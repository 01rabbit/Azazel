"""Render QoS classifier results to actionable plans."""
from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List


CLASS_PATTERN = re.compile(
    r"^class\s+(?P<name>[A-Za-z0-9_-]+)\s+prio\s+(?P<priority>\d+)\s+share\s+(?P<share>[0-9.]+)"
)


@dataclass(frozen=True)
class HTBClass:
    """Represents a class definition from classes.htb."""

    name: str
    priority: int
    share: float


def _parse_classes(path: str | Path) -> List[HTBClass]:
    classes: List[HTBClass] = []
    for line in Path(path).read_text().splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        match = CLASS_PATTERN.match(stripped)
        if match:
            classes.append(
                HTBClass(
                    name=match.group("name"),
                    priority=int(match.group("priority")),
                    share=float(match.group("share")),
                )
            )
    if not classes:
        raise ValueError(f"No HTB classes defined in {path}")
    return classes


@dataclass
class QoSPlan:
    """Container for tc class calculations."""

    profile: str
    uplink_kbps: int
    classes: Dict[str, Dict[str, int]]

    @classmethod
    def from_profile(
        cls,
        profiles: Dict[str, Dict[str, Any]],
        profile_name: str,
        classes_path: str | Path,
    ) -> "QoSPlan":
        try:
            profile = profiles[profile_name]
        except KeyError as exc:  # pragma: no cover - defensive guard
            raise KeyError(f"Unknown profile: {profile_name}") from exc

        uplink = int(profile.get("uplink_kbps", 0) or 0)
        if uplink <= 0:
            raise ValueError(f"Profile {profile_name} must define uplink_kbps > 0")

        classes = _parse_classes(classes_path)
        plan: Dict[str, Dict[str, int]] = {}
        for entry in classes:
            rate = max(1, int(round(uplink * (entry.share / 100.0))))
            plan[entry.name] = {
                "priority": entry.priority,
                "rate_kbps": rate,
                "ceil_kbps": uplink,
            }
        return cls(profile=profile_name, uplink_kbps=uplink, classes=plan)

    def as_dict(self) -> Dict[str, Any]:
        return {
            "profile": self.profile,
            "uplink_kbps": self.uplink_kbps,
            "classes": self.classes,
        }
