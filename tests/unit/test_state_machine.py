from dataclasses import dataclass

from azazel_core.state_machine import Event, State, StateMachine, Transition


@dataclass
class FakeClock:
    value: float = 0.0

    def __call__(self) -> float:
        return self.value


def build_machine(clock: FakeClock) -> StateMachine:
    portal = State(name="portal")
    shield = State(name="shield")
    lockdown = State(name="lockdown")
    machine = StateMachine(initial_state=portal, clock=clock)
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


def test_state_machine_transitions():
    clock = FakeClock()
    machine = build_machine(clock)

    assert machine.current_state.name == "portal"
    machine.dispatch(Event(name="shield", severity=55))
    assert machine.current_state.name == "shield"
    machine.dispatch(Event(name="lockdown", severity=90))
    assert machine.current_state.name == "lockdown"
    machine.dispatch(Event(name="portal", severity=0))
    assert machine.current_state.name == "portal"


def test_state_machine_presets_and_unlocks():
    clock = FakeClock()
    machine = build_machine(clock)

    # Start from portal – presets come from configs/azazel.yaml
    actions = machine.get_actions_preset()
    assert actions["delay_ms"] == 100
    assert actions["shape_kbps"] is None
    assert actions["block"] is False

    # Escalate to lockdown based on high score
    result = machine.apply_score(90)
    assert result["desired_mode"] == "lockdown"
    assert machine.current_state.name == "lockdown"
    actions = machine.get_actions_preset()
    assert actions["delay_ms"] == 300
    assert actions["shape_kbps"] == 64
    assert actions["block"] is True

    # Average drops below threshold but unlock wait keeps us in lockdown
    result = machine.apply_score(0)
    assert result["target_mode"] == "lockdown"
    assert machine.current_state.name == "lockdown"

    # Advance clock past the shield unlock window and drop severity
    clock.value += 601
    result = machine.apply_score(0)
    assert result["target_mode"] == "shield"
    assert machine.current_state.name == "shield"

    # Move clock forward for portal unlock and continue low severity
    clock.value += 1800
    result = machine.apply_score(0)
    assert result["target_mode"] == "portal"
    assert machine.current_state.name == "portal"
