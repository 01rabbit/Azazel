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
trap 'echo "[ERROR] スクリプトの実行中にエラーが発生しました。詳細は $ERROR_LOG を確認してください。" | tee -a "$ERROR_LOG"' ERR

echo "[INFO] Dockerコンテナのセットアップ開始 $(date)" | tee -a "$ERROR_LOG"

log_and_exit() {
    echo "[ERROR] $1" | tee -a "$ERROR_LOG"
    echo "[INFO] 解決策: $2" | tee -a "$ERROR_LOG"
    exit 1
}

# Docker用のディレクトリ作成
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
mkdir -p /opt/azazel/{containers,data,config,logs}
cd /opt/azazel/containers || log_and_exit "ディレクトリ移動に失敗しました。" "手動で cd /opt/azazel/containers を実行してください。"

# docker-compose.yml を配置（固定的なパス指定）
echo "[INFO] docker-compose.yml を配置中..." | tee -a "$ERROR_LOG"
SOURCE_YML="$PROJECT_ROOT/config/docker-compose.yml"

if [ ! -f "$SOURCE_YML" ]; then
    log_and_exit "docker-compose.yml が $SOURCE_YML に見つかりません。" "$PROJECT_ROOT/config/ に正しく配置されているか確認してください。"
fi

cp "$SOURCE_YML" ./docker-compose.yml

# コンテナ起動
echo "[INFO] Dockerコンテナを起動中..." | tee -a "$ERROR_LOG"
if ! docker-compose up -d; then
    log_and_exit "Dockerコンテナの起動に失敗しました。" "docker logs azazel_postgres などでログを確認してください。"
fi

# 現在のユーザーを docker グループに追加（未所属の場合のみ）
CURRENT_USER="${SUDO_USER:-$USER}"

if id -nG "$CURRENT_USER" | grep -qw docker; then
    echo "[INFO] $CURRENT_USER はすでに docker グループに所属しています。"
else
    echo "[INFO] $CURRENT_USER を docker グループに追加します。"
    sudo usermod -aG docker "$CURRENT_USER"
    echo "[SUCCESS] docker グループに追加しました。"

    echo ""
    echo "⚠️  変更を反映させるには、以下を実行してください："
    echo ""
    echo "   newgrp docker"
    echo "     または"
    echo "   一度ログアウトして再ログイン"
    echo ""
    echo "[INFO] 処理はここで終了します。以降の操作は新しいセッションで実行してください。"
    exit 0
fi

echo "[INFO] Dockerコンテナのセットアップ完了！次に ./3_configure_services.sh を実行してください。" | tee -a "$ERROR_LOG"
