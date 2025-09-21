"""Pydantic-free lightweight schemas for API responses."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict


@dataclass
class HealthResponse:
    status: str
    version: str

    def as_dict(self) -> Dict[str, str]:
        return {"status": self.status, "version": self.version}
