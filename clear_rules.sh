#!/bin/bash

# 使用するネットワークインタフェース名
IFACE="wlan1"  # ←適宜変更してね

echo "[*] 既存のiptables NATルールとtc設定をクリアします..."

# iptables NATテーブル PREROUTINGチェーンから、OpenCanaryへのリダイレクトルールを削除
iptables -t nat -F PREROUTING

# tcの遅延設定を削除
tc qdisc del dev $IFACE root

echo "[+] クリア完了！"
