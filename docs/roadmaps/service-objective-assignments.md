# Service Objective Assignments

Companion to `nexus-boot-program-plan.md` §8. Status: assignment dated 2026-09-19, amended for Boot scope on 2026-09-28.

§8 now has ten active measurable targets and calls them *initial release gates*. It
binds in both directions: a later change may revise a target only with benchmark
evidence and an updated compatibility entry. Other parts of the plan already
lean on it — §5 R5's exit gate requires staying "within per-peer quotas and Core
service objectives", and §9.5 makes release eligibility partly "current
documentation matches observed behavior".

As of 2026-09-19 no repository measured any row, and none referenced one. That
made §8 a release gate with no owner, no method, and no evidence path. This
document assigns each active row so the gate can be enforced rather than
asserted.

**This document changes no target value.** Revising a target needs the benchmark
evidence §8 itself demands, and that evidence does not exist yet. Where a target
turns out to be unmeasurable *as written*, it is recorded as an open program
finding (§15), not repaired here. Two rows are in that position: see OF-05 and
OF-06.

**This document implements no harness.** Its deliverable is the assignment. The
follow-up issues in §6 below carry the implementation.

## 1. How to read a row

Every row states the same seven things, so nothing is left to a reader's
judgement:

| Field | Meaning |
| --- | --- |
| **Owner** | The one repository that owns the measurement and its evidence. |
| **Configuration** | The product configuration measured. A target measured on the wrong configuration proves nothing. |
| **Start event** | The observable instant the interval opens. Never "when someone noticed". |
| **End event** | The observable instant it closes. Never a proxy for the thing the row is about. |
| **Clock** | Which clock, on which host. A latency measured across two unsynchronized clocks is not a latency. |
| **Sample rule** | How many observations, across what variation. |
| **Pass rule** | The single condition that decides. A hard bound ("every sample"), a percentile, or a hard zero — stated, not implied. |

Each row is also classified:

- **software** — measurable in a container or CI runner.
- **virtual-lab** — needs a running lab (namespaces, virtual NICs, real containers) but no specific hardware.
- **hardware-only** — needs a declared hardware class, a physical segment, or a second physical device. **No green CI run can satisfy a hardware-only row**, the same rule `Azazel-Deception/docs/live-gate-checklist.md` already applies to its HIL gates.

A row that is hardware-only in its release form may still have a software or
virtual-lab variant. That variant is a regression signal, never the gate.

## 2. Evidence path

Every measurement writes one JSON record per run. The record carries, at
minimum: the objective id, the owning repository and commit, the product
configuration (including the **commissioned composite interface identity** where
an interface is involved — never the kernel interface name), every sample with
its start and end timestamps, the pass rule as evaluated, and the verdict.

The record is archived by the owning repository as a workflow artifact for
software and virtual-lab rows, and as a field-exercise record committed to the
owning repository for hardware-only rows. The release gate named on each row
reads those records. "Benchmark evidence and an updated compatibility entry", as
§8 requires for a revision, means one of these records plus the compatibility
entry of the configuration it was taken on.

A record is evidence only if the measurement actually ran. A job that exists is
not a run that happened, and a suite that skipped is not executed evidence.

## 3. Active objectives and retired identifiers

### SO-01 — Core ready after encrypted-volume unlock (within 120 seconds)

- **Owner:** Azazel-Nexus.
- **Configuration:** an installed system on each declared rugged-PC class.
- **Start event:** the decryption layer reports the volume mapped and usable (the unlock unit reaching its active state), not when the passphrase was typed.
- **End event:** the deterministic Core answers. Concretely: a synthetic probe event submitted to the Core decision path receives a decision **and** that decision's audit-chain record is durable. Not "the init system finished", which can be true while the Core is not yet answering.
- **Clock:** `CLOCK_MONOTONIC` on the device under test. One clock domain; no NTP dependency, because a Core that is not ready cannot be relied on to have corrected its time.
- **Sample rule:** 10 consecutive cold boots per declared hardware class, at the coldest declared cache state.
- **Pass rule:** **every** sample ≤ 120 seconds. The maximum is reported. An operator experiences each boot individually, so a percentile would let a failing boot pass.
- **Class:** hardware-only. A virtual-lab variant with a virtual encrypted volume is the regression signal for the software path.
- **Gate:** R7 (product field readiness); re-read at R8.

### SO-02 — Source/interface failure visible (within 10 seconds)

- **Owner:** Azazel-Edge.
- **Configuration:** Edge as integrated into a Nexus Core install, with the operator surface present.
- **Start event:** the instant the harness injects the failure — capture-interface link down, capture process death, or feed source made unreachable. The harness timestamps its own injection.
- **End event:** the read-only operator status surface reports that source as failed or unavailable when polled. "Visible" means legible on the surface an operator actually reads, not an internal flag.
- **Clock:** the harness host's monotonic clock; the harness both injects and polls, so both events share one clock.
- **Sample rule:** 20 injections, covering every declared source type.
- **Pass rule:** **every** sample ≤ 10 seconds.
- **Class:** virtual-lab for the logical source types (veth link-down, process kill, unreachable feed). The physical-NIC variant is hardware-only.
- **Gate:** R3 for the virtual-lab class; R7 for the physical variant.

### SO-03 — P0 visual/voice alert queued after decision (within 2 seconds)

- **Owner:** Azazel-Edge.
- **Configuration:** Edge with the P0 alert path configured for the declared output devices.
- **Start event:** the arbiter's decision record is durable (its audit-chain entry committed). "After decision" is after the decision exists, not after it was computed.
- **End event:** the alert is **enqueued** into the visual/voice delivery queue with a durable record naming the decision id. The row says *queued*; rendering and speaking are downstream and are not bounded here.
- **Clock:** the Edge node's monotonic clock. Both events are recorded by Edge on one host.
- **Sample rule:** 200 synthetic P0 decisions under nominal load.
- **Pass rule:** **every** sample ≤ 2 seconds. Behaviour under hostile load is governed by SO-11, not by relaxing this rule.
- **Class:** software.
- **Gate:** R3.

### SO-04 — Lease-expiry rollback starts (within 5 seconds of expiry)

- **Owner:** Azazel-Edge.
- **Configuration:** Edge holding an enforcement lease of each declared action type.
- **Start event:** the lease's declared expiry instant, taken from the lease record itself — not the moment a sweeper noticed it.
- **End event:** an audit-chain record naming that lease id states that rollback has begun.
- **Clock:** the issuing node's monotonic clock, the same one the lease was issued against (§4.3). A lease must not depend on remote time, so a cross-node lease is measured on its issuer.
- **Sample rule:** 50 leases per declared action type, including leases expiring while the node is under hostile load and while the operator plane is unavailable.
- **Pass rule:** **every** sample starts ≤ 5 seconds after expiry.
- **Completion:** deliberately not bounded here. §8 says the completion bound is action-specific; no action type currently declares one anywhere. That half is **unmeasurable as written** — see OF-05.
- **Class:** software.
- **Gate:** R3.

### SO-05 — Local M.I.O. failure reflected as `CORE ONLY` (within 30 seconds)

- **Owner:** Azazel-Edge.
- **Configuration:** a node with a local M.I.O. runtime configured — the Nexus profiles that carry one, or Edge with a local model.
- **Start event:** the instant the harness injects the failure: process death, OOM kill, model asset removed, or health probe made to hang.
- **End event:** the node's reported capability state reads `CORE ONLY` on the read-only status surface **and** an audit record names the degradation cause. A state change with no recorded cause is not a reflection of the failure.
- **Clock:** the harness host's monotonic clock.
- **Sample rule:** 20 injections, covering every declared failure mode above.
- **Pass rule:** **every** sample ≤ 30 seconds.
- **Class:** software.
- **Gate:** R6.
- **Note:** `CORE ONLY` is a capability state, never an authority state (§3.1). Reflecting it narrows what the node can do; it moves no authority.

### SO-06 — External Knowledge, Deception, or remote cognition loss (100% continuation)

This row is a **property, not a latency**. It has no start or end event.

- **Owner:** Azazel-Edge, with the consumer variant owned by Azazel-Nexus.
- **Configuration:** the deterministic Core with each external dependency present, then with each one removed.
- **Method:** run a fixed deterministic scenario replay twice over identical inputs — once with every external dependency healthy, once with one dependency in each failure mode: **absent, refusing, hanging, corrupt, expired**. Compare the four deterministic paths the row names: evidence records, evaluation outcomes, enforcement-lease records, audit chain.
- **Pass rule:** across every scenario and every failure mode, the evaluation outcomes, enforcement-lease records and audit chain are **byte-identical** to the healthy run, after excluding only the fields that legitimately record advisory presence (advisory reason entries and advisory source generation), and **no record is dropped**. "100% continuation" is zero deterministic-path divergence — not "mostly the same".
- **Clock:** not applicable; deterministic replay.
- **Class:** software.
- **Gate:** R4 for the Knowledge axis, R5 for Deception, R6 for remote cognition.
- **Note:** this is the same property [Azazel-Nexus#15](https://github.com/01rabbit/Azazel-Nexus/issues/15) requires of the embedded Lite consumer.

### SO-07 — Audit ordering (durable before reported complete)

This row is a **property, not a latency**.

- **Owner:** Azazel-Edge for the decision chain, with the same check owned per-chain by Azazel-Knowledge (advisory chain), Azazel-Deception (outcome chain) and Azazel-Nexus (system anchor).
- **Configuration:** each chain in its own product's Core configuration.
- **Method:** fault injection at the durability boundary. For every record type the chain writes, interrupt between "record written" and "reported complete", at minimum by killing the process after the report and before the flush. On restart, enumerate every action reported complete and check its record exists.
- **Pass rule:** **zero** instances of "reported complete, record absent", at every injection point. The converse — a durable record for an action never reported complete — is permitted and is the safe direction.
- **Class:** software for the process-kill variant. The true power-cut variant is hardware-only.
- **Gate:** R3 for the software variant; R7 for the power-cut variant.

### SO-08 — Deception isolation drift (detect ≤ 2 s, withdraw exposure ≤ 5 s)

- **Owner:** Azazel-Deception for detection; the withdrawal half is measured end-to-end through the Azazel-Edge authority path, because withdrawing an attacker route is an enforcement action and AZ-06 does not hold enforcement authority.
- **Configuration:** an activated engagement environment on a real segment, with a protected network present to drift toward.
- **Start event:** the instant the harness injects drift — a route appearing from the decoy side toward the protected side, a published port appearing, or a dropped capability being re-added.
- **End event (detect):** the drift is recorded as an observation in the AZ-06 evidence chain.
- **End event (withdraw):** an **active probe from the decoy side fails to reach the protected side**. The row says "independent of runtime cleanup", so the decoy container may still be running; reachability is what is measured, not teardown.
- **Clock:** the harness host's monotonic clock; the harness both injects and probes.
- **Sample rule:** 20 injections per declared drift type.
- **Pass rule:** **every** sample detects ≤ 2 seconds and withdraws ≤ 5 seconds.
- **Class:** hardware-only in its release form — it is the same property as AZ-06's `hil_no_route_decoy_to_production` and `hil_egress_denied_under_failure` gates, and that checklist already states no CI run satisfies a HIL gate. A namespace-based virtual-lab variant is the regression signal.
- **Gate:** R5; the HIL half rides AZ-06's live-gate checklist.

### SO-09 — Retired Boot host-storage objective (identifier not reused)

Retired by the owner on 2026-09-28 when Boot's bootable-OS and media-writing
scope was removed. Boot does not start an OS from USB, so the initramfs-to-
shutdown host-storage measurement no longer has a Boot configuration to
measure. This is a scope retirement, not a measured pass; future helper tools
must declare and test their own exact host side effects.

### SO-10 — Observation interface (zero transmitted frames in a 10-minute stress interval)

A **zero-value row**. Stated as a falsifiable check:

- **Owner:** Azazel-Nexus.
- **Configuration:** the interface commissioned into the observation role, identified in the record by its **commissioned composite identity** (bus path, permanent MAC, and PCI/USB identity or serial) — never by kernel name, which can move between boots.
- **What is observed:** an **independent capture device** on the same physical segment — a second host, a tap, or a switch mirror port. The measurement must not run on the device under test: a host that transmits a frame could equally fail to record that it did.
- **Stress:** across 10 minutes, drive link up/down transitions, IPv6 Router Advertisements, DHCP offers and requests, and at least one suspend/resume cycle.
- **What counts as a violation:** any frame the independent capture attributes to that interface's link, counted individually — explicitly including ARP, DHCP, IPv6 RS/NS/NA, mDNS, LLDP and 802.1X, which are the frames a host emits without anyone asking it to.
- **Sample rule:** 3 runs per declared hardware class.
- **Pass rule:** **zero** attributed frames in every run. A hard zero.
- **Class:** hardware-only — it requires a second physical device on the same segment.
- **Gate:** R7.
- **Note:** this row is why an interface role is confirmed and never inferred. A measurement taken on an interface that is not the commissioned one measures nothing, which is why the composite identity is part of the record.

### SO-11 — Hostile load (SLOs hold at each declared ingress quota)

This row is parasitic on others: it asserts that SO-03, SO-04, SO-07 and the
health surface continue to hold while the node is under load.

- **Owner:** Azazel-Edge.
- **Configuration:** the Core at each declared ingress quota.
- **Method:** re-run SO-03, SO-04 and SO-07, plus a health-surface freshness check, while offering traffic at each declared ingress quota; then once at 120% of the highest declared quota.
- **Pass rule:** at every declared quota, the referenced rows' own pass rules hold **unchanged**. At 120%, the quota must **shed** — excess dropped or queued per the declared policy — and the referenced rows must still hold for admitted traffic. A quota that is declared but not enforced fails this row.
- **Clock:** as per the referenced rows.
- **Class:** virtual-lab for traffic generation; a hardware-class run at R7 confirms the quota values per declared hardware class.
- **Gate:** R5 exit gate, which already names this; re-read at R7.
- **Blocked:** "each declared ingress quota" presumes declared quotas. None exist in any repository — see OF-06.

## 4. Classification summary

| Objective | Owner | Class (release form) | Gate |
| --- | --- | --- | --- |
| SO-01 Core ready after unlock | Nexus | hardware-only | R7 |
| SO-02 Source/interface failure visible | Edge | virtual-lab (physical variant hardware-only) | R3 / R7 |
| SO-03 P0 alert queued | Edge | software | R3 |
| SO-04 Lease-expiry rollback starts | Edge | software | R3 |
| SO-05 M.I.O. failure → `CORE ONLY` | Edge | software | R6 |
| SO-06 External loss → 100% continuation | Edge (+ Nexus) | software | R4 / R5 / R6 |
| SO-07 Audit ordering | Edge (+ per-chain owners) | software (power-cut hardware-only) | R3 / R7 |
| SO-08 Deception isolation drift | Deception (+ Edge path) | hardware-only | R5 |
| SO-10 Observation interface | Nexus | hardware-only | R7 |
| SO-11 Hostile load | Edge | virtual-lab | R5 / R7 |

Four of ten active rows are hardware-only in their release form. §8 never made that
distinction, although the plan's own R0 deliverables demand it everywhere else.

## 5. Deferral register

A row that cannot be measured yet is deferred explicitly, to a named gate, with
a reason. None is left silently unmeasured.

| Objective | Deferred to | Reason |
| --- | --- | --- |
| SO-01 | R7 | No installed Nexus exists on a declared hardware class. |
| SO-02 (physical variant) | R7 | Needs a declared hardware class with real NICs. |
| SO-05 | R6 | The local M.I.O. runtime profile is not implemented ([Azazel-Nexus#5](https://github.com/01rabbit/Azazel-Nexus/issues/5)). |
| SO-06 (Nexus consumer variant) | R4 | Nexus has no Core to run the replay against; the requirement is recorded as [Azazel-Nexus#15](https://github.com/01rabbit/Azazel-Nexus/issues/15). |
| SO-07 (power-cut variant) | R7 | Needs real hardware that can lose power. |
| SO-08 | R5 | The AZ-06 live gate is not open; the HIL half cannot be certified from any CI run. |
| SO-10 | R7 | Needs a second physical capture device on the same segment. |
| SO-11 | R5 | Blocked on declared ingress quotas, which do not exist (OF-06). |

SO-03, SO-04 and SO-07 (software variant) are **not** deferred. Edge exists,
runs CI, and can measure them now.

## 6. Follow-up issues

This document assigns; the owning repositories implement. One issue per owning
repository:

| Repository | Objectives it owns | Issue |
| --- | --- | --- |
| Azazel-Edge | SO-02, SO-03, SO-04, SO-05, SO-06, SO-07, SO-11 | [Azazel-Edge#414](https://github.com/01rabbit/Azazel-Edge/issues/414) |
| Azazel-Deception | SO-08 | [Azazel-Deception#41](https://github.com/01rabbit/Azazel-Deception/issues/41) |
| Azazel-Nexus | SO-01, SO-06 (consumer), SO-10 | [Azazel-Nexus#17](https://github.com/01rabbit/Azazel-Nexus/issues/17) |

Azazel-Knowledge and Azazel-Fabric own no row. Knowledge appears inside SO-06 as
a dependency whose loss must change nothing, and inside SO-07 as a chain owner
under §12 — neither makes it the owner of a timing target. Fabric describes; it
measures nothing.
