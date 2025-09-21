#!/bin/bash

# ===============================
# Azazel 統合インストーラ with 多言語対応
# ===============================

# ===== 言語オプション処理（--lang=en で英語出力） =====
LANG_OPTION="ja"  # デフォルトは日本語
for arg in "$@"; do
  case $arg in
    --lang=*)
      LANG_OPTION="${arg#*=}"
      ;;
  esac
done

# ===== メッセージ辞書（日本語/英語） =====
if [[ "$LANG_OPTION" == "en" ]]; then
  MSG_REQUIRE_ROOT="[ERROR] This script must be run as root."
  MSG_EXAMPLE_SUDO="       Example: sudo $0"
  MSG_ERROR_GENERIC="[ERROR] An error occurred. See the log for details."
  MSG_LOG_PATH="Details:"
  MSG_START_INSTALL="[INFO] Starting Azazel installation"
  MSG_UPDATE_SYSTEM="[INFO] Updating system and installing dependencies..."
  MSG_SURICATA_RULES="[INFO] Fetching initial Suricata rules..."
  MSG_CREATE_DIRS="[INFO] Creating Azazel directory structure..."
  MSG_COPY_CONFIGS="[INFO] Copying configuration files before Docker startup..."
  MSG_SETUP_DOCKER="[INFO] Deploying docker-compose and starting containers..."
  MSG_MATTERMOST_SETUP="[INFO] Deploying Mattermost to /opt..."
  MSG_CONFIG_UPDATED="[SUCCESS] config.json updated with SiteURL and DataSource."
  MSG_MATTERMOST_STARTED="[SUCCESS] Mattermost service started successfully."
  MSG_INSTALL_DONE="[SUCCESS] Azazel setup is complete!"
else
  MSG_REQUIRE_ROOT="[ERROR] このスクリプトは管理者権限で実行する必要があります。"
  MSG_EXAMPLE_SUDO="       例: sudo $0"
  MSG_ERROR_GENERIC="[ERROR] スクリプトの実行中にエラーが発生しました。詳細はログを確認してください。"
  MSG_LOG_PATH="詳細:"
  MSG_START_INSTALL="[INFO] Azazel 統合インストール開始"
  MSG_UPDATE_SYSTEM="[INFO] システム更新と必要パッケージのインストール..."
  MSG_SURICATA_RULES="[INFO] Suricata ルールを初回取得中..."
  MSG_CREATE_DIRS="[INFO] ディレクトリ構成作成中..."
  MSG_COPY_CONFIGS="[INFO] コンテナ起動前に設定ファイルをコピー..."
  MSG_SETUP_DOCKER="[INFO] docker-compose.yml を配置し、コンテナ起動中..."
  MSG_MATTERMOST_SETUP="[INFO] Mattermost を /opt に展開中..."
  MSG_CONFIG_UPDATED="[SUCCESS] config.json に SiteURL/DataSource を反映しました。"
  MSG_MATTERMOST_STARTED="[SUCCESS] Mattermost サービスが正常に起動しました。"
  MSG_INSTALL_DONE="[SUCCESS] Azazel 環境の構築が完了しました！"
fi

# === 管理者権限チェック ===
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\e[91m$MSG_REQUIRE_ROOT\e[0m"
    echo "$MSG_EXAMPLE_SUDO"
    exit 1
fi

# === エラーハンドリング ===
set -e
ERROR_LOG="/opt/azazel/logs/install_errors.log"
mkdir -p /opt/azazel/logs
trap 'echo -e "\e[91m$MSG_ERROR_GENERIC\e[0m $MSG_LOG_PATH $ERROR_LOG" | tee -a "$ERROR_LOG"' ERR

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
echo -e "\e[96m$MSG_START_INSTALL\e[0m ($(date))" | tee -a "$ERROR_LOG"

log_and_exit() {
    echo -e "\e[91m[ERROR]\e[0m $1" | tee -a "$ERROR_LOG"
    echo -e "\e[93m[INFO]\e[0m 解決策: $2" | tee -a "$ERROR_LOG"
    exit 1
}

# === システムアップデートと依存パッケージ ===
echo -e "\e[96m$MSG_UPDATE_SYSTEM\e[0m" | tee -a "$ERROR_LOG"
apt update && apt upgrade -y
apt install -y curl wget git docker.io docker-compose python3 python3-pip suricata iptables-persistent jq

# === Suricata ルール初期取得 ===
echo -e "\e[96m$MSG_SURICATA_RULES\e[0m" | tee -a "$ERROR_LOG"
suricata-update || log_and_exit "Suricataルールの取得に失敗" "インターネット接続と suricata-update を確認"

# === Suricata設定ファイルのバックアップとminimal構成への置き換え ===
echo -e "\e[96m[INFO]\e[0m Suricata設定をminimal構成に切り替えます..." | tee -a "$ERROR_LOG"
cp /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.bak
cp "$PROJECT_ROOT/config/suricata_minimal.yaml" /etc/suricata/suricata.yaml

# === Azazel ディレクトリ構成作成 ===
echo -e "\e[96m$MSG_CREATE_DIRS\e[0m" | tee -a "$ERROR_LOG"
mkdir -p /opt/azazel/{bin,config,logs,data,containers}
chown -R "$(whoami)":"$(whoami)" /opt/azazel

# === 設定ファイルの先行配置（重要: コンテナ起動前） ===
echo -e "\e[96m$MSG_COPY_CONFIGS\e[0m" | tee -a "$ERROR_LOG"
cp "$PROJECT_ROOT/config/vector.toml" /opt/azazel/config/
cp "$PROJECT_ROOT/config/opencanary.conf" /opt/azazel/config/

# === docker-compose.yml の配置と Docker コンテナ起動 ===
echo -e "\e[96m$MSG_SETUP_DOCKER\e[0m" | tee -a "$ERROR_LOG"
cp "$PROJECT_ROOT/config/docker-compose.yml" /opt/azazel/containers/docker-compose.yml
cd /opt/azazel/containers
docker-compose up -d || log_and_exit "Dockerコンテナ起動に失敗" "docker logs を確認してください"

# === Mattermost セットアップ ===
echo -e "\e[96m$MSG_MATTERMOST_SETUP\e[0m" | tee -a "$ERROR_LOG"
cd /opt
wget https://releases.mattermost.com/9.0.0/mattermost-9.0.0-linux-arm64.tar.gz
 tar -xzf mattermost-9.0.0-linux-arm64.tar.gz
rm mattermost-9.0.0-linux-arm64.tar.gz
mkdir -p /opt/mattermost/data

if ! id mattermost &>/dev/null; then
    useradd --system --user-group mattermost
fi

chown -R mattermost:mattermost /opt/mattermost
chmod 750 /opt/mattermost/config

IPADDR=$(hostname -I | awk '{print $1}')
SITEURL="http://${IPADDR}:8065"
DATASOURCE="postgres://mmuser:securepassword@localhost:5432/mattermost?sslmode=disable"
CONFIG_JSON="/opt/mattermost/config/config.json"

jq ".ServiceSettings.SiteURL = \"${SITEURL}\" | .SqlSettings.DataSource = \"${DATASOURCE}\"" \
    "$CONFIG_JSON" > /tmp/config.tmp && mv /tmp/config.tmp "$CONFIG_JSON"

chown mattermost:mattermost "$CONFIG_JSON"
chmod 640 "$CONFIG_JSON"
echo -e "\e[92m$MSG_CONFIG_UPDATED\e[0m"

cp "$PROJECT_ROOT/config/mattermost.service" /etc/systemd/system/mattermost.service
systemctl daemon-reload
systemctl enable mattermost
systemctl start mattermost

if systemctl is-active --quiet mattermost; then
    echo -e "\e[92m$MSG_MATTERMOST_STARTED\e[0m"
else
    log_and_exit "Mattermost サービスの起動に失敗" "systemctl status mattermost を確認してください。"
fi

echo -e "\e[92m$MSG_INSTALL_DONE\e[0m" | tee -a "$ERROR_LOG"
