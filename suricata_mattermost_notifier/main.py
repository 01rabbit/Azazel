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
        "details": details
    })
    suppressed_alerts.clear()

def test_mattermost():
    send_alert_to_mattermost("Suricata", {
        "timestamp": datetime.now().isoformat(),
        "signature": "Test Alert",
        "severity": 2,
        "src_ip": "127.0.0.1",
        "dest_ip": "127.0.0.1",
        "proto": "TEST",
        "details": "This is a test message from the Suricata notifier script."
    })

def main():
    global last_summary_time
    with open(notice.EVE_JSON_PATH, "r") as f:
        for line in follow(f):
            alert_data = parse_alert(line)
            if alert_data:
                sig = alert_data["signature"]
                if should_notify(sig):
                    print(f"Detected alert: {sig}")
                    send_alert_to_mattermost("Suricata", alert_data)
                else:
                    suppressed_alerts[sig] += 1

            now = time.time()
            if now - last_summary_time > summary_interval:
                send_summary()
                last_summary_time = now

if __name__ == "__main__":
    # test_mattermost()
    main()
