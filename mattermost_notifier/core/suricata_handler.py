import json
from collections import deque
from config.notice import SURICATA_EVE_JSON_PATH

def get_suricata_alerts(limit=100):
    alerts = deque(maxlen=limit)
    try:
        with open(SURICATA_EVE_JSON_PATH, "r") as f:
            for line in f:
                try:
                    event = json.loads(line)
                    if event.get("event_type") == "alert":
                        alerts.append(event)
                except Exception as e:
                    print(f"JSON decode error: {e}")
    except Exception as e:
        print(f"suricata_handler.py: Error reading {SURICATA_EVE_JSON_PATH}: {e}")
    return list(alerts)[::-1]  # 新しい順にしたい場合

def get_suricata_flows(limit=100):
    flows = deque(maxlen=limit)
    try:
        with open(SURICATA_EVE_JSON_PATH, "r") as f:
            for line in f:
                try:
                    event = json.loads(line)
                    if event.get("event_type") == "flow":
                        flows.append(event)
                except Exception as e:
                    print(f"JSON decode error: {e}")
    except Exception as e:
        print(f"suricata_handler.py: Error reading {SURICATA_EVE_JSON_PATH}: {e}")
    return list(flows)[::-1]  # 新しい順にしたい場合