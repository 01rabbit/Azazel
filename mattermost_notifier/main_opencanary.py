import time
import json
import re
from datetime import datetime
from collections import defaultdict
from config import notice
from utils.mattermost import send_alert_to_mattermost

LOG_PATH = notice.OPENCANARY_LOG_PATH
SUPPRESS_MODE = notice.SUPPRESS_KEY_MODE
cooldown_seconds = 60
summary_interval = 60
last_alert_times = {}
suppressed_alerts = defaultdict(int)
last_summary_time = time.time()

LOGTYPE_SENSOR_MAP = {
    2000: "ftp", 2001: "telnet", 2002: "http", 3001: "http",
    4000: "ssh-session", 4001: "ssh-probe", 4002: "ssh-login",
    5001: "mysql", 5002: "rdp"
}

SENSOR_SEVERITY = {
    "ssh-login": 1, "ssh-session": 1, "ssh-probe": 1,
    "telnet": 1, "http": 2, "ftp": 2, "mysql": 2,
    "rdp": 3, "smb": 3
}

def follow(file):
    file.seek(0, 2)
    while True:
        line = file.readline()
        if not line:
            time.sleep(1)
            continue
        yield line

def generate_suppress_key(alert, mode):
    sig = alert["signature"]
    ip = alert["src_ip"]
    user = alert.get("details", {}).get("USERNAME", "-")
    session = alert.get("details", {}).get("SESSION", "-")

    if mode == "signature":
        return sig
    elif mode == "signature_ip":
        return f"{sig}:{ip}"
    elif mode == "signature_ip_user":
        return f"{sig}:{ip}:{user}"
    elif mode == "signature_ip_user_session":
        return f"{sig}:{ip}:{user}:{session}"
    else:
        return f"{sig}:{ip}"

def should_notify(key):
    now = datetime.now()
    last = last_alert_times.get(key)
    if not last or (now - last).total_seconds() > cooldown_seconds:
        last_alert_times[key] = now
        return True
    return False

def evaluate_confidence(alert):
    sig = alert["signature"].lower()
    details = str(alert.get("details", "")).lower()

    if "ssh-login" in sig:
        return "High"
    elif "ftp" in sig and "anonymous" in details:
        return "Low"
    elif "ftp" in sig:
        return "Medium"
    elif "mysql" in sig or "rdp" in sig or "telnet" in sig:
        return "Medium"
    elif "http" in sig or "smb" in sig:
        return "Low"
    elif "ssh-session" in sig:
        return "Medium"
    else:
        return "Low"

def parse_alert(line):
    try:
        match = re.search(r'\{.*\}$', line)
        if not match:
            return None
        data = json.loads(match.group())

        sensor = data.get("sensor") or LOGTYPE_SENSOR_MAP.get(data.get("logtype"), "unknown")
        severity = SENSOR_SEVERITY.get(sensor, 3)
        logdata = data.get("logdata", {})

        alert = {
            "timestamp": data.get("local_time", ""),
            "signature": f"OpenCanary {sensor} access to port {data.get('dst_port', '')}",
            "severity": severity,
            "src_ip": data.get("src_host", "unknown"),
            "dest_ip": data.get("dst_host", "unknown"),
            "proto": "TCP",
            "details": logdata
        }

        # ⬇ 信頼度を追加しておく（通知関数側で使う）
        alert["confidence"] = evaluate_confidence(alert)

        return alert
    except Exception as e:
        print("🔥 parse_alert error:", e)
        return None

def send_summary():
    if not suppressed_alerts:
        return
    now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
    summary_lines = [f"📦 **[OpenCanary Summary - {now_str}]**", ""]
    for signature, count in suppressed_alerts.items():
        summary_lines.append(f"- `{signature}`: {count} times")

    message = "\n".join(summary_lines)

    send_alert_to_mattermost("OpenCanary", {
        "timestamp": now_str,
        "signature": "Summary",
        "severity": 3,
        "src_ip": "-",
        "dest_ip": "-",
        "proto": "-",
        "details": message,
        "confidence": "Low"  # Summaryは全てLow扱いでよい
    })

    print("📦 Summary sent.")
    suppressed_alerts.clear()

def main():
    global last_summary_time
    print(f"🚀 Monitoring: {LOG_PATH}")
    with open(LOG_PATH, "r") as f:
        for line in follow(f):
            alert = parse_alert(line)
            if alert:
                key = generate_suppress_key(alert, SUPPRESS_MODE)
                if should_notify(key):
                    print(f"✅ Notify: {alert['signature']} (Confidence: {alert['confidence']})")
                    send_alert_to_mattermost("OpenCanary", alert)
                else:
                    suppressed_alerts[alert["signature"]] += 1
                    print(f"⏸ Suppressed: {key}")

            if time.time() - last_summary_time > summary_interval:
                send_summary()
                last_summary_time = time.time()

if __name__ == "__main__":
    main()
