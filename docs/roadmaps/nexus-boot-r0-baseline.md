---
title: Nexus and Boot R0 Baseline
nav_exclude: true
---

# Nexus and Boot R0 Product and Compatibility Baseline

Status: product designations ratified 2026-09-18; the compatibility state, issue register, and exit criteria below are observed records, not ratified claims  
Baseline date: 2026-09-19
Last scope correction: 2026-09-28 (Boot owner decision)
Program plan: [Nexus and Boot cross-repository development plan](nexus-boot-program-plan.md)

Ratification scope: [Azazel #70](https://github.com/01rabbit/Azazel/issues/70) is closed as completed (2026-09-18). What was ratified is exactly what the [naming specification](../specs/naming.md) records under "Ratified Designations / 2026-09-18": the formal names `Azazel-Boot Responder` (AZ-03) and `Azazel-Nexus Gateway` (AZ-07), their series numbers, the `Nexus` and `Responder` additions to the Form and Role vocabularies, the two deployment scopes, and Azazel-Edge as the sole deterministic enforcement authority. Ratification extends no further. The observed compatibility state, the R0 issue register, and the R0 exit criteria in this document are engineering records that change as the repositories change, and they are re-verified rather than ratified.

This document freezes the product meanings and records the observed dependency state from which Nexus and Boot development starts. It is a coordination baseline, not a promise that every listed repository already implements the target behavior.

## Owner scope correction (2026-09-28)

For Azazel-Boot, the 2026-09-19 removable-media deployment description below
is historical and superseded. Boot does not build or remaster Debian Live or
another OS, create/write boot media, or provide Boot-owned persistence. Its
current assistance flow is user-prepared Debian Live, user-configured
persistence, the existing Nexus tools installer, and a separate-PC boot check.
Boot owns guidance and evidence collection only, not image/media or persistence
lifecycle tooling. Issues #61 and #63 track the guidance and the still-pending
hardware observation. See [Boot ADR-0012](https://github.com/01rabbit/Azazel-Boot/blob/main/docs/adr/0012-existing-environment-tooling.md)
and the program plan's owner scope correction. This does not change Nexus's
persistent appliance role or Edge's sole authority.

## Product definitions

| Designation | Product | Deployment | Minimum independent behavior |
|---|---|---|---|
| AZ-03 | Azazel-Boot Responder | Guidance for user-prepared Debian Live, user-managed persistence, existing Nexus tools installer, and separate-PC check; no OS/image creation or media writing | #61 guidance and #63 hardware observation remain open; no operational Boot installer or capability is claimed |
| AZ-07 | Azazel-Nexus Gateway | Persistent, self-contained installation on a generic rugged x86_64 Linux PC | Deterministic observation, evaluation, decision, operator control, audit, graceful degradation, and topology-gated bounded enforcement without external nodes |

Nexus is the deployment product; Boot is a user-assistance/tooling companion. Azazel-Fabric owns shared descriptive contracts; Azazel-Edge remains the sole deterministic decision and enforcement authority. M.I.O., Knowledge, Deception, installers, user interfaces, and external nodes cannot override that authority.

## Capability rules

- `FULL`, `LITE`, and `CORE` are capability states, not authority levels.
- A higher resource tier permits capacity; it does not prove network topology, model availability, signature validity, trust, or service health.
- Interface roles are assigned during commissioning and confirmed by an operator. They are not inferred solely from interface names or link state.
- Nexus must remain useful standalone. External AZ-04 Knowledge and AZ-06 Deception nodes extend capability and are never baseline dependencies.
- Any future Boot helper must declare its exact host changes and require explicit user approval; Boot has no general no-host-write or media-writer product claim.
- Failure or loss of optional cognition and advisory services falls back locally and deterministically.

## Observed compatibility state

The following pins were observed on each repository's `main` branch during the baseline audit. They expose compatibility work; they do not declare every combination interoperable.

| Repository | Observed product/package version | Observed Azazel-Fabric pin | R0 interpretation |
|---|---|---|---|
| Azazel-Fabric | package `0.8.0`; GitHub release `v0.8.0` published | self | Contract source of truth; documentation and compatibility claims require reconciliation |
| Azazel-Edge | repository has no single product package version | `v0.8.0` in `requirements/fabric.txt` | Reference authority implementation for Nexus integration |
| Azazel-Gadget | repository has no single product package version | `v0.4.0` in `requirements.txt` | Existing consumer retained in the compatibility matrix; not part of Nexus/Boot implementation scope |
| Azazel-Knowledge | package `0.1.0` | `v0.8.0` in the API optional dependency (`pyproject.toml`, `api` extra), moved from `v0.6.0` by Knowledge ADR-0016, commit `97bad3e` | Lite bundle and advisory interfaces must be aligned with the selected Fabric baseline |
| Azazel-Deception | package `0.2.0.dev0` | `v0.8.0` in `pyproject.toml` | Lite profiles and assurance claims must be made explicit and testable |
| Azazel-Nexus | no release baseline yet | none | Must adopt an explicit, tested Fabric pin before an implementation release |
| Azazel-Boot | package `0.0.0`, non-operational status scaffold; current helper host and toolset undecided | no Fabric pin | No current Fabric contract consumer; revisit only if an approved helper needs one |

Fabric `v0.8.0` is the current reference candidate: its source package and the Edge, Deception, and Knowledge pins agree, and a published release exists. Boot no longer pins or consumes Fabric; Nexus still has no pin, so the pins do not yet agree series-wide. The Fabric truth pass is complete ([Azazel-Fabric #20](https://github.com/01rabbit/Azazel-Fabric/issues/20), closed as completed 2026-09-18); what remains before `v0.8.0` can be called the program-wide locked baseline is consumer compatibility evidence, and no cross-repository conformance run against `v0.8.0` is linked from this document or the program plan.

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
| Azazel-Boot | [#1](https://github.com/01rabbit/Azazel-Boot/issues/1) | closed as not planned (2026-09-28) | The original USB-SSD product premise was superseded; retained bootstrap/governance files do not mean its hardware acceptance criteria passed |

A closed entry records either delivery of that historical issue's scope or an explicit scope retirement; it does not close unrelated R0 exit criteria below. Boot #1 was closed as not planned because its removable-media product premise was superseded on 2026-09-28. Do not reopen it for builder/writer work; see Boot ADR-0012.

## R0 exit criteria

- Product names, designations, audiences, and deployment boundaries are owner-ratified.
- The Fabric reference version and supported schema/API matrix are factual and tested.
- Every consumer has an explicit immutable Fabric pin or image lock.
- Edge authority and advisory-only boundaries are represented in contracts and integration tests.
- Installer inventory is non-destructive; commissioning produces a reviewable topology plan before applying it.
- Nexus RAM tiers of 8 GB, 16 GB, and 32 GB or more select resource envelopes independently of topology. (OF-01, Nexus target boundaries are 7168 / 15360 / 31744 MiB usable — each nominal size minus a 1024 MiB firmware-reservation allowance. Boot has no RAM-tier or resource-envelope contract.)
- Nexus publishes its security policy, support matrix, license, update channel, and recovery procedure before a release is called supported; Boot must define an approved helper scope and host contract before any operational release claim.
- Cross-repository conformance, degraded-mode, update, rollback, and recovery evidence is linked from the program plan.

Until all exit criteria pass, R0 artifacts are development baselines and must not be described as operationally certified releases.

## Open R0 findings

Findings raised against R0 that are not yet resolved. The full record lives in the program plan, §15; this list exists so that a reader of the exit criteria above sees what is known to be wrong with them. A finding is not a decision.

| Finding | Concerns | State |
|---|---|---|
| [OF-01](nexus-boot-program-plan.md#15-open-program-findings) — the RAM selector's thresholds contradict the tiers the program assumes | the Nexus 8/16/32 GB RAM-tier criterion and Nexus R2 selector; former Boot tier work was retired on 2026-09-28 | **resolved for the Nexus target rule 2026-09-19** ([#74](https://github.com/01rabbit/Azazel/issues/74)); measurement remains pending. Boot has no RAM selector or resource-envelope requirement |
| [OF-03](nexus-boot-program-plan.md#15-open-program-findings) — the firmware boot path and Secure Boot posture are undeclared | Nexus firmware compatibility and installation evidence; Boot firmware and image-builder scope retired 2026-09-28 | **resolved for Nexus target policy 2026-09-19** ([#79](https://github.com/01rabbit/Azazel/issues/79)); machine-specific verification remains open in Nexus. This finding imposes no Boot firmware or image requirement |
| [OF-02](nexus-boot-program-plan.md#15-open-program-findings) — the selector's four output values and the three capability states are never reconciled (`standard` vs `FULL`; `diagnostic` has no counterpart) | any product that must report a capability state derived from a selected tier | **resolved 2026-09-19** ([#77](https://github.com/01rabbit/Azazel/issues/77)) by owner decision: **there is no mapping** — a resource tier never derives a capability state, and the two are reported separately. As predicted, no contract changed: Fabric's provisioning contracts encode neither vocabulary |
| [OF-05](nexus-boot-program-plan.md#15-open-program-findings) — §8's lease-expiry completion bound is action-specific, and no action declares one | the program plan's §8 lease-expiry row and §5 R3 exit gate; `service-objective-assignments.md` SO-04 | **open**, raised 2026-09-19 ([#75](https://github.com/01rabbit/Azazel/issues/75)). The 5-second *start* bound is measurable and assigned. The completion half defers to a per-action value that exists in no repository, so it can neither pass nor fail. §4.3 gives a state for incompleteness (`ROLLBACK_INCOMPLETE`) but no time bound. Owner: Azazel-Edge |
| [OF-06](nexus-boot-program-plan.md#15-open-program-findings) — §8's hostile-load row presumes declared ingress quotas that do not exist | the program plan's §8 hostile-load row and §5 R5 exit gate; `service-objective-assignments.md` SO-11 | **open**, raised 2026-09-19 ([#75](https://github.com/01rabbit/Azazel/issues/75)). "At each declared ingress quota" ranges over an empty set in all seven repositories, which makes the condition vacuously satisfiable — a gate that reports a pass because there was nothing to check. Owner: Azazel-Edge (Core ingress), Azazel-Nexus (per-peer module) |
