"""Blocking action."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from .base import Action, ActionResult


@dataclass
class BlockAction(Action):
    """Deny traffic for a target."""

    name: str = "block"

    def plan(self, target: str) -> Iterable[ActionResult]:
        yield ActionResult(
            command="nft add element",
            parameters={"set": "blocked_hosts", "value": target},
        )
