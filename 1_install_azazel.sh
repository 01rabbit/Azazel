#!/bin/bash

# 管理者権限チェック
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] このスクリプトは管理者権限で実行する必要があります。"
    echo "       例: sudo $0"
    exit 1
fi

# エラーハンドリングとログ
set -e
ERROR_LOG="/opt/azazel/logs/install_errors.log"
mkdir -p /opt/azazel/logs
trap 'echo "[ERROR] スクリプトの実行中にエラーが発生しました。詳細は $ERROR_LOG を確認してください。" | tee -a "$ERROR_LOG"' ERR

echo "[INFO] Azazelインストール開始 $(date)" | tee -a "$ERROR_LOG"

log_and_exit() {
    echo "[ERROR] $1" | tee -a "$ERROR_LOG"
    echo "[INFO] 解決策: $2" | tee -a "$ERROR_LOG"
    exit 1
}

# システムアップデート
echo "[INFO] システム更新中..." | tee -a "$ERROR_LOG"
if ! apt update && apt upgrade -y; then
    log_and_exit "システム更新に失敗しました。" "インターネット接続を確認してください。"
fi

# 必要パッケージのインストール
echo "[INFO] パッケージインストール中..." | tee -a "$ERROR_LOG"
if ! apt install -y curl wget git docker.io docker-compose python3 python3-pip suricata iptables-persistent jq; then
    log_and_exit "パッケージのインストールに失敗しました。" "apt install を個別に試してみてください。"
fi

# Docker・Suricata 有効化
echo "[INFO] DockerとSuricataを有効化..." | tee -a "$ERROR_LOG"
systemctl enable docker --now
systemctl enable suricata --now

# === Suricata ルール初期取得 ===
echo "[INFO] Suricataルールを初回取得中..." | tee -a "$ERROR_LOG"

if ! sudo suricata-update >> "$ERROR_LOG" 2>&1; then
    echo "[ERROR] Suricataルールの取得に失敗しました。" | tee -a "$ERROR_LOG"
    echo "[INFO] 解決策: ネットワーク接続や suricata-update のインストールを確認してください。" | tee -a "$ERROR_LOG"
    exit 1
fi

echo "[SUCCESS] Suricataルールの初期取得が完了しました。" | tee -a "$ERROR_LOG"


# Azazelディレクトリ作成
echo "[INFO] ディレクトリを作成中..." | tee -a "$ERROR_LOG"
mkdir -p /opt/azazel/{bin,config,logs,data,containers}
chown -R "$(whoami)":"$(whoami)" /opt/azazel

echo "[SUCCESS] インストール完了！次に ./2_setup_containers.sh を実行してください。" | tee -a "$ERROR_LOG"
