# Defensive State: one vocabulary, and the five words it is not

Status: **partially landed.** The canonical definition and the Knowledge/
Deception boundaries exist and are mechanically enforced. Edge's outward
vocabulary and Gadget's specification are not covered here — see the status
table at the end, which says precisely what is and is not true today.

## 1. The canonical vocabulary

A product's **Defensive State** is what it is currently doing:

```text
OBSERVE | NOTIFY | THROTTLE | REDIRECT | ISOLATE
```

The canonical definition lives in **Azazel-Fabric**, in
`src/azazel_fabric/schema/defensive_state.py`. It is the only definition. A
second copy in any product would drift from it, and the drift would stay
invisible until someone compared values across two products.

Two properties are worth stating because they are enforced, not merely
intended:

**The word carries no warrant.** `DefensiveStateProjection` pins
`authority = "descriptive_only"` as a `Literal`, and Fabric's
`tests/test_no_enforcement_bypass.py` registers that pin so it cannot be
loosened quietly. A record reporting a state is a report, never an instruction.

**An unknown value never escalates.** `coerce_defensive_state` lands an
unrecognized value on `OBSERVE` — the state that does least — and returns a
second value saying whether the input was recognized, so "claims the weakest"
stays distinguishable from "could not be read".

## 2. Five words that are not Defensive State

The word **Mode** is no longer used as a generic synonym for any of these.

| Term | What it answers | Never |
| --- | --- | --- |
| **Defensive State** | What is the product doing right now? | A severity, a capability, or a UI condition |
| **Threat Level** | How severe is the observed situation? | What the product is doing about it |
| **Policy Profile** | Which deterministic threshold set is loaded? (conservative / balanced / demo) | A state, and never an authority |
| **AI Runtime Tier** | What can M.I.O. currently infer with? (deterministic-only / tiny-local / primary-local / local-accelerated) | A permission. Cognition is advisory in every tier |
| **Engagement / Deception State** | Where is an approved bounded deception environment in its own life? (`active` / `terminated` / `reset` / `failed` / `stale`) | A synonym for Defensive State |
| **Presentation State** | What is the UI showing? (`WARNING` / `UNKNOWN`) | An authority or an action |

A `REDIRECT` decision may result in traffic reaching an AZ-06 environment.
`REDIRECT` is still not an AZ-06 lifecycle state, and AZ-06 refuses it as one.

## 3. Who may set it

**Only Azazel-Edge's deterministic arbiter.** Everything else reports,
enriches, explains, or materializes.

| Product | May set Defensive State | Enforced by |
| --- | --- | --- |
| AZ-01 Edge | **yes** — the arbiter is the sole decision authority | — |
| AZ-02 Gadget | its own, deterministically; never another product's | *not verified here — see §6* |
| AZ-04 Knowledge | **no** | `Azazel-Knowledge/tests/unit/test_defensive_state_lane.py` |
| AZ-05 Fabric | **no** — it owns the word, not the authority | `Azazel-Fabric/tests/test_no_enforcement_bypass.py` |
| AZ-06 Deception | **no** | `Azazel-Deception/tests/test_defensive_state_boundary.py` |

These are test files, not assertions. A reader who doubts any row can run it.

**Knowledge stores a reported state as a fact with provenance** and never
enumerates the values itself: `reported_state` is carried exactly as it
arrived, `state_vocabulary` names the vocabulary it arrived in, and absence
yields `null` rather than a default. A default would be Knowledge asserting
another product's posture out of its own ignorance.

**Deception never learns the words.** The canonical values appear nowhere in
its code; its test parses every module and fails if one shows up as a string
literal outside a docstring. A reported producer state is not an input to
activation anywhere in AZ-06 — which is why a stale or replayed one cannot
prolong an environment. Not because it is filtered, but because there is
nothing to filter.

## 4. Legacy names: migration and deprecation

`portal`, `shield` and `scapegoat` predate this vocabulary.

**They remain permitted as concept branding and for backward compatibility.**
The Cyber Scapegoat Gateway is the project's founding concept and the
philosophy essays that use the word are not state documents. What changed is
narrower: these names are no longer *a* state vocabulary anywhere in the
system.

**Fabric deliberately defines no mapping from them to the canonical values.**
Deciding what `portal` means in canonical terms would make a product-local word
canonical by the back door — the same reason the system keeps exactly one
definition of everything it shares. A legacy name may be carried alongside a
canonical state as opaque context; it is never translated into one.

The deprecation is therefore a *demotion*, not a removal:

| Where | Action | State |
| --- | --- | --- |
| Cross-product state vocabulary | replaced by the canonical five | done in Fabric, Knowledge, Deception |
| `docs/architecture/modes.md` | demoted to a legacy note pointing here | done |
| Philosophy, branding, concept essays | unchanged, permitted | permanent |
| Product-local compatibility fields | may carry the legacy name as opaque context | per product |

## 5. The canonical flow

```text
Evidence
  -> deterministic scoring / policy evaluation
  -> optional M.I.O. reasoning (Edge only, when available, advisory)
  -> deterministic Arbiter
  -> Defensive State   OBSERVE | NOTIFY | THROTTLE | REDIRECT | ISOLATE
  -> enforcement / bounded deception / notification
  -> outcome evidence
```

M.I.O. failure does not stop deterministic operation. Neither does the absence
of Knowledge, Deception, remote cognition, or any network at all.

## 6. Status, stated precisely

| Acceptance criterion (Azazel#62) | State |
| --- | --- |
| One canonical definition of Defensive State | **met** — `azazel_fabric.schema.defensive_state`. **Not in any released tag yet**; Fabric's latest tag is `v0.9.0rc1` and the vocabulary landed after it |
| Edge exposes the five values as its primary vocabulary | **open** — Azazel-Edge#379, waiting on a Fabric tag that carries the vocabulary |
| Gadget specified as deterministic Edge-derived architecture | **not verified.** Azazel-Gadget was outside the scope this document was written from; nothing here should be read as a claim about it |
| Threat Level / Policy Profile / AI Runtime Tier / Engagement State / Presentation State distinguished | **met for this document** (§2). Per-product doc alignment is partial |
| Fabric semantics preserve the distinction without creating authority | **met** — `authority` pinned `descriptive_only`, registered in the shared gate |
| Knowledge and Deception explicitly cannot set Defensive State | **met** — both enforced by test, named in §3 |
| Legacy terminology has an explicit migration/deprecation plan | **met** — §4 |
| Cross-repo docs and diagrams aligned | **partial** — Fabric, Knowledge and Deception carry the boundary in their own docs; Edge and Gadget do not yet |

Three of the eight wait on work outside this repository, and one of those
three waits only on a Fabric release tag.

## 7. What this document does not do

It does not enforce anything. The enforcement is in the three test files named
in §3, and this page is only useful to the extent it points at them honestly.
A reader who finds a row here that those tests do not support should trust the
tests and fix this page.
