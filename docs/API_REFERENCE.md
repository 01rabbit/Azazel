# API reference

This reference documents the Python modules that make up the Azazel control
plane. The intent is to provide enough context for operators to extend or mock
the behaviour during testing.

## `azazel_core.state_machine`

- `State(name: str, description: str = "")`
- `Event(name: str, severity: int = 0)`
- `Transition(source, target, condition, action=None)`
- `StateMachine(initial_state, config_path=None, window_size=5)` provides:
  - `add_transition(transition)` – register a new transition.
  - `dispatch(event)` – evaluate transitions from the current state.
  - `reset()` – return to the initial state and clear score history.
  - `summary()` – dictionary suitable for API responses.
  - `get_thresholds()` – read shield/lockdown thresholds and unlock timers
    from `azazel.yaml`.
  - `get_actions_preset()` – fetch the delay/shape/block preset for the
    current mode.
  - `apply_score(severity)` – update the moving-average score window,
    transition to the correct mode, and return evaluation metadata.

## `azazel_core.scorer`

`ScoreEvaluator` computes cumulative severity and provides `classify(score)`
which returns `normal`, `guarded`, `elevated`, or `critical`.

## `azazel_core.actions`

`DelayAction`, `ShapeAction`, `BlockAction`, and `RedirectAction` derive from the
common `Action` interface and expose `plan(target)` iterators. Each yields
`ActionResult` objects that describe tc/nftables commands without executing
side-effects.

## `azazel_core.ingest`

`SuricataTail` and `CanaryTail` read JSON logs from disk and emit `Event`
instances. They are intentionally deterministic, easing unit test coverage.

## `azazel_core.api`

`APIServer` is a minimal dispatcher used by future HTTP front-ends. The bundled
handler `add_health_route(version)` returns a `HealthResponse` dataclass.

## `azctl.cli`

`build_machine()` wires the portal/shield/lockdown states. `load_events(path)`
loads YAML describing synthetic events. `main(argv)` powers the systemd service
by feeding events into `AzazelDaemon`, which applies score-based decisions and
writes `decisions.log` entries containing the chosen mode and action presets.

## HTTP endpoints

### `POST /v1/mode`

The controller exposes a minimal HTTP interface for supervised overrides. A
`POST` request to `/v1/mode` with a JSON body such as `{ "mode": "shield" }`
will transition the daemon to the requested state. The handler immediately
applies the corresponding preset from `azazel.yaml` (delay, shaping rate, and
block flag) and records the outcome to `decisions.log` alongside operator
metadata. Preset values are documented in the operations guide's
[mode action table](OPERATIONS.md#mode-presets).

## Scripts

- `scripts/suricata_generate.py` renders the Suricata YAML template.
- `scripts/nft_apply.sh` and `scripts/tc_reset.sh` manage enforcement tools.
- `scripts/sanity_check.sh` prints warnings if dependent services are inactive.
- `scripts/rollback.sh` removes installed assets.
- `scripts/resolve_allowlist.py` resolves medical FQDNs to CIDRs and writes the
  lockdown nftables allowlist used by the generated template.
