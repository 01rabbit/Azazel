import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
import time
from config.notice import EVENTS_JSON_PATH
from analytics.correlation_engine import EventCorrelator

if __name__ == "__main__":
    INTERVAL = 60
    correlator = EventCorrelator(EVENTS_JSON_PATH)
    print(f"[main_correlation] Start monitoring: {EVENTS_JSON_PATH}")

    try:
        while True:
            correlator.process()  # ← このメソッド内で「高リスクIPへの遅滞・通知・復旧」まで完結
            time.sleep(INTERVAL)
    except KeyboardInterrupt:
        print("[main_correlation] Interrupted and exiting.")
    except Exception as e:
        print(f"[main_correlation] Error: {e}")