import os
import json
import time
import datetime
from collections import defaultdict

from config.notice import NOTICE_MATTERMOST
from utils.mattermost import send_alert_to_mattermost
from utils.iptables_control import redirect_and_delay_attacker

# 自身のIPリスト（誤検知防止用）
SELF_IPS = ["172.16.0.254"]  # このGWのIP（適宜追加・編集）

# 新規検知した攻撃者IPの記録
detected_attackers = set()

# eve.jsonファイルパス（Suricataログ）
EVE_JSON_PATH = "/var/log/suricata/eve.json"

# 監視対象カテゴリフィルタ（必要なら調整）
FILTER_SIG_CATEGORY = [
    "Attempted Administrator Privilege Gain",
    "Attempted User Privilege Gain",
    "Executable Code was Detected",
    "Attempted Information Leak",
    "Web Application Attack",
    "Shellcode Detected",
    "SQL Injection",
    "Trojan Activity",
    "Network Trojan",
]

def is_self_traffic(event):
    """自身の通信か判定する関数"""
    src_ip = event.get("src_ip")
    dest_ip = event.get("dest_ip")
    return src_ip in SELF_IPS or dest_ip in SELF_IPS

def main():
    print("[*] Suricataログ監視開始...")
    
    with open(EVE_JSON_PATH, "r") as f:
        # ファイル末尾から監視開始
        f.seek(0, os.SEEK_END)

        while True:
            line = f.readline()
            if not line:
                time.sleep(0.1)
                continue

            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue

            if event.get("event_type") != "alert":
                continue

            # カテゴリフィルタ
            alert_category = event.get("alert", {}).get("category", "")
            if alert_category not in FILTER_SIG_CATEGORY:
                continue

            if is_self_traffic(event):
                continue  # 自分通信は無視

            # --- 通知本文作成 ---
            src_ip = event.get("src_ip", "")
            dest_ip = event.get("dest_ip", "")
            proto = event.get("proto", "")
            signature = event.get("alert", {}).get("signature", "")
            severity = event.get("alert", {}).get("severity", 3)

            emoji = ":warning:"
            if severity == 1:
                emoji = ":rotating_light:"
            elif severity == 2:
                emoji = ":warning:"

            notice_text = f"{emoji} **Suricata Alert**\n- Signature: `{signature}`\n- Source: `{src_ip}`\n- Destination: `{dest_ip}`\n- Protocol: `{proto}`\n- Severity: `{severity}`\n@all"

            send_alert_to_mattermost(notice_text)

            # --- 自動防御処理 ---
            if src_ip:
                redirect_and_delay_attacker(src_ip)

                if src_ip not in detected_attackers:
                    battle_message = f":new: **新たな侵入者検知**\n- 攻撃元IP: `{src_ip}`"
                    send_alert_to_mattermost(battle_message)
                    detected_attackers.add(src_ip)

if __name__ == "__main__":
    main()
