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

# Fluent Bit インストール（APT経由）
echo "[INFO] Fluent Bit をインストール中..." | tee -a "$ERROR_LOG"

# APTレポジトリ追加（Fluent Bit公式 for Raspbian）
if ! curl -fsSL https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -; then
    log_and_exit "Fluent Bit GPGキーの取得に失敗しました。" "https://docs.fluentbit.io/manual/installation/linux/debian"
fi

# sources.list に直接追記（Raspbian向け）
if ! grep -q "packages.fluentbit.io/raspbian/bullseye" /etc/apt/sources.list; then
    echo "deb https://packages.fluentbit.io/raspbian/bullseye bullseye main" | \
        sudo tee -a /etc/apt/sources.list > /dev/null
fi

# パッケージインストール
if ! sudo apt-get update >> "$ERROR_LOG" 2>&1; then
    log_and_exit "apt update に失敗しました。" "ネットワーク設定を確認してください"
fi

if ! sudo apt-get install fluent-bit -y >> "$ERROR_LOG" 2>&1; then
    log_and_exit "fluent-bit のインストールに失敗しました。" "Fluent Bit パッケージ取得を確認してください"
fi

# サービス起動・自動起動設定
if ! sudo systemctl enable fluent-bit --now >> "$ERROR_LOG" 2>&1; then
    log_and_exit "fluent-bit のサービス起動に失敗しました。" "systemd 状態を確認してください"
fi

# Azazelディレクトリ作成
echo "[INFO] ディレクトリを作成中..." | tee -a "$ERROR_LOG"
mkdir -p /opt/azazel/{bin,config,logs,data,containers}
chown -R "$(whoami)":"$(whoami)" /opt/azazel

echo "[SUCCESS] インストール完了！次に ./2_setup_containers.sh を実行してください。" | tee -a "$ERROR_LOG"
