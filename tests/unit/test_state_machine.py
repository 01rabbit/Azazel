from azazel_core.state_machine import Event, State, StateMachine, Transition


def test_state_machine_transitions():
    idle = State(name="idle")
    shield = State(name="shield")
    machine = StateMachine(initial_state=idle)
    machine.add_transition(
        Transition(source=idle, target=shield, condition=lambda event: event.name == "escalate")
    )
    machine.add_transition(
        Transition(source=shield, target=idle, condition=lambda event: event.name == "recover")
    )

    assert machine.current_state == idle
    machine.dispatch(Event(name="noop"))
    assert machine.current_state == idle
    machine.dispatch(Event(name="escalate"))
    assert machine.current_state == shield
    machine.dispatch(Event(name="recover"))
    assert machine.current_state == idle
