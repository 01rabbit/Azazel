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
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Vector 設定
echo "[INFO] Vector 設定をコピー..." | tee -a "$ERROR_LOG"
cp "$PROJECT_ROOT/config/vector.toml" /opt/azazel/config/

# OpenCanary 設定
echo "[INFO] OpenCanary 設定をコピー..." | tee -a "$ERROR_LOG"
cp "$PROJECT_ROOT/config/opencanary.conf" /opt/azazel/config/

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

# === jq が未インストールなら導入 ===
if ! command -v jq &>/dev/null; then
    echo "[INFO] jq をインストール..." | tee -a "$ERROR_LOG"
    apt update && apt install -y jq
fi

# === config.json の SiteURL および DataSource を自動設定 ===
echo "[INFO] config.json に SiteURL / DataSource を自動設定..." | tee -a "$ERROR_LOG"
IPADDR=$(hostname -I | awk '{print $1}')
SITEURL="http://${IPADDR}:8065"
DATASOURCE="postgres://mmuser:securepassword@azazel_postgres:5432/mattermost?sslmode=disable"
CONFIG_JSON="/opt/mattermost/config/config.json"

jq ".ServiceSettings.SiteURL = \"${SITEURL}\" | .SqlSettings.DataSource = \"${DATASOURCE}\"" \
    "$CONFIG_JSON" > /tmp/config.tmp && mv /tmp/config.tmp "$CONFIG_JSON"

# 所有権とパーミッション修正（重要）
chown mattermost:mattermost "$CONFIG_JSON"
chmod 640 "$CONFIG_JSON"

echo "[SUCCESS] config.json に反映完了: SiteURL=${SITEURL}" | tee -a "$ERROR_LOG"

# Mattermost systemd ユニットファイルを配置
echo "[INFO] systemd ユニットファイルをコピー..." | tee -a "$ERROR_LOG"
cp "$PROJECT_ROOT/config/mattermost.service" /etc/systemd/system/mattermost.service

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

echo "[SUCCESS] Azazel 構成完了！すべてのコンポーネントが動作準備できました。" | tee -a "$ERROR_LOG"
