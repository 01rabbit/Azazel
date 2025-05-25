import os
import sys
import json
import time
import logging

# 設定・通知系は外部ファイル利用を想定
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'config'))
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'utils'))

from config import notice
from utils.mattermost import send_alert_to_mattermost

LOG_FILE = notice.OPEN_CANARY_LOG  # /opt/azazel/logs/opencanary.log など
SCORE_THRESHOLD = notice.OPEN_CANARY_SCORE_THRESHOLD  # 必要なら

def parse_opencanary_log(line):
    try:
        entry = json.loads(line)
        # ここで更にフィルタリング・抽出処理
        return entry
    except Exception as e:
        logging.error(f"Failed to parse OpenCanary log line: {e}")
        return None

def analyze_opencanary_event(event):
    """攻撃的なイベントかどうかの判定・通知発報等"""
    # サンプル条件：SSHアクセスが複数回など
    if event.get("logtype") == 4000:  # 例: SSH probe
        msg = f"🐍 OpenCanary: SSH probe detected from {event.get('src_host')}"
        send_alert_to_mattermost("OpenCanary", {
            "timestamp": event.get("timestamp"),
            "signature": "SSH Probe",
            "severity": 3,
            "src_ip": event.get("src_host"),
            "dest_ip": event.get("dst_host"),
            "proto": "tcp",
            "details": msg,
            "confidence": "Medium"
        })
        logging.info(msg)
        # 必要に応じてアクション実施（遅滞/遮断など）

def watch_opencanary_log():
    """OpenCanaryログのリアルタイム監視・通知"""
    logging.info(f"Monitoring OpenCanary log: {LOG_FILE}")
    with open(LOG_FILE, "r") as f:
        # ファイル末尾監視（tail -f的）
        f.seek(0, 2)
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.5)
                continue
            event = parse_opencanary_log(line)
            if event:
                analyze_opencanary_event(event)

if __name__ == "__main__":
    watch_opencanary_log()