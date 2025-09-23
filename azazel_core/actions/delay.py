"""Traffic delay action."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from .base import Action, ActionResult


@dataclass
class DelayAction(Action):
    """Introduce latency to traffic."""

    delay_ms: int
    name: str = "delay"

    def plan(self, target: str) -> Iterable[ActionResult]:
        yield ActionResult(
            command="tc qdisc replace",
            parameters={"target": target, "delay": f"{self.delay_ms}ms"},
        )
