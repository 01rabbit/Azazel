import time
import json
import os
import requests
from config import notice

FILTER_SIG_CATEGORY = [
    "Attack Response", "DNS", "DOS", "Exploit", "FTP", 
    "ICMP", "IMAP", "Malware", "NETBIOS", "Phishing", 
    "POP3", "RPC", "SCAN", "Shellcode", "SMTP", "SNMP", 
    "SQL", "TELNET", "TFTP", "Web Client", "Web Server", 
    "Web Specific Apps", "WORM"
]

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

def send_mattermost(alert_data):
    msg = (
        f"**[Suricata Alert]**\n"
        f"Time: {alert_data['timestamp']}\n"
        f"Signature: {alert_data['signature']}\n"
        f"Severity: {alert_data['severity']}\n"
        f"Source: {alert_data['src_ip']}\n"
        f"Destination: {alert_data['dest_ip']}\n"
        f"Protocol: {alert_data['proto']}"
    )
    response = requests.post(notice.MATTERMOST_WEBHOOK_URL, json={"text": msg})
    return response

def test_mattermost():
    msg = "**[TEST ALERT]**\nThis is a test message from the Suricata notifier script."
    response = requests.post(notice.MATTERMOST_WEBHOOK_URL, json={"text": msg})
    print(f"Test message sent. Response: {response.status_code}")
    return response

def main():
    with open(notice.EVE_JSON_PATH, "r") as f:
        for line in follow(f):
            alert_data = parse_alert(line)
            if alert_data:
                print(f"Detected alert: {alert_data['signature']}")
                send_mattermost(alert_data)

if __name__ == "__main__":
    # 初回動作確認用にコメントアウトして使ってください
    # test_mattermost()
    main()
