#!/bin/bash

# === Azazel Runtime Retrieval Script ===
# /opt/azazel の内容をローカルディレクトリ azazel/azazel_runtime にコピーします。
# 動作確認やローカルでのファイル検証に使用します。

set -e

SRC_DIR="/opt/azazel"
DEST_DIR="$PWD/azazel_runtime"

echo "[INFO] Retrieving Azazel runtime from $SRC_DIR to $DEST_DIR"

if [ ! -d "$SRC_DIR" ]; then
    echo "[ERROR] $SRC_DIR が存在しません。Azazelがインストールされていない可能性があります。"
    exit 1
fi

mkdir -p "$DEST_DIR"
rsync -av --delete "$SRC_DIR"/ "$DEST_DIR"

echo "[SUCCESS] Retrieval completed."
