# MacBook Pro M5 Pro Azazel Development Lab

This directory defines the **reference development environment** for validating the new M.I.O. cognitive plane together with Azazel-Knowledge and Azazel-Deception before Raspberry Pi HIL testing.

## Purpose

The MacBook lab validates system logic and cross-product contracts first:

```text
Evidence / Replay
      |
      v
Azazel-Edge (PR #380 branch)
  NOC/SOC evaluators
      |
      v
M.I.O. cognitive shadow core
  hypotheses -> evidence gaps -> read-only evidence -> hypothesis revision
      |                         |
      | advisory-only           | typed/read-only
      v                         v
Azazel-Knowledge          Azazel-Deception
long-term context         shadow/replay host
      ^                         |
      +------ observed outcome -+
```

The MacBook lab is **not** a replacement for Raspberry Pi validation. It is used to remove logic/integration defects before Pi-specific testing of Linux networking, systemd, nftables/tc, resource pressure, thermals and real interfaces.

## Safety boundary

The lab intentionally does **not**:

- run the Azazel-Edge installer;
- install/enable systemd services;
- change macOS packet filter or routing;
- invoke nftables, iptables or tc;
- connect M.I.O. directly to Action Arbiter enforcement;
- enable live AZ-06 engagement;
- expose Deception on a non-loopback interface;
- use a public/cloud LLM fallback.

Azazel-Deception is started with its existing `serve_shadow.py` launcher, which pins `live_execution=disabled`.

## Host baseline

Reference host:

- MacBook Pro with Apple Silicon M5 Pro
- macOS / arm64
- Python 3.11+
- Xcode Command Line Tools
- Docker Desktop or compatible Docker runtime (required for Deception compose/HIL-style development tests)
- Ollama (required only for live local-model M.I.O. tests)
- authenticated Git access to private `01rabbit/Azazel-Knowledge`

Each repository gets its own Python virtual environment because Knowledge and Deception intentionally pin different Azazel-Fabric contract versions.

## Repository pins

The bootstrap currently uses:

- `01rabbit/Azazel-Edge` -> `feat/mio-cognitive-shadow-core` (PR #380)
- `01rabbit/Azazel-Knowledge` -> `main`
- `01rabbit/Azazel-Deception` -> `main`

Do not switch Edge to `main` until PR #380 or its successor is merged.

## 1. Preflight

From this repository branch:

```bash
cd dev/macbook-m5pro
bash preflight.sh
```

Preflight is read-only. It verifies macOS/arm64, Python, Xcode tools, Docker reachability, Ollama reachability and GitHub authentication signals. It installs nothing.

## 2. Bootstrap repositories and virtual environments

Default lab root is `~/azazel-m5pro-lab`.

```bash
bash bootstrap.sh
```

Bootstrap:

1. clones/updates Edge, Knowledge and Deception;
2. creates separate `.venv` environments;
3. installs development dependencies;
4. provisions an isolated Knowledge development database under the lab state directory;
5. creates a scoped `ingest,query,read` Knowledge token;
6. creates a random AZ-06 shadow HMAC key;
7. stores runtime secrets outside every Git repository in `~/azazel-m5pro-lab/runtime.env` with mode `0600`;
8. runs the M.I.O. shadow test set.

For the complete Knowledge and Deception unit suites:

```bash
AZAZEL_FULL_TESTS=1 bash bootstrap.sh
```

To pull both initial local models during bootstrap:

```bash
AZAZEL_PULL_MODELS=1 bash bootstrap.sh
```

The configured initial M.I.O. chain is:

```text
qwen3.5:2b
   -> unavailable/failed transport only
qwen3.5:0.8b
```

There is no automatic cloud fallback.

## 3. Start the safe shadow lab

```bash
bash start-shadow-lab.sh
```

Default loopback services:

| Service | Endpoint | Authority |
|---|---|---|
| Azazel-Knowledge | `127.0.0.1:8070` | advisory-only |
| Azazel-Deception | `127.0.0.1:8071` | shadow/replay, live disabled |
| Ollama | `127.0.0.1:11434` | M.I.O. inference only |

Service logs are written under `~/azazel-m5pro-lab/logs/` and lab-managed process IDs under `~/azazel-m5pro-lab/pids/`.

## 4. Run M.I.O. with the real local model

With Ollama running and the model present:

```bash
cd ~/azazel-m5pro-lab/repos/Azazel-Edge
PYTHONPATH=py .venv/bin/python bin/azazel-mio-shadow-replay \
  --fixture tests/fixtures/mio/auth_ambiguity_shadow.json \
  --playbook auth-ambiguity-v1 \
  --endpoint http://127.0.0.1:11434
```

Expected boundary:

```text
Evidence/evaluator state
 -> MioSituationFrame
 -> multiple hypotheses
 -> evidence gaps
 -> read-only Capability Broker
 -> evidence-driven hypothesis revision
 -> grounded recommendation
 -> executable=false
```

A M.I.O. recommendation must not change Edge Defensive State in this stage.

## 5. Model comparison on M5 Pro

The Mac is the quality/reference environment. Run the same fixture against 0.8B, 2B, and later a larger local comparison model while keeping SituationFrame and Playbook identical.

Measure separately:

- hypothesis coverage;
- falsification quality;
- evidence-gap usefulness;
- fabricated-reference rejection;
- recommendation grounding;
- latency;
- peak memory;
- deterministic fallback behavior.

The Raspberry Pi candidate is selected from measured results, not assumed from parameter count.

## 6. Knowledge integration target

Knowledge already supports a local FastAPI surface and persists deterministic/advisory CTI state. The M.I.O. integration must remain:

```text
M.I.O. -> typed Knowledge query
Knowledge -> context + provenance + freshness + limitations
M.I.O. -> hypothesis/reasoning update
```

Never:

```text
Knowledge -> enforcement command
```

The lab's Knowledge state is deliberately isolated from the repository and from any production dataset.

## 7. Deception integration target

The development sequence is:

```text
M.I.O. information objective
 -> non-executable Engagement Advisory
 -> deterministic Edge mapping
 -> Arbiter decision
 -> AZ-06 shadow/replay request
 -> observed interaction/result
 -> M.I.O. hypothesis revision
 -> evidence-backed Knowledge feedback
```

Until the #373 adversarial gate is passed, development must remain shadow/replay only. The Mac lab must not be used to turn a model recommendation directly into AZ-06 activation.

## 8. When to move Edge to Raspberry Pi

Move Azazel-Edge to Raspberry Pi only after the Mac development gate demonstrates:

- stable M.I.O. reasoning/replay behavior;
- Knowledge absent/slow/malformed/wrong degradation;
- Deception unavailable/malformed/stale degradation;
- cross-trace rejection;
- prompt/delimiter/Unicode injection resistance;
- deterministic Arbiter remains the only authority;
- closed-loop replay is reproducible;
- #373 adversarial review findings are resolved or explicitly accepted.

Then Raspberry Pi HIL focuses on:

- Raspberry Pi OS/Linux behavior;
- systemd/service lifecycle;
- real NIC/interface state;
- nftables/tc/enforcement dry-run and approved paths;
- CPU/RAM/swap/temperature;
- long-duration stability;
- 0.8B/2B latency and resource budgets.

## Directory layout created by bootstrap

```text
~/azazel-m5pro-lab/
  repos/
    Azazel-Edge/
    Azazel-Knowledge/
    Azazel-Deception/
  state/
    knowledge/
    deception/
  logs/
  pids/
  runtime.env       # mode 0600; never commit
```

## Customization

Useful environment variables:

```bash
AZAZEL_LAB_ROOT=/path/to/lab
AZAZEL_GIT_BASE=git@github.com:01rabbit
AZAZEL_EDGE_BRANCH=feat/mio-cognitive-shadow-core
AZAZEL_FULL_TESTS=1
AZAZEL_PULL_MODELS=1
```

For SSH Git URLs, set for example:

```bash
AZAZEL_GIT_BASE=git@github.com:01rabbit bash bootstrap.sh
```

The scripts never write runtime secrets into any Azazel Git repository.
