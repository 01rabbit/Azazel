"""Runtime daemon glue for Azazel."""
from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

from azazel_core import ScoreEvaluator, StateMachine
from azazel_core.state_machine import Event


@dataclass
class AzazelDaemon:
    machine: StateMachine
    scorer: ScoreEvaluator

    def process_events(self, events: Iterable[Event]) -> None:
        score = self.scorer.evaluate(events)
        classification = self.scorer.classify(score)
        if classification in {"elevated", "critical"}:
            self.machine.dispatch(Event(name="escalate", severity=score))
        else:
            self.machine.dispatch(Event(name="recover", severity=0))
