#!/usr/bin/env python3
# coding: utf-8
"""
Unified Security Monitor
------------------------
* Watches **Suricata**'s ``eve.json`` and **OpenCanary**'s JSON log simultaneously.
* Converts both event formats into a **common schema** and ships alerts to
  Mattermost via ``utils.mattermost.send_alert_to_mattermost``.
* Performs **duplicate‑suppression**, **periodic summary**, and – when an
  SSH/Nmap style reconnaissance is spotted – dynamically **diverts** the
  attacker to your OpenCanary honeypot via ``utils.delay_action.divert_to_opencanary``.

This file *replaces* the old ``run_all.py``, ``main_suricata.py`` and
``main_opencanary.py`` runtime wrappers.  You can still keep those around for
unit‑testing each parser in isolation, but in production just run::

    $ python3 mattermost_notifier/unified_monitor.py

"""
from __future__ import annotations

import json
import logging
import threading
import time
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Callable, Dict, Optional

from config import notice
from utils.delay_action import divert_to_opencanary
from utils.mattermost import send_alert_to_mattermost

# --- parser functions ------------------------------------------------------
#   * We reuse the "library‑quality" parsing logic sitting in each module.
#   * The functions **do not** launch the individual monitors – they only
#     convert one log line into a Python dict we can further normalise.
# ----------------------------------------------------------------------------
from main_suricata import parse_alert as parse_suricata  # type: ignore
from mattermost_notifier.experimental.opencanary_parser import parse_oc_line as parse_opencanary

# ---------------------------------------------------------------------------
# Settings & shared state
# ---------------------------------------------------------------------------
SRC_FILES: Dict[str, Path] = {
    "Suricata": Path(notice.SURICATA_EVE_JSON_PATH),
    "OpenCanary": Path(notice.OPENCANARY_LOG_PATH),
}

_SUPPRESS_SEC = 60          # 1分間は同一キーを抑制
_SUMMARY_INT = 60           # 1分毎にサマリ送信

_last_alert: Dict[str, datetime] = {}
_suppressed: defaultdict[str, int] = defaultdict(int)
_last_summary_ts = time.time()
_LOCK = threading.Lock()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)

# ---------------------------------------------------------------------------
# Utility helpers
# ---------------------------------------------------------------------------

def _tail_f(path: Path):
    """Yield new lines like *tail -F* (survive log rotation)."""
    offset = 0
    while True:
        if not path.exists():
            time.sleep(1)
            continue
        with path.open("r", errors="ignore") as fp:
            fp.seek(offset)
            for line in fp:
                yield line.rstrip("\n")
            offset = fp.tell()
        time.sleep(0.5)


def _normalise(event: dict, source: str) -> Optional[dict]:
    """Make both Suricata and OpenCanary events look the same downstream."""
    if not event:
        return None

    return {
        "timestamp": event.get("timestamp", datetime.utcnow().isoformat()),
        "signature": event.get("signature", "Unknown"),
        "severity": int(event.get("severity", 3)),
        "src_ip": event.get("src_ip", "-"),
        "dest_ip": event.get("dest_ip", "-"),
        "dest_port": event.get("dest_port"),
        "proto": event.get("proto", "-"),
        "details": event.get("details", ""),
        "confidence": event.get("confidence", "Unknown"),
        "source": source,
    }


def _should_notify(key: str) -> bool:
    """Return *True* if we may send a fresh alert; otherwise store suppress."""
    now = datetime.utcnow()
    with _LOCK:
        last = _last_alert.get(key)
        if not last or (now - last).total_seconds() > _SUPPRESS_SEC:
            _last_alert[key] = now
            return True
        _suppressed[key] += 1
        return False


def _maybe_send_summary():
    """Every minute post a summary of suppressed alerts (if any)."""
    global _last_summary_ts
    if time.time() - _last_summary_ts < _SUMMARY_INT:
        return

    with _LOCK:
        if not _suppressed:
            _last_summary_ts = time.time()
            return

        lines = [f"- {sig}: {cnt} times" for sig, cnt in _suppressed.items()]
        send_alert_to_mattermost(
            "Unified",
            {
                "timestamp": datetime.utcnow().strftime("%Y-%m-%d %H:%M"),
                "signature": "Summary",
                "severity": 3,
                "src_ip": "-",
                "dest_ip": "-",
                "proto": "-",
                "details": "📦 **[Unified Summary]**\n" + "\n".join(lines),
                "confidence": "Low",
            },
        )
        _suppressed.clear()
        _last_summary_ts = time.time()

# ---------------------------------------------------------------------------
# Worker per log source
# ---------------------------------------------------------------------------

def _monitor(source: str, parser: Callable[[str], Optional[dict]]):
    filepath = SRC_FILES[source]
    logging.info(f"🚀 Monitoring {source}: {filepath}")

    for line in _tail_f(filepath):
        try:
            raw_evt = parser(line)
        except Exception:
            # Malformed line → skip
            continue

        alert = _normalise(raw_evt, source)
        if not alert:
            continue

        key = f"{alert['signature']}:{alert['src_ip']}:{source}"
        sig_lower = alert["signature"].lower()

        # === delay/divert trigger (SSH & Nmap on interesting ports) =========
        if ("ssh" in sig_lower or "nmap" in sig_lower):
            if _should_notify(key):
                send_alert_to_mattermost(source, alert)
                # Try DNAT – missing port defaults to 22.
                try:
                    divert_to_opencanary(
                        alert["src_ip"],
                        alert.get("dest_port", 22),
                    )
                except Exception as e:
                    logging.warning(f"divert_to_opencanary failed: {e}")
            _maybe_send_summary()
            continue

        # === regular notification ==========================================
        if _should_notify(key):
            send_alert_to_mattermost(source, alert)

        _maybe_send_summary()

# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------

def main():
    threads = [
        threading.Thread(target=_monitor, args=("Suricata", parse_suricata), daemon=True),
        threading.Thread(target=_monitor, args=("OpenCanary", parse_opencanary), daemon=True),
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
