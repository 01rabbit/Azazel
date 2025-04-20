import time
import json
import os
import requests
from datetime import datetime, timedelta
from collections import defaultdict
from config import notice

FILTER_SIG_CATEGORY = [
    "Attack Response", "DNS", "DOS", "Exploit", "FTP", 
    "ICMP", "IMAP", "Malware", "NETBIOS", "Phishing", 
    "POP3", "RPC", "SCAN", "Shellcode", "SMTP", "SNMP", 
    "SQL", "TELNET", "TFTP", "Web Client", "Web Server", 
    "Web Specific Apps", "WORM"
]

# 重複通知制御
last_alert_times = {}
cooldown_seconds = 60  # 同一シグネチャの通知間隔

# 集約用バッファ
suppressed_alerts = defaultdict(int)
last_summary_time = time.time()
summary_interval = 60  # 秒

def follow(file):
    file.seek(0, os.SEEK_END)
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
                    "severity": alert.get("severity", ""),
                    "src_ip": data.get("src_ip", ""),
                    "dest_ip": data.get("dest_ip", ""),
                    "proto": data.get("proto", "")
                }
    except json.JSONDecodeError:
        pass
    return None

def should_notify(signature):
    now = datetime.now()
    last = last_alert_times.get(signature)
    if not last or (now - last).total_seconds() > cooldown_seconds:
        last_alert_times[signature] = now
        return True
    return False

def severity_label(severity):
    return {
        "1": "🟥",
        "2": "🟧",
        "3": "🟩"
    }.get(str(severity), "⬜")

def send_mattermost(alert_data):
    label = severity_label(alert_data["severity"])
    msg = (
        f"**{label} [Suricata Alert]**\n"
        f"Time: {alert_data['timestamp']}\n"
        f"Signature: {alert_data['signature']}\n"
        f"Severity: {alert_data['severity']}\n"
        f"Source: {alert_data['src_ip']}\n"
        f"Destination: {alert_data['dest_ip']}\n"
        f"Protocol: {alert_data['proto']}"
    )

    # Severityが1のときのみ @all を付ける
    if str(alert_data["severity"]) == "1":
        msg = "@all\n\n" + msg

    requests.post(notice.MATTERMOST_WEBHOOK_URL, json={"text": msg})

def send_summary():
    if not suppressed_alerts:
        return
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
    msg_lines = [f"**📦 [Suricata Alert Summary - {now_str}]**", "", "🔁 Repeated (suppressed) alerts:"]
    for signature, count in suppressed_alerts.items():
        msg_lines.append(f"- {signature}: {count} times")
    message = "\n".join(msg_lines)
    requests.post(notice.MATTERMOST_WEBHOOK_URL, json={"text": message})
    suppressed_alerts.clear()

def test_mattermost():
    msg = "**[TEST ALERT]**\nThis is a test message from the Suricata notifier script."
    response = requests.post(notice.MATTERMOST_WEBHOOK_URL, json={"text": msg})
    print(f"Test message sent. Response: {response.status_code}")
    return response

def main():
    global last_summary_time
    with open(notice.EVE_JSON_PATH, "r") as f:
        for line in follow(f):
            alert_data = parse_alert(line)
            if alert_data:
                signature = alert_data["signature"]
                if should_notify(signature):
                    print(f"Detected alert: {signature}")
                    send_mattermost(alert_data)
                else:
                    suppressed_alerts[signature] += 1

            # 一定時間ごとにサマリーを送信
            now = time.time()
            if now - last_summary_time > summary_interval:
                send_summary()
                last_summary_time = now

if __name__ == "__main__":
    # test_mattermost()
    main()
