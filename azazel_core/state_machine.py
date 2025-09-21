"""Light-weight state machine driving Azazel defensive posture changes."""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Callable, Dict, List, Optional


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
    """Simple but testable state machine implementation."""

    initial_state: State
    transitions: List[Transition] = field(default_factory=list)
    current_state: State = field(init=False)

    def __post_init__(self) -> None:
        self.current_state = self.initial_state
        self._transition_map: Dict[str, List[Transition]] = {}
        for transition in self.transitions:
            self.add_transition(transition)

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
                if transition.action:
                    transition.action(previous, self.current_state, event)
                return self.current_state
        return self.current_state

    def reset(self) -> None:
        """Reset the state machine to its initial state."""

        self.current_state = self.initial_state

    def summary(self) -> Dict[str, str]:
        """Return a serializable summary of the state machine."""

        return {
            "state": self.current_state.name,
            "description": self.current_state.description,
        }
