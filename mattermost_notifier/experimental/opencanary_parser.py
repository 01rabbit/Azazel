import json
from datetime import datetime

LOGTYPE_MAP = {
    4001: "ssh-probe",
    4002: "ssh-login",
    4003: "ssh-session",
    5001: "http",
    6001: "postgres",
    # 必要に応じて追加
}

DEFAULT_PORT = {
    4001: 22, 4002: 22, 4003: 22,
    5001: 80,
    6001: 5432,
}

def parse_oc_line(line: str):
    """
    OpenCanary の 1 行 JSON を Suricata 風 dict に整形して返す。
    対象外行なら None を返す。
    """
    try:
        data = json.loads(line)
    except ValueError:
        return None

    logtype = data.get("logtype")
    if logtype not in LOGTYPE_MAP:
        return None        # 興味のないイベントは捨てる

    port = data.get("dst_port", -1)
    if port in (-1, None):
        port = DEFAULT_PORT.get(logtype, "?")

    return {
        "timestamp": data.get("local_time") or data.get("utc_time"),
        "signature": f"OpenCanary {LOGTYPE_MAP[logtype]} access to port {port}",
        "severity": 3,
        "src_ip":  data.get("src_host", "-"),
        "dest_ip": data.get("dst_host") or "OpenCanary",
        "dest_port": port,
        "proto":    "TCP",
        "details":  data.get("logdata", {}),
        "confidence": "Low",
    }
