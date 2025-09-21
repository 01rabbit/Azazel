"""Render QoS classifier results to actionable plans."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List

from ..actions import ActionResult


@dataclass
class QoSPlan:
    """Container for actions derived from QoS policy."""

    commands: List[ActionResult]

    @classmethod
    def from_matches(cls, matches: Iterable[str]) -> "QoSPlan":
        commands: List[ActionResult] = []
        for match in matches:
            commands.append(
                ActionResult(
                    command="tc class add",
                    parameters={"class": match},
                )
            )
        return cls(commands=commands)

    def as_dict(self) -> Dict[str, List[Dict[str, str]]]:
        return {
            "commands": [
                {"command": result.command, **result.parameters}
                for result in self.commands
            ]
        }
