"""Tail OpenCanary log files."""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Generator, Iterable

import json

from ..state_machine import Event


@dataclass
class CanaryTail:
    path: Path

    def stream(self) -> Generator[Event, None, None]:
        for line in self._read_lines():
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue
            yield Event(name=record.get("logtype", "canary"), severity=10)

    def _read_lines(self) -> Iterable[str]:
        return self.path.read_text().splitlines()
