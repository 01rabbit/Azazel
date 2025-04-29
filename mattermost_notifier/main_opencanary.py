#!/usr/bin/env python3
"""
OpenCanary の JSON ログを監視し Mattermost へ通知
"""
import re, json, time, logging, sys
from datetime import datetime
from collections import defaultdict
from pathlib import Path

from config import notice
from utils.mattermost import send_alert_to_mattermost

LOG_FILE          = Path(notice.OPENCANARY_LOG_PATH)
SUPPRESS_MODE     = notice.SUPPRESS_KEY_MODE
cooldown_seconds  = 60
summary_interval  = 60

last_alert_times  = {}
suppressed_alerts = defaultdict(int)
last_summary_time = time.time()

LOGTYPE_SENSOR_MAP = {
    2000:"ftp",2001:"telnet",2002:"http",3001:"http",
    4000:"ssh-session",4001:"ssh-probe",4002:"ssh-login",
    5001:"mysql",5002:"rdp",
}
SENSOR_SEVERITY = {
    "ssh-login":1,"ssh-session":1,"ssh-probe":1,
    "telnet":1,"http":2,"ftp":2,"mysql":2,"rdp":3,"smb":3
}

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
        print("\n✋ OpenCanary monitor interrupted, exiting...")
        sys.exit(0)

# ------------------------------------------------------------------
def generate_key(alert)->str:
    user   = alert["details"].get("USERNAME","-")
    session= alert["details"].get("SESSION","-")
    sig,ip = alert["signature"],alert["src_ip"]
    if   SUPPRESS_MODE=="signature"                    : return sig
    elif SUPPRESS_MODE=="signature_ip"                 : return f"{sig}:{ip}"
    elif SUPPRESS_MODE=="signature_ip_user"            : return f"{sig}:{ip}:{user}"
    elif SUPPRESS_MODE=="signature_ip_user_session"    : return f"{sig}:{ip}:{user}:{session}"
    else: return f"{sig}:{ip}"

def should_notify(key):
    now=datetime.now(notice.TZ)
    last=last_alert_times.get(key)
    if not last or (now-last).total_seconds()>cooldown_seconds:
        last_alert_times[key]=now; return True
    return False

def confidence(alert):
    sig=alert["signature"].lower()
    details=str(alert["details"]).lower()
    if "ssh-login" in sig           : return "High"
    if "ftp" in sig and "anonymous" in details: return "Low"
    if "ftp" in sig                 : return "Medium"
    if any(x in sig for x in ("mysql","rdp","telnet")): return "Medium"
    if any(x in sig for x in ("http","smb"))   : return "Low"
    if "ssh-session" in sig         : return "Medium"
    return "Low"

def parse_oc_line(line:str):
    m=re.search(r'\{.*\}$',line)
    if not m: return None
    data=json.loads(m.group())
    sensor = data.get("sensor") or LOGTYPE_SENSOR_MAP.get(data.get("logtype"))
    if not sensor: return None
    sev    = SENSOR_SEVERITY.get(sensor,3)
    alert  = {
        "timestamp":data.get("local_time") or data.get("utc_time"),
        "signature":f"OpenCanary {sensor} access to port {data.get('dst_port','')}",
        "severity" :sev,
        "src_ip"   :data.get("src_host"),
        "dest_ip"  :data.get("dst_host") or "OpenCanary",
        "proto"    :"TCP",
        "details"  :data.get("logdata",{})
    }
    alert["confidence"]=confidence(alert)
    return alert

# ------------------------------------------------------------------
def send_summary():
    if not suppressed_alerts: return
    now=datetime.now(notice.TZ).strftime("%Y-%m-%d %H:%M")
    body="\n".join(f"- `{sig}`: {cnt} times" for sig,cnt in suppressed_alerts.items())
    send_alert_to_mattermost("OpenCanary",{
        "timestamp":now,"signature":"Summary","severity":3,
        "src_ip":"-","dest_ip":"-","proto":"-",
        "details":f"📦 **[OpenCanary Summary - {now}]**\n\n{body}",
        "confidence":"Low"
    })
    suppressed_alerts.clear()

# ------------------------------------------------------------------
def main():
    global last_summary_time
    logging.basicConfig(level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s")
    logging.info(f"🚀 Monitoring OpenCanary: {LOG_FILE}")

    for line in follow(LOG_FILE):
        alert=parse_oc_line(line)
        if not alert: continue

        key=generate_key(alert)
        if should_notify(key):
            send_alert_to_mattermost("OpenCanary",alert)
            logging.info(f"Notify: {alert['signature']}")
        else:
            suppressed_alerts[alert["signature"]]+=1

        if time.time()-last_summary_time>=summary_interval:
            send_summary(); last_summary_time=time.time()

if __name__=="__main__":
    main()
