import requests
import json
from config import notice
from datetime import datetime

def severity_label(sev):
    return {
        1: "🟥",
        2: "🟧",
        3: "🟩"
    }.get(int(sev), "⬜")

def confidence_icon(confidence):
    return {
        "High": "🔥",
        "Medium": "⚠️",
        "Low": "💡"
    }.get(confidence, "❔")

def send_alert_to_mattermost(source, alert_data):
    """
    source: 'Suricata' または 'OpenCanary' など
    alert_data: dict with keys:
        - timestamp
        - signature
        - severity
        - src_ip
        - dest_ip
        - proto
        - details (optional)
        - confidence (optional)
    """
    label = severity_label(alert_data["severity"])
    confidence = alert_data.get("confidence", "Unknown")
    icon = confidence_icon(confidence)

    msg = (
        f"**{label} [{source} Alert]**\n"
        f"{icon} 🔐 信頼度: {confidence}\n"
        f"Time: {alert_data['timestamp']}\n"
        f"Signature: {alert_data['signature']}\n"
        f"Severity: {alert_data['severity']}\n"
        f"Source: {alert_data['src_ip']}\n"
        f"Destination: {alert_data['dest_ip']}\n"
        f"Protocol: {alert_data['proto']}\n"
    )

    if alert_data.get("details"):
        if isinstance(alert_data["details"], dict):
            msg += f"Details: `{json.dumps(alert_data['details'])}`\n"
        else:
            msg += f"Details: {alert_data['details']}\n"

    # 🚨 信頼度が High のときにだけ @all 通知を加える
    if confidence == "High":
        msg = "@all\n\n" + msg

    requests.post(notice.MATTERMOST_WEBHOOK_URL, json={"text": msg})
