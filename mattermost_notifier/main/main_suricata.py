#!/usr/bin/env python3
# coding: utf-8
"""
Suricata eve.json を監視し Mattermost へ通知、必要に応じ DNAT 遅滞行動を発動
"""

import json, time, logging, sys
from datetime import datetime
from collections import defaultdict
from pathlib import Path

from config import notice
from utils.mattermost     import send_alert_to_mattermost
from utils.delay_action   import divert_to_opencanary, OPENCANARY_IP

EVE_FILE           = Path(notice.SURICATA_EVE_JSON_PATH)
FILTER_SIG_CATEGORY = [
    "Attack Response","DNS","DOS","Exploit","FTP","ICMP","IMAP","Malware",
    "NETBIOS","Phishing","POP3","RPC","SCAN","Shellcode","SMTP","SNMP",
    "SQL","TELNET","TFTP","Web Client","Web Server","Web Specific Apps","WORM"
]
NOTIFY_CALLBACK = None

cooldown_seconds   = 60          # 同一シグネチャ抑止時間
summary_interval   = 60          # サマリ送信間隔

last_alert_times  = {}
suppressed_alerts = defaultdict(int)
last_summary_time = time.time()

# ────────────────────────────────────────────────────────────
def follow(fp: Path, skip_existing=True):
    pos = None
    try:
        while True:
            if not fp.exists():
                time.sleep(1)
                continue

            size = fp.stat().st_size
            with fp.open() as f:
                if pos is None:
                    if skip_existing:
                        f.seek(0, 2)
                    pos = f.tell()

                if size < pos:
                    pos = 0
                f.seek(pos)

                for line in f:
                    yield line.rstrip("\n")
                pos = f.tell()
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("\n✋ Suricata monitor interrupted, exiting...")
        sys.exit(0)

# ────────────────────────────────────────────────────────────
def parse_alert(line: str):
    try:
        data = json.loads(line)
        if data.get("event_type") != "alert":
            return None

        alert      = data["alert"]
        signature  = alert["signature"]
        category   = signature.split(" ", 2)[1] if signature.startswith("ET ") else None

        if category and category in FILTER_SIG_CATEGORY:
            return {
                "timestamp" : data["timestamp"],
                "signature" : signature,
                "severity"  : alert.get("severity", 3),
                "src_ip"    : data.get("src_ip",""),
                "dest_ip"   : data.get("dest_ip",""),
                "proto"     : data.get("proto",""),
                "dest_port" : data.get("dest_port"),
                "details"   : alert,
                "confidence": alert.get("metadata",{}).get("confidence",["Unknown"])[0],
            }
    except json.JSONDecodeError:
        pass
    return None

# ────────────────────────────────────────────────────────────
def should_notify(key: str) -> bool:
    now  = datetime.now(notice.TZ)
    last = last_alert_times.get(key)
    if not last or (now-last).total_seconds() > cooldown_seconds:
        last_alert_times[key] = now
        return True
    return False

def send_summary():
    if not suppressed_alerts:
        return
    now_str = datetime.now(notice.TZ).strftime("%Y-%m-%d %H:%M")
    body = "\n".join(f"- {sig}: {cnt} times" for sig,cnt in suppressed_alerts.items())
    send_alert_to_mattermost("Suricata",{
        "timestamp": now_str,
        "signature": "Summary",
        "severity" : 3,
        "src_ip": "-", "dest_ip": "-", "proto": "-",
        "details": f"📃 **[Suricata Summary - {now_str}]**\n\n{body}",
        "confidence": "Low"
    })
    suppressed_alerts.clear()

# ────────────────────────────────────────────────────────────
def main():
    global last_summary_time
    logging.basicConfig(level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s")

    logging.info(f"🚀 Monitoring eve.json: {EVE_FILE}")
    for line in follow(EVE_FILE):
        alert = parse_alert(line)
        if not alert:
            continue

        sig, src_ip, dport = alert["signature"], alert["src_ip"], alert["dest_port"]
        key = f"{sig}:{src_ip}"

        trigger = ("nmap" in sig.lower()) or (
            alert["proto"] == "TCP" and dport in (22, 80, 5432)
        )

        # ── 遅滞行動 ──────────────────
        if trigger:
            if should_notify(key):
                send_alert_to_mattermost("Suricata",{
                    **alert,
                    "signature":"⚠️ 偵察／攻撃を検知",
                    "severity":1,
                    "details":sig,
                    "confidence":"High"
                })
                logging.info(f"Notify & DNAT: {sig}")

                try:
                    divert_to_opencanary(src_ip, dport)
                    if 'NOTIFY_CALLBACK' in globals():
                        NOTIFY_CALLBACK()

                    send_alert_to_mattermost("Suricata",{
                        "timestamp": alert["timestamp"],
                        "signature": "🛡️ 遅滞行動発動（DNAT）",
                        "severity": 2,
                        "src_ip": src_ip,
                        "dest_ip": f"{OPENCANARY_IP}:{dport}",
                        "proto": alert["proto"],
                        "details": "攻撃元の通信を OpenCanary へ転送しました。",
                        "confidence": "High"
                    })
                    logging.info(f"[遅滞行動] {src_ip}:{dport} -> {OPENCANARY_IP}:{dport}")

                except Exception as e:
                    logging.error(f"DNAT error: {e}")
            else:
                suppressed_alerts[sig] += 1
            continue

        # ── 通常通知 ──────────────────
        if should_notify(key):
            send_alert_to_mattermost("Suricata", alert)
        else:
            suppressed_alerts[sig] += 1

        # ── サマリ ────────────────────
        if time.time() - last_summary_time >= summary_interval:
            send_summary()
            last_summary_time = time.time()

if __name__ == "__main__":
    main()
