"""Configuration helpers for Azazel."""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict

import yaml


@dataclass
class AzazelConfig:
    """Represents the high level configuration used by the controller."""

    raw: Dict[str, Any]

    @classmethod
    def from_file(cls, path: str | Path) -> "AzazelConfig":
        data = yaml.safe_load(Path(path).read_text())
        if not isinstance(data, dict):
            raise ValueError("Configuration root must be a mapping")
        return cls(raw=data)

    def get(self, key: str, default: Any = None) -> Any:
        return self.raw.get(key, default)

    def require(self, key: str) -> Any:
        if key not in self.raw:
            raise KeyError(f"Missing configuration key: {key}")
        return self.raw[key]
