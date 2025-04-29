#!/usr/bin/env python3
"""
 unified_monitor.py
  Suricata と OpenCanary を同時監視して Mattermost に通知し、
  必要に応じて DNAT 遅滞行動を発動するワンプロセス版
"""
import json, threading, time, logging
from collections import defaultdict
from datetime import datetime
from pathlib import Path

from config import notice
from mattermost_notifier.experimental.opencanary_parser import parse_oc_line   as parse_opencanary
from main_suricata            import parse_alert    as parse_suricata
from utils.delay_action       import divert_to_opencanary, OPENCANARY_IP
from utils.mattermost         import send_alert_to_mattermost

# ────────────────────────────────────────────────────────────
SRC_FILES = {
    "Suricata"   : Path(notice.SURICATA_EVE_JSON_PATH),
    "OpenCanary" : Path(notice.OPENCANARY_LOG_PATH),
}

_SUPPRESS_SEC   = 60
_SUMMARY_INT    = 60
_last_alert     = {}
_suppressed     = defaultdict(int)
_last_summary_ts = time.time()
_lock = threading.Lock()

# ────────────────────────────────────────────────────────────
def follow(fp: Path, skip_existing=True):
    """
    tail -F 相当。初回はファイル末尾から読み始める。
    ログがローテーションされたら自動で先頭に戻る。
    """
    pos = None
    while True:
        if not fp.exists():
            time.sleep(1)
            continue

        size = fp.stat().st_size
        with fp.open("r") as f:
            # 初回：既存行を飛ばす
            if pos is None:
                if skip_existing:
                    f.seek(0, 2)          # = seek(size)
                pos = f.tell()

            # ローテーションでサイズ縮小 → 先頭へ
            if size < pos:
                pos = 0
            f.seek(pos)

            for line in f:
                yield line.rstrip("\n")
            pos = f.tell()

        time.sleep(0.5)

# ────────────────────────────────────────────────────────────
def normalize(event: dict, source: str) -> dict | None:
    """各パーサーの出力を共通フォーマットに整形"""
    if not event:
        return None
    return {
        "timestamp"  : event.get("timestamp", datetime.utcnow().isoformat()),
        "signature"  : event.get("signature", "Unknown"),
        "severity"   : event.get("severity", 3),
        "src_ip"     : event.get("src_ip", "-"),
        "dest_ip"    : event.get("dest_ip", "-"),
        "proto"      : event.get("proto", "-"),
        "details"    : event.get("details", ""),
        "confidence" : event.get("confidence", "Unknown"),
        "dest_port"  : event.get("dest_port", "-"),
        "source"     : source,
    }

# ────────────────────────────────────────────────────────────
def should_notify(key: str) -> bool:
    now = datetime.utcnow()
    with _lock:
        last = _last_alert.get(key)
        if not last or (now - last).total_seconds() > _SUPPRESS_SEC:
            _last_alert[key] = now
            return True
        _suppressed[key] += 1
        return False

def maybe_send_summary():
    global _last_summary_ts
    now = time.time()
    if now - _last_summary_ts < _SUMMARY_INT:
        return

    with _lock:
        if not _suppressed:
            _last_summary_ts = now
            return

        lines = [f"- {sig}: {cnt} times" for sig, cnt in _suppressed.items()]
        send_alert_to_mattermost("Summary", {
            "timestamp" : datetime.utcnow().strftime("%Y-%m-%d %H:%M"),
            "signature" : "Summary",
            "severity"  : 3,
            "src_ip"    : "-",
            "dest_ip"   : "-",
            "proto"     : "-",
            "details"   : "📦 **[Unified Summary]**\n" + "\n".join(lines),
            "confidence": "Low"
        })
        _suppressed.clear()
        _last_summary_ts = now

# ────────────────────────────────────────────────────────────
def monitor_worker(source: str, parser):
    fp = SRC_FILES[source]
    logging.info(f"🚀 Monitoring {source}: {fp}")
    for line in follow(fp):
        try:
            event = parser(line)
        except Exception:
            continue

        alert = normalize(event, source)
        if not alert:
            continue

        key = f"{alert['signature']}:{alert['src_ip']}:{source}"

        # ── 遅滞行動トリガ（SSH, nmap 等） ──────────────────
        if ("ssh" in alert["signature"].lower()) or ("nmap" in alert["signature"].lower()):
            if should_notify(key):
                send_alert_to_mattermost(source, alert)

                try:
                    divert_to_opencanary(alert["src_ip"])
                    # ★ DNAT 実施を Mattermost にも通知
                    send_alert_to_mattermost("Unified", {
                        "timestamp" : datetime.utcnow().isoformat(),
                        "signature" : "🛡️ 遅滞行動発動（DNAT）",
                        "severity"  : 2,
                        "src_ip"    : alert["src_ip"],
                        "dest_ip"   : f"{OPENCANARY_IP}:{alert['dest_port']}",
                        "proto"     : alert["proto"],
                        "details"   : "攻撃元の通信を OpenCanary へ転送しました。",
                        "confidence": "High"
                    })
                    logging.info(f"[遅滞行動] {alert['src_ip']} -> {OPENCANARY_IP}:{alert['dest_port']}")
                except Exception as e:
                    logging.error(f"[遅滞行動エラー] {e}")
            maybe_send_summary()
            continue

        # ── 通常通知 ────────────────────────────────
        if should_notify(key):
            send_alert_to_mattermost(source, alert)

        maybe_send_summary()

# ────────────────────────────────────────────────────────────
def main():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s"
    )
    threads = [
        threading.Thread(target=monitor_worker, args=("Suricata",   parse_suricata),   daemon=True),
        threading.Thread(target=monitor_worker, args=("OpenCanary", parse_opencanary), daemon=True),
    ]
    for t in threads:
        t.start()

    try:
        while True:
            time.sleep(5)
    except KeyboardInterrupt:
        logging.info("✋ Stopping unified monitor ...")

if __name__ == "__main__":
    main()
