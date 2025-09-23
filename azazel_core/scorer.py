"""Threat scoring utilities for Azazel."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from .state_machine import Event


@dataclass
class ScoreEvaluator:
    """Aggregate scores from multiple events."""

    baseline: int = 0

    def evaluate(self, events: Iterable[Event]) -> int:
        """Compute a cumulative severity score."""

        score = self.baseline
        for event in events:
            score += max(event.severity, 0)
        return score

    def classify(self, score: int) -> str:
        """Return a textual classification for a score."""

        if score >= 80:
            return "critical"
        if score >= 50:
            return "elevated"
        if score >= 20:
            return "guarded"
        return "normal"
