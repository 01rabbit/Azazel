#!/bin/bash

# === Azazel Runtime Deployment Script ===
# このスクリプトは azazel_runtime/ の内容を /opt/azazel に展開するためのものです。
# 開発ディレクトリから実行してください。

set -e

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="/opt/azazel"

echo "[INFO] Deploying Azazel runtime to $DEST_DIR"
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] このスクリプトは root 権限で実行する必要があります（sudo）"
    exit 1
fi

mkdir -p "$DEST_DIR"
rsync -av --exclude='logs/*' --exclude='data/*' "$SRC_DIR"/ "$DEST_DIR"

echo "[SUCCESS] Deployment completed."
