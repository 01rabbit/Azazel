---
title: Nexus and Boot R0 Baseline
nav_exclude: true
---

# Nexus and Boot R0 Product and Compatibility Baseline

Status: product designations ratified 2026-09-18; the compatibility state, issue register, and exit criteria below are observed records, not ratified claims  
Baseline date: 2026-09-19  
Last verified against the repositories: 2026-09-19  
Program plan: [Nexus and Boot cross-repository development plan](nexus-boot-program-plan.md)

Ratification scope: [Azazel #70](https://github.com/01rabbit/Azazel/issues/70) is closed as completed (2026-09-18). What was ratified is exactly what the [naming specification](../specs/naming.md) records under "Ratified Designations / 2026-09-18": the formal names `Azazel-Boot Responder` (AZ-03) and `Azazel-Nexus Gateway` (AZ-07), their series numbers, the `Nexus` and `Responder` additions to the Form and Role vocabularies, the two deployment scopes, and Azazel-Edge as the sole deterministic enforcement authority. Ratification extends no further. The observed compatibility state, the R0 issue register, and the R0 exit criteria in this document are engineering records that change as the repositories change, and they are re-verified rather than ratified.

This document freezes the product meanings and records the observed dependency state from which Nexus and Boot development starts. It is a coordination baseline, not a promise that every listed repository already implements the target behavior.

## Product definitions

| Designation | Product | Deployment | Minimum independent behavior |
|---|---|---|---|
| AZ-03 | Azazel-Boot Responder | Civil emergency environment started from removable USB SSD media on a commissioned compatible x86_64 laptop | Deterministic Core assessment, bounded topology-gated response, evidence handling, and recovery support without external services |
| AZ-07 | Azazel-Nexus Gateway | Persistent, self-contained installation on a generic rugged x86_64 Linux PC | Deterministic observation, evaluation, decision, operator control, audit, graceful degradation, and topology-gated bounded enforcement without external nodes |

Boot and Nexus are deployment products. Azazel-Fabric owns shared descriptive contracts; Azazel-Edge remains the sole deterministic decision and enforcement authority. M.I.O., Knowledge, Deception, installers, user interfaces, and external nodes cannot override that authority.

## Capability rules

- `FULL`, `LITE`, and `CORE` are capability states, not authority levels.
- A higher resource tier permits capacity; it does not prove network topology, model availability, signature validity, trust, or service health.
- Interface roles are assigned during commissioning and confirmed by an operator. They are not inferred solely from interface names or link state.
- Nexus must remain useful standalone. External AZ-04 Knowledge and AZ-06 Deception nodes extend capability and are never baseline dependencies.
- Boot writes no internal host storage by default. Any approved export target requires an explicit operator action.
- Failure or loss of optional cognition and advisory services falls back locally and deterministically.

## Observed compatibility state

The following pins were observed on each repository's `main` branch during the baseline audit. They expose compatibility work; they do not declare every combination interoperable.

| Repository | Observed product/package version | Observed Azazel-Fabric pin | R0 interpretation |
|---|---|---|---|
| Azazel-Fabric | package `0.8.0`; GitHub release `v0.8.0` published | self | Contract source of truth; documentation and compatibility claims require reconciliation |
| Azazel-Edge | repository has no single product package version | `v0.8.0` in `requirements/fabric.txt` | Reference authority implementation for Nexus/Boot integration |
| Azazel-Gadget | repository has no single product package version | `v0.4.0` in `requirements.txt` | Existing consumer retained in the compatibility matrix; not part of Nexus/Boot implementation scope |
| Azazel-Knowledge | package `0.1.0` | `v0.8.0` in the API optional dependency (`pyproject.toml`, `api` extra), moved from `v0.6.0` by Knowledge ADR-0016, commit `97bad3e` | Lite bundle and advisory interfaces must be aligned with the selected Fabric baseline |
| Azazel-Deception | package `0.2.0.dev0` | `v0.8.0` in `pyproject.toml` | Lite profiles and assurance claims must be made explicit and testable |
| Azazel-Nexus | no release baseline yet | none | Must adopt an explicit, tested Fabric pin before an implementation release |
| Azazel-Boot | package `0.0.0`, declared a non-operational status scaffold; bootstrap issue [#1](https://github.com/01rabbit/Azazel-Boot/issues/1) still open | `v0.8.0` exact tag in the `fabric` optional dependency (`pyproject.toml`), per Boot ADR-0004 | The package manifest now carries the pin; the image lock does not exist yet and must carry the same baseline |

Fabric `v0.8.0` is the current reference candidate: its source package and the Edge, Deception, Knowledge, and Boot pins now agree, and a published release exists. Azazel-Gadget remains at `v0.4.0` and Azazel-Nexus still has no pin, so the pins do not yet agree series-wide. The Fabric truth pass is complete ([Azazel-Fabric #20](https://github.com/01rabbit/Azazel-Fabric/issues/20), closed as completed 2026-09-18); what remains before `v0.8.0` can be called the program-wide locked baseline is consumer compatibility evidence, and no cross-repository conformance run against `v0.8.0` is linked from this document or the program plan. No repository may silently float its Fabric dependency.

Azazel-Fabric's own `docs/release-compatibility.md` still records the superseded Knowledge (`v0.6.0`) and Boot (no image lock) rows. Fabric owns that document; this baseline does not edit it.

## R0 issue register

State verified 2026-09-19. A closed entry is not reopened for new work; follow-up work gets its own issue.

| Repository | Issue | State | R0 outcome |
|---|---|---|---|
| Azazel | [#70](https://github.com/01rabbit/Azazel/issues/70) | closed as completed 2026-09-18 | Ratify product names, authority boundaries, and compatibility baseline |
| Azazel-Fabric | [#20](https://github.com/01rabbit/Azazel-Fabric/issues/20) | closed as completed 2026-09-18 | Reconcile release, schema, documentation, and support truth |
| Azazel-Edge | [#410](https://github.com/01rabbit/Azazel-Edge/issues/410) | closed as completed 2026-09-18 | Define the supported x86_64 package and the installer/commissioning boundary |
| Azazel-Knowledge | [#73](https://github.com/01rabbit/Azazel-Knowledge/issues/73) | open | Define and sign the bounded Knowledge Lite bundle |
| Azazel-Deception | [#35](https://github.com/01rabbit/Azazel-Deception/issues/35) | open | Reconcile assurance truth and define bounded Lite profiles |
| Azazel-Nexus | [#2](https://github.com/01rabbit/Azazel-Nexus/issues/2) | closed as completed 2026-09-19 | Make Fabric the contract source of truth and separate resource from topology eligibility |
| Azazel-Boot | [#1](https://github.com/01rabbit/Azazel-Boot/issues/1) | open | Bootstrap the removable-media product with safe host and persistence defaults |

A closed entry records that the issue's own scope was delivered; it does not close the corresponding R0 exit criterion below. The [third-party development handoff](third-party-development-handoff.md) states the same rule for Fabric's truth-reconciliation issue: it is closed and is not to be reopened for new integration work.

## R0 exit criteria

- Product names, designations, audiences, and deployment boundaries are owner-ratified.
- The Fabric reference version and supported schema/API matrix are factual and tested.
- Every consumer has an explicit immutable Fabric pin or image lock.
- Edge authority and advisory-only boundaries are represented in contracts and integration tests.
- Installer inventory is non-destructive; commissioning produces a reviewable topology plan before applying it.
- RAM tiers of 8 GB, 16 GB, and 32 GB or more select resource envelopes independently of topology. (Open finding OF-01 below: the selector that implements this criterion does not assign these nominal tiers to the envelopes named here.)
- Nexus and Boot publish their own security policy, support matrix, license, update channel, and recovery procedure before a release is called supported.
- Cross-repository conformance, degraded-mode, update, rollback, and recovery evidence is linked from the program plan.

Until all exit criteria pass, R0 artifacts are development baselines and must not be described as operationally certified releases.

## Open R0 findings

Findings raised against R0 that are not yet resolved. The full record lives in the program plan, §15; this list exists so that a reader of the exit criteria above sees what is known to be wrong with them. A finding is not a decision.

| Finding | Concerns | State |
|---|---|---|
| [OF-01](nexus-boot-program-plan.md#15-open-program-findings) — the RAM selector's thresholds contradict the tiers the program assumes | the exit criterion on 8/16/32 GB RAM tiers above, the program plan's R2 selector and R4 Boot exit gate, and the tables those thresholds have propagated into in Azazel-Nexus and Azazel-Boot | open; resolution is an owner decision, and the candidate resolutions are recorded without one being chosen |
