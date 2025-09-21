"""Streaming helper for Suricata EVE logs."""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Generator, Iterable

import json

from ..state_machine import Event


@dataclass
class SuricataTail:
    path: Path

    def stream(self) -> Generator[Event, None, None]:
        """Yield events from an EVE JSON log."""

        for line in self._read_lines():
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue
            severity = int(record.get("alert", {}).get("severity", 0))
            yield Event(
                name=record.get("event_type", "alert"),
                severity=severity,
            )

    def _read_lines(self) -> Iterable[str]:
        return self.path.read_text().splitlines()
