#!/bin/bash

# === Azazel: Suricataルールフィルタスクリプト ===
# scan, malware, exploit, trojan, dos カテゴリを含むルールのみ抽出

SOURCE_RULES="/etc/suricata/rules/suricata.rules"
FILTERED_RULES="/etc/suricata/rules/filtered.rules"

# 抽出対象のキーワード
KEYWORDS=("scan" "malware" "exploit" "trojan" "dos")

echo "[INFO] Suricataルールをフィルタリングします..."
echo "[INFO] 対象キーワード: ${KEYWORDS[*]}"

# 既存のfiltered.rulesを初期化
> "$FILTERED_RULES"

# 各キーワードにマッチする行を追加
for KEY in "${KEYWORDS[@]}"; do
    grep -i "$KEY" "$SOURCE_RULES" >> "$FILTERED_RULES"
done

echo "[SUCCESS] フィルタ済みルールを $FILTERED_RULES に出力しました。"
