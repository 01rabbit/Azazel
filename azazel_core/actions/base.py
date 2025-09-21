"""Base classes for traffic control actions."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable


@dataclass
class ActionResult:
    """Represents an idempotent command for network enforcement."""

    command: str
    parameters: Dict[str, str]


class Action:
    """Interface for all concrete actions."""

    name: str = "action"

    def plan(self, target: str) -> Iterable[ActionResult]:  # pragma: no cover - interface
        raise NotImplementedError
