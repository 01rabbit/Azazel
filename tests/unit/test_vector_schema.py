import json
from pathlib import Path

import jsonschema


SCHEMA = json.loads(Path("configs/azazel.schema.json").read_text())
EVENT_SCHEMA = SCHEMA["definitions"]["normalizedEvent"]


def normalize_event(event: dict) -> dict:
    def first_of(*keys):
        for key in keys:
            parts = key.split(".")
            cursor = event
            for part in parts:
                if isinstance(cursor, dict) and part in cursor:
                    cursor = cursor[part]
                else:
                    break
            else:
                return cursor
        return None

    def as_int(value):
        if value is None:
            return None
        try:
            return int(value)
        except (TypeError, ValueError):
            return None

    def as_str(value):
        if value is None:
            return None
        return str(value)

    normalized = {
        "ts": as_str(first_of("timestamp", "time")) or "1970-01-01T00:00:00Z",
        "node": as_str(first_of("host", "agent.hostname", "node")),
        "event": as_str(first_of("event_type", "alert.signature", "service", "message")),
        "src": {
            "ip": as_str(first_of("src_ip", "src.ip", "source.address")),
            "port": as_int(first_of("src_port", "src.port", "source.port")),
        },
        "dst": {
            "ip": as_str(first_of("dest_ip", "dest.ip", "destination.address")),
            "port": as_int(first_of("dest_port", "dest.port", "destination.port")),
        },
        "proto": as_str(first_of("proto", "protocol", "transport")),
        "sig_id": as_int(first_of("alert.signature_id", "signature_id")),
        "score": as_int(first_of("score")),
        "severity": as_str(first_of("severity", "alert.severity")),
        "actions": [as_str(item) for item in event.get("actions", []) if as_str(item) is not None],
        "mode": as_str(event.get("mode")),
        "qos_class": as_str(event.get("qos_class")),
        "evidence_ref": as_str(
            first_of("evidence_ref", "file", "logfile")
        ),
    }
    # Ensure arrays default to empty list and nested dict keys exist
    if not normalized["actions"]:
        normalized["actions"] = []
    if normalized["src"]["port"] is None:
        normalized["src"]["port"] = None
    if normalized["dst"]["port"] is None:
        normalized["dst"]["port"] = None
    return normalized


def test_suricata_event_schema():
    event = {
        "timestamp": "2024-03-14T10:00:00Z",
        "host": "sensor-1",
        "event_type": "alert",
        "src_ip": "192.0.2.5",
        "src_port": 12345,
        "dest_ip": "203.0.113.8",
        "dest_port": 80,
        "proto": "TCP",
        "score": 88,
        "mode": "shield",
        "qos_class": "medical",
        "evidence_ref": "eve.json",
        "alert": {"signature_id": 2100001, "severity": "high"},
        "actions": ["delay"],
    }
    normalized = normalize_event(event)
    jsonschema.validate(normalized, EVENT_SCHEMA)


def test_canary_event_schema():
    event = {
        "timestamp": "2024-03-14T10:01:00Z",
        "service": "ssh",
        "src_ip": "198.51.100.20",
        "username": "root",
        "logfile": "/var/log/opencanary.log",
    }
    normalized = normalize_event(event)
    jsonschema.validate(normalized, EVENT_SCHEMA)
