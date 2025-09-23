"""Tiny CLI facade for the Azazel daemon."""
from __future__ import annotations

import argparse
from typing import Iterable

from azazel_core import AzazelConfig, ScoreEvaluator, State, StateMachine
from azazel_core.state_machine import Event, Transition

from .daemon import AzazelDaemon


def build_machine() -> StateMachine:
    portal = State(name="portal", description="Nominal operations")
    shield = State(name="shield", description="Heightened monitoring")
    lockdown = State(name="lockdown", description="Full containment mode")

    machine = StateMachine(initial_state=portal)
    machine.add_transition(
        Transition(
            source=portal,
            target=shield,
            condition=lambda event: event.name == "shield",
        )
    )
    machine.add_transition(
        Transition(
            source=portal,
            target=lockdown,
            condition=lambda event: event.name == "lockdown",
        )
    )
    machine.add_transition(
        Transition(
            source=shield,
            target=portal,
            condition=lambda event: event.name == "portal",
        )
    )
    machine.add_transition(
        Transition(
            source=shield,
            target=lockdown,
            condition=lambda event: event.name == "lockdown",
        )
    )
    machine.add_transition(
        Transition(
            source=lockdown,
            target=shield,
            condition=lambda event: event.name == "shield",
        )
    )
    machine.add_transition(
        Transition(
            source=lockdown,
            target=portal,
            condition=lambda event: event.name == "portal",
        )
    )
    return machine


def load_events(path: str) -> Iterable[Event]:
    config = AzazelConfig.from_file(path)
    events = config.get("events", [])
    for item in events:
        yield Event(name=item.get("name", "escalate"), severity=int(item.get("severity", 0)))


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Azazel control CLI")
    parser.add_argument("--config", required=True, help="Path to configuration YAML")
    args = parser.parse_args(list(argv) if argv is not None else None)

    machine = build_machine()
    daemon = AzazelDaemon(machine=machine, scorer=ScoreEvaluator())
    daemon.process_events(load_events(args.config))
    return 0


if __name__ == "__main__":  # pragma: no cover - CLI entry point
    raise SystemExit(main())
