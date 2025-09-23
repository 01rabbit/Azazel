"""Light-weight state machine driving Azazel defensive posture changes."""
from __future__ import annotations

import time
from collections import deque
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable, Deque, Dict, List, Optional

import yaml


CONFIG_PATH = Path(__file__).resolve().parents[1] / "configs" / "azazel.yaml"


@dataclass(frozen=True)
class State:
    """Represents a named state of the defensive system."""

    name: str
    description: str = ""


@dataclass(frozen=True)
class Event:
    """An external event that may trigger a transition."""

    name: str
    severity: int = 0


@dataclass
class Transition:
    """Transition from one state to another triggered by an event."""

    source: State
    target: State
    condition: Callable[[Event], bool]
    action: Optional[Callable[[State, State, Event], None]] = None


@dataclass
class StateMachine:
    """Mode-aware state machine with YAML-backed presets."""

    initial_state: State
    transitions: List[Transition] = field(default_factory=list)
    config_path: str | Path | None = None
    window_size: int = 5
    clock: Callable[[], float] = field(default=time.monotonic, repr=False)
    current_state: State = field(init=False)

    def __post_init__(self) -> None:
        self.current_state = self.initial_state
        self._transition_map: Dict[str, List[Transition]] = {}
        for transition in self.transitions:
            self.add_transition(transition)
        self._config_cache: Dict[str, Any] | None = None
        self._score_window: Deque[int] = deque(maxlen=max(self.window_size, 1))
        self._unlock_until: Dict[str, float] = {}

    # ------------------------------------------------------------------
    # Transition helpers
    # ------------------------------------------------------------------
    def add_transition(self, transition: Transition) -> None:
        """Register a new transition."""

        bucket = self._transition_map.setdefault(transition.source.name, [])
        bucket.append(transition)

    def dispatch(self, event: Event) -> State:
        """Process an event and advance the state machine if applicable."""

        for transition in self._transition_map.get(self.current_state.name, []):
            if transition.condition(event):
                previous = self.current_state
                self.current_state = transition.target
                self._handle_transition(previous, self.current_state)
                if transition.action:
                    transition.action(previous, self.current_state, event)
                return self.current_state
        return self.current_state

    def reset(self) -> None:
        """Reset the state machine to its initial state."""

        self.current_state = self.initial_state
        self._score_window.clear()
        self._unlock_until.clear()

    def summary(self) -> Dict[str, str]:
        """Return a serializable summary of the state machine."""

        return {
            "state": self.current_state.name,
            "description": self.current_state.description,
        }

    # ------------------------------------------------------------------
    # Configuration helpers
    # ------------------------------------------------------------------
    def _resolve_config_path(self) -> Path:
        if self.config_path is not None:
            return Path(self.config_path)
        return CONFIG_PATH

    def _load_config(self) -> Dict[str, Any]:
        if self._config_cache is None:
            path = self._resolve_config_path()
            data = yaml.safe_load(path.read_text())
            if not isinstance(data, dict):
                raise ValueError("Configuration root must be a mapping")
            self._config_cache = data
        return self._config_cache

    def reload_config(self) -> None:
        """Force re-reading of the YAML configuration."""

        self._config_cache = None

    def get_thresholds(self) -> Dict[str, Any]:
        """Return shield/lockdown thresholds and unlock windows."""

        config = self._load_config()
        thresholds = config.get("thresholds", {})
        unlock = thresholds.get("unlock_wait_secs", {})
        return {
            "t1": int(thresholds.get("t1_shield", 0) or 0),
            "t2": int(thresholds.get("t2_lockdown", 0) or 0),
            "unlock_wait_secs": {
                "shield": int(unlock.get("shield", 0) or 0),
                "portal": int(unlock.get("portal", 0) or 0),
            },
        }

    def get_actions_preset(self) -> Dict[str, Any]:
        """Return the action plan preset for the current mode."""

        config = self._load_config()
        actions = config.get("actions", {})
        preset = actions.get(self.current_state.name, {})
        shape = preset.get("shape_kbps")
        return {
            "delay_ms": int(preset.get("delay_ms", 0) or 0),
            "shape_kbps": int(shape) if shape not in (None, "", False) else None,
            "block": bool(preset.get("block", False)),
        }

    # ------------------------------------------------------------------
    # Score window evaluation
    # ------------------------------------------------------------------
    def evaluate_window(self, severity: int) -> Dict[str, Any]:
        """Append a severity score and compute moving average decisions."""

        self._score_window.append(max(int(severity), 0))
        average = sum(self._score_window) / len(self._score_window)
        thresholds = self.get_thresholds()
        desired_mode = "portal"
        if average >= thresholds["t2"]:
            desired_mode = "lockdown"
        elif average >= thresholds["t1"]:
            desired_mode = "shield"
        return {"average": average, "desired_mode": desired_mode}

    def apply_score(self, severity: int) -> Dict[str, Any]:
        """Evaluate the score window and transition to the appropriate mode."""

        evaluation = self.evaluate_window(severity)
        desired_mode = evaluation["desired_mode"]
        now = self.clock()
        target_mode = desired_mode
        if desired_mode == "portal":
            target_mode = self._target_for_portal(now)
        elif desired_mode == "shield":
            target_mode = self._target_for_shield(now)

        if target_mode != self.current_state.name:
            self.dispatch(Event(name=target_mode, severity=severity))

        evaluation.update({
            "target_mode": target_mode,
            "applied_mode": self.current_state.name,
        })
        return evaluation

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------
    def _handle_transition(self, previous: State, current: State) -> None:
        thresholds = self.get_thresholds()
        unlocks = thresholds.get("unlock_wait_secs", {})
        now = self.clock()
        if current.name == "lockdown":
            wait_shield = unlocks.get("shield", 0)
            if wait_shield:
                self._unlock_until["shield"] = now + wait_shield
        elif current.name == "shield":
            wait_portal = unlocks.get("portal", 0)
            if wait_portal:
                self._unlock_until["portal"] = now + wait_portal
            self._unlock_until.pop("shield", None)
        elif current.name == "portal":
            self._unlock_until.clear()

    def _target_for_shield(self, now: float) -> str:
        if self.current_state.name == "lockdown":
            unlock_at = self._unlock_until.get("shield", 0.0)
            if now < unlock_at:
                return "lockdown"
        return "shield"

    def _target_for_portal(self, now: float) -> str:
        if self.current_state.name == "lockdown":
            unlock_at = self._unlock_until.get("shield", 0.0)
            if now < unlock_at:
                return "lockdown"
            # Step-down path: lockdown -> shield before portal.
            return "shield"
        if self.current_state.name == "shield":
            unlock_at = self._unlock_until.get("portal", 0.0)
            if now < unlock_at:
                return "shield"
        return "portal"
