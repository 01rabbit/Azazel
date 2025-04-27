import time
import json
from datetime import datetime
from collections import defaultdict
from config import notice
from utils.mattermost import send_alert_to_mattermost

FILTER_SIG_CATEGORY = [
    "Attack Response", "DNS", "DOS", "Exploit", "FTP",
    "ICMP", "IMAP", "Malware", "NETBIOS", "Phishing",
    "POP3", "RPC", "SCAN", "Shellcode", "SMTP", "SNMP",
    "SQL", "TELNET", "TFTP", "Web Client", "Web Server",
    "Web Specific Apps", "WORM"
]

CATEGORY_EMOJIS = {
    "SQL": "📂",
    "SSH": "🔐",
    "NMAP": "📁",
    "VNC": "🖥️",
    "FTP": "📂",
    "HTTP": "🌐",
    "DEFAULT": "📌"
}

last_alert_times = {}
cooldown_seconds = 60
suppressed_alerts = defaultdict(int)
last_summary_time = time.time()
summary_interval = 60

def follow(file):
    file.seek(0, 2)
    while True:
        line = file.readline()
        if not line:
            time.sleep(1)
            continue
        yield line

def extract_et_category(signature):
    if signature.startswith("ET "):
        parts = signature.split(" ", 2)
        if len(parts) >= 2:
            return parts[1]
    return None

def get_confidence_level(alert):
    meta = alert.get("metadata", {})
    if isinstance(meta, dict):
        conf = meta.get("confidence", ["Unknown"])
        if isinstance(conf, list):
            return conf[0]
    return "Unknown"

def get_category_emoji(signature):
    for keyword, emoji in CATEGORY_EMOJIS.items():
        if keyword.lower() in signature.lower():
            return emoji
    return CATEGORY_EMOJIS["DEFAULT"]

def parse_alert(line):
    try:
        data = json.loads(line)
        if data.get("event_type") == "alert":
            alert = data.get("alert", {})
            signature = alert.get("signature", "")
            category = extract_et_category(signature)
            if category and category in FILTER_SIG_CATEGORY:
                return {
                    "timestamp": data.get("timestamp", ""),
                    "signature": signature,
                    "severity": alert.get("severity", 3),
                    "src_ip": data.get("src_ip", ""),
                    "dest_ip": data.get("dest_ip", ""),
                    "proto": data.get("proto", ""),
                    "details": alert,
                    "confidence": get_confidence_level(alert)
                }
    except json.JSONDecodeError:
        pass
    return None

def should_notify(key):
    now = datetime.now()
    last = last_alert_times.get(key)
    if not last or (now - last).total_seconds() > cooldown_seconds:
        last_alert_times[key] = now
        return True
    return False

def send_summary():
    if not suppressed_alerts:
        return
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
    details = "\n".join(f"- {sig}: {count} times" for sig, count in suppressed_alerts.items())
    send_alert_to_mattermost("Suricata", {
        "timestamp": now_str,
        "signature": "Summary",
        "severity": 3,
        "src_ip": "-",
        "dest_ip": "-",
        "proto": "-",
        "details": f"📃 **[Suricata Summary - {now_str}]**\n\n{details}",
        "confidence": "Low"  # ← 明示的に設定
    })
    print("🖒 Summary sent.")
    suppressed_alerts.clear()

def main():
    global last_summary_time
    print(f"🚀 Monitoring: {notice.SURICATA_EVE_JSON_PATH}")
    with open(notice.SURICATA_EVE_JSON_PATH, "r") as f:
        for line in follow(f):
            alert_data = parse_alert(line)
            if alert_data:
                sig = alert_data["signature"]
                key = f"{sig}:{alert_data['src_ip']}"
                conf = alert_data.get("confidence", "Unknown")
                emoji = get_category_emoji(sig)

                if "nmap" in sig.lower():
                    if should_notify(key):
                        send_alert_to_mattermost("Suricata", {
                            "timestamp": alert_data["timestamp"],
                            "signature": "⚠️ 偵察行為（Nmap）を検知",
                            "severity": 1,
                            "src_ip": alert_data["src_ip"],
                            "dest_ip": alert_data["dest_ip"],
                            "proto": alert_data["proto"],
                            "details": "この通信は偵察行為と判定されました。即時対応を推奨します。",
                            "confidence": "High"
                        })
                        print(f"🚨 Notify Nmap once: {sig}")
                    else:
                        suppressed_alerts[sig] += 1
                        print(f"⏸ Suppressed: {key}")
                    continue

                if should_notify(key):
                    print(f"✅ Notify: {sig} (Confidence: {conf})")
                    send_alert_to_mattermost("Suricata", alert_data)
                else:
                    suppressed_alerts[sig] += 1
                    print(f"⏸ Suppressed: {key}")

            now = time.time()
            if now - last_summary_time > summary_interval:
                print("🕒 Summary条件成立、送信開始")
                send_summary()
                last_summary_time = now

if __name__ == "__main__":
    main()
