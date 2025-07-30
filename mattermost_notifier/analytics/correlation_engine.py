import json
import time
from collections import defaultdict
from datetime import datetime, timedelta
import os
import logging

# 設定・通知系は外部ファイル利用を想定
from config.notice import EVENTS_JSON_PATH
from config import notice
from utils.mattermost import send_alert_to_mattermost

class EventCorrelator:
    def __init__(self, events_path, score_config=None):
        self.events_path = events_path
        self.score_config = score_config or self.default_score_config()

    def default_score_config(self):
        return {
            "ET SCAN Potential SSH Scan": 3,
            "ET POLICY": 2,
            "OPENCANARY_SSH_LOGIN": 4,
            "OPENCANARY_SSH_PROBE": 2,
            "ET BRUTEFORCE": 5,
        }

    def load_events(self, since_minutes=5):
        now = datetime.now()
        events = []
        with open(self.events_path, "r") as f:
            for line in f:
                try:
                    event = json.loads(line)
                    ts_str = event.get("timestamp") or event.get("time")
                    if not ts_str:
                        continue
                    ts_str = ts_str.split('+')[0]
                    ts = datetime.fromisoformat(ts_str)
                    if now - ts < timedelta(minutes=since_minutes):
                        events.append(event)
                except Exception:
                    continue
        return events

    def correlate(self, events):
        by_ip = defaultdict(list)
        for event in events:
            ip = (
                event.get("src_ip")
                or event.get("source_ip")
                or (event.get("event", {}).get("src_ip"))
            )
            if not ip:
                continue
            by_ip[ip].append(event)

        results = []
        for ip, ip_events in by_ip.items():
            score = 0
            reasons = []
            for ev in ip_events:
                sig = ""
                if "alert" in ev and "signature" in ev["alert"]:
                    sig = ev["alert"]["signature"]
                elif "type" in ev:
                    sig = "OPENCANARY_" + ev["type"].upper()
                s = self.score_config.get(sig, 1)
                score += s
                reasons.append(sig)
            results.append({
                "src_ip": ip,
                "score": score,
                "reasons": reasons,
                "events": ip_events
            })
        return results

    def get_high_risk(self, correlated, threshold=6):
        return [x for x in correlated if x["score"] >= threshold]

    def process(self, since_minutes=5, threshold=6):
        """
        Run one correlation cycle:
        - Load recent events (default: last 5 minutes)
        - Compute correlation scores
        - Return list of high-risk entries above threshold
        """
        events = self.load_events(since_minutes)
        correlated = self.correlate(events)
        high_risk = self.get_high_risk(correlated, threshold)
        return high_risk

def notify(ip, score, reasons, events):
    msg = {
        "timestamp": datetime.now().isoformat(),
        "signature": "🚨 相関スコア高リスク検知",
        "severity": 2,
        "src_ip": ip,
        "dest_ip": ", ".join(set([e.get("dest_ip","") for e in events if e.get("dest_ip")])),
        "proto": ", ".join(set([e.get("proto","") for e in events if e.get("proto")])),
        "details": f"スコア: {score} / 要因: {', '.join(reasons)} / 関連イベント数: {len(events)}",
        "confidence": "High"
    }
    send_alert_to_mattermost("Correlation", msg)
    logging.info(f"[相関遅滞] {ip}: スコア{score}, 要因: {reasons}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    EVENTS_JSON = EVENTS_JSON_PATH
    correlator = EventCorrelator(EVENTS_JSON)

    last_run = datetime.now() - timedelta(minutes=1)
    seen_ips = set()

    while True:
        events = correlator.load_events(since_minutes=5)
        corr = correlator.correlate(events)
        high_risk = correlator.get_high_risk(corr)
        for r in high_risk:
            if r["src_ip"] not in seen_ips:
                notify(r["src_ip"], r["score"], r["reasons"], r["events"])
                seen_ips.add(r["src_ip"])
        time.sleep(60)  # 1分ごとに再チェック