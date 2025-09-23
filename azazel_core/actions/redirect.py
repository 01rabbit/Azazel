"""Traffic redirection action."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from .base import Action, ActionResult


@dataclass
class RedirectAction(Action):
    """Redirect hostile traffic to the canary network."""

    target_host: str
    name: str = "redirect"

    def plan(self, target: str) -> Iterable[ActionResult]:
        yield ActionResult(
            command="nft add rule",
            parameters={
                "chain": "azazel_redirect",
                "match": target,
                "redirect": self.target_host,
            },
        )
