#!/bin/bash

# 管理者権限チェック
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] このスクリプトは管理者権限で実行する必要があります。"
    echo "       例: sudo $0"
    exit 1
fi

# エラーハンドリング
set -e
ERROR_LOG="/opt/azazel/logs/install_errors.log"
mkdir -p /opt/azazel/logs
trap 'echo "[ERROR] スクリプトの実行中にエラーが発生しました。詳細は $ERROR_LOG を確認してください。" | tee -a "$ERROR_LOG"' ERR

echo "[INFO] Azazel構成ファイルの配置開始 $(date)" | tee -a "$ERROR_LOG"

log_and_exit() {
    echo "[ERROR] $1" | tee -a "$ERROR_LOG"
    echo "[INFO] 解決策: $2" | tee -a "$ERROR_LOG"
    exit 1
}

# Fluent Bit 設定
echo "[INFO] Fluent Bit 設定を作成..." | tee -a "$ERROR_LOG"
cat <<EOF > /opt/azazel/config/fluentbit.conf
[INPUT]
    Name tail
    Path /var/log/suricata/eve.json
    Tag suricata
    Parser json

[OUTPUT]
    Name http
    Match suricata
    Host 192.168.X.X
    Port 8065
    URI /hooks/XXXXX
    Format json
EOF

# Vector 設定
echo "[INFO] Vector 設定を作成..." | tee -a "$ERROR_LOG"
cat <<EOF > /opt/azazel/config/vector.toml
[sources.fluentbit]
  type = "socket"
  address = "0.0.0.0:24224"
  mode = "udp"

[transforms.json_parse]
  type = "json_parser"
  inputs = ["fluentbit"]

[sinks.file]
  type = "file"
  inputs = ["json_parse"]
  path = "/logs/azazel.log"
EOF

# OpenCanary 設定
echo "[INFO] OpenCanary 設定を作成..." | tee -a "$ERROR_LOG"
cat <<EOF > /opt/azazel/config/opencanary.conf
{
    "device.node_id": "azazel-pi5",
    "ftp.enabled": true,
    "ssh.enabled": true,
    "ssh.port": 2222,
    "http.enabled": true,
    "portscan.enabled": true,
    "logger": {
        "class": "PyLogger",
        "kwargs": {
            "formatters": {
                "plain": {
                    "format": "%(asctime)s %(message)s"
                }
            },
            "handlers": {
                "file": {
                    "class": "logging.FileHandler",
                    "filename": "/logs/opencanary.log"
                }
            }
        }
    }
}
EOF

# === Mattermost を /opt に展開 ===
echo "[INFO] Mattermost をダウンロードして /opt に展開..." | tee -a "$ERROR_LOG"
cd /opt
wget https://releases.mattermost.com/9.0.0/mattermost-9.0.0-linux-arm64.tar.gz
tar -xzf mattermost-9.0.0-linux-arm64.tar.gz
rm mattermost-9.0.0-linux-arm64.tar.gz
mkdir -p /opt/mattermost/data

# === mattermost ユーザー・グループ作成 ===
if ! id mattermost &>/dev/null; then
    useradd --system --user-group mattermost
    echo "[INFO] mattermost ユーザーを作成しました。" | tee -a "$ERROR_LOG"
fi

# === ディレクトリの所有権とパーミッション調整 ===
chown -R mattermost:mattermost /opt/mattermost
chmod 750 /opt/mattermost/config
chmod 640 /opt/mattermost/config/config.json

# === jq が未インストールなら導入 ===
if ! command -v jq &>/dev/null; then
    echo "[INFO] jq をインストール..." | tee -a "$ERROR_LOG"
    apt update && apt install -y jq
fi

# === config.json の SiteURL および DataSource を自動設定 ===
echo "[INFO] config.json に SiteURL / DataSource を自動設定..." | tee -a "$ERROR_LOG"
IPADDR=$(hostname -I | awk '{print $1}')
SITEURL="http://${IPADDR}:8065"
DATASOURCE="postgres://mmuser:securepassword@localhost:5432/mattermost?sslmode=disable"
CONFIG_JSON="/opt/mattermost/config/config.json"

jq ".ServiceSettings.SiteURL = \"${SITEURL}\" | .SqlSettings.DataSource = \"${DATASOURCE}\"" \
    "$CONFIG_JSON" > /tmp/config.tmp && mv /tmp/config.tmp "$CONFIG_JSON"

echo "[SUCCESS] config.json に反映完了: SiteURL=${SITEURL}" | tee -a "$ERROR_LOG"

# === Mattermost systemd ユニット作成 ===
echo "[INFO] systemd ユニットファイルを作成..." | tee -a "$ERROR_LOG"
cat <<EOF > /etc/systemd/system/mattermost.service
[Unit]
Description=Mattermost
After=network.target

[Service]
Type=simple
ExecStart=/opt/mattermost/bin/mattermost
WorkingDirectory=/opt/mattermost
User=mattermost
Group=mattermost
Restart=always
LimitNOFILE=49152

[Install]
WantedBy=multi-user.target
EOF

# === systemd サービス有効化と起動 ===
systemctl daemon-reload
systemctl enable mattermost
systemctl start mattermost
systemctl status mattermost | tee -a "$ERROR_LOG"
if systemctl is-active --quiet mattermost; then
    echo "[SUCCESS] Mattermost サービスが起動しました。" | tee -a "$ERROR_LOG"
else
    log_and_exit "Mattermost サービスの起動に失敗しました。" "systemctl status mattermost を確認してください。"
fi

# Firewall 設定
echo "[INFO] iptables によるファイアウォールルールを適用..." | tee -a "$ERROR_LOG"
# まずループバックと確立済み通信を許可
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# SSHとMattermostを明示的に許可
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 8065 -j ACCEPT
# その他はDROP
iptables -A INPUT -j DROP

iptables-save | tee /etc/iptables/rules.v4 > /dev/null

# 通信遅延（攻撃者遅滞用）
echo "[INFO] 攻撃者向け遅延動作を適用 (100ms delay)..." | tee -a "$ERROR_LOG"
tc qdisc add dev eth0 root netem delay 100ms || echo "[WARN] tc 設定が既に存在する可能性があります"

# ログバックアップスクリプトと cron 登録
echo "[INFO] ログバックアップ用スクリプトを作成..." | tee -a "$ERROR_LOG"
cat <<EOF > /opt/azazel/bin/backup_logs.sh
#!/bin/bash
rsync -avz /opt/azazel/logs/ user@backup-server:/remote/logs/
EOF
chmod +x /opt/azazel/bin/backup_logs.sh

( sudo crontab -l 2>/dev/null | grep -v '/opt/azazel/bin/backup_logs.sh' ; echo "0 * * * * /opt/azazel/bin/backup_logs.sh" ) | sudo crontab -
sudo crontab -l | grep backup_logs.sh && echo "[INFO] crontab登録成功" || echo "[ERROR] crontab登録失敗"

echo "[SUCCESS] Azazel 構成完了！すべてのコンポーネントが動作準備できました。" | tee -a "$ERROR_LOG"
