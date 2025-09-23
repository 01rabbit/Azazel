"""Traffic shaping action."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from .base import Action, ActionResult


@dataclass
class ShapeAction(Action):
    """Throttle bandwidth for a target."""

    rate_kbps: int
    name: str = "shape"

    def plan(self, target: str) -> Iterable[ActionResult]:
        yield ActionResult(
            command="tc class replace",
            parameters={"target": target, "rate": f"{self.rate_kbps}kbps"},
        )
