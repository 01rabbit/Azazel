"""Simplified Mattermost webhook client."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict

import json
import urllib.request


@dataclass
class MattermostNotifier:
    webhook_url: str

    def format_payload(self, message: str, level: str = "info") -> Dict[str, Any]:
        return {
            "text": message,
            "props": {"severity": level},
        }

    def send(self, message: str, level: str = "info") -> None:
        data = json.dumps(self.format_payload(message, level)).encode()
        request = urllib.request.Request(
            self.webhook_url,
            data=data,
            headers={"Content-Type": "application/json"},
        )
        # Network operations are avoided during tests; errors bubble up.
        urllib.request.urlopen(request, timeout=5)
