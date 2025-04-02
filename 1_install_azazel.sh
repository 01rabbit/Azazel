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

# APTレポジトリ追加（Fluent Bit公式）
if ! curl -fsSL https://packages.fluentbit.io/fluentbit.key | sudo gpg --dearmor -o /usr/share/keyrings/fluentbit.gpg; then
    log_and_exit "Fluent Bit GPGキーの取得に失敗しました。" "https://docs.fluentbit.io/manual/installation/linux/debian"
fi

echo "deb [signed-by=/usr/share/keyrings/fluentbit.gpg] https://packages.fluentbit.io/debian/ bookworm main" | \
    sudo tee /etc/apt/sources.list.d/fluentbit.list > /dev/null

# パッケージインストール
if ! sudo apt update >> "$ERROR_LOG" 2>&1; then
    log_and_exit "apt update に失敗しました。" "ネットワーク設定を確認してください"
fi

if ! sudo apt install td-agent-bit -y >> "$ERROR_LOG" 2>&1; then
    log_and_exit "td-agent-bit のインストールに失敗しました。" "Fluent Bit パッケージ取得を確認してください"
fi

# サービス起動・自動起動設定
if ! sudo systemctl enable td-agent-bit --now >> "$ERROR_LOG" 2>&1; then
    log_and_exit "td-agent-bit のサービス起動に失敗しました。" "systemd 状態を確認してください"
fi

# Azazelディレクトリ作成
echo "[INFO] ディレクトリを作成中..." | tee -a "$ERROR_LOG"
mkdir -p /opt/azazel/{bin,config,logs,data,containers}
chown -R "$(whoami)":"$(whoami)" /opt/azazel

echo "[SUCCESS] インストール完了！次に ./setup_containers.sh を実行してください。" | tee -a "$ERROR_LOG"
