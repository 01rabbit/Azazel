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

# 必要パッケージのインストール（sqlite3 は不要のため除外）
echo "[INFO] パッケージインストール中..." | tee -a "$ERROR_LOG"
if ! apt install -y curl wget git docker.io docker-compose python3 python3-pip suricata iptables-persistent; then
    log_and_exit "パッケージのインストールに失敗しました。" "apt install を個別に試してみてください。"
fi

# Docker・Suricata 有効化
echo "[INFO] DockerとSuricataを有効化..." | tee -a "$ERROR_LOG"
systemctl enable docker --now
systemctl enable suricata --now

# Fluent Bit インストール（/opt配下に入る）
echo "[INFO] Fluent Bit をインストール中..." | tee -a "$ERROR_LOG"
if ! curl -fsSL https://fluentbit.io/install.sh | sh; then
    log_and_exit "Fluent Bit のインストールに失敗しました。" "公式サイトの手順を参照してください（https://fluentbit.io/）"
fi
systemctl enable fluent-bit --now

# Azazelディレクトリ作成
echo "[INFO] ディレクトリを作成中..." | tee -a "$ERROR_LOG"
mkdir -p /opt/azazel/{bin,config,logs,data,containers}
chown -R "$(whoami)":"$(whoami)" /opt/azazel

echo "[SUCCESS] インストール完了！次に ./setup_containers.sh を実行してください。" | tee -a "$ERROR_LOG"
