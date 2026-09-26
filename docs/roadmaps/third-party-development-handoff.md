---
title: Third-Party Development Handoff
nav_exclude: true
---

# Azazel Series: Third-Party Development Handoff

Status: active development handoff baseline  
Last reviewed: 2026-09-19  
Audience: an external engineering team taking responsibility for one or more Azazel repositories.

This is the entry point for continuing the series without relying on private
context. It states the current product intent, authority boundaries, active
work ownership, and rules for extending the system without reviving retired
designs.

## 1. Read in this order

1. This handoff, then the [series naming specification](../specs/naming.md).
2. The [Nexus and Boot program plan](nexus-boot-program-plan.md) for the full
   cross-repository architecture, safety gates, and release evidence.
3. The [R0 product and compatibility baseline](nexus-boot-r0-baseline.md) for
   current targets, known version facts, and open R0 work.
4. The receiving repository's README, security policy, contribution rules,
   architecture/design documents, and tests.
5. The linked active Issue, its explicit acceptance criteria, and its current
   dependencies.

Do not treat an old closed issue, a historical changelog entry, an archived
roadmap, or a demonstration artifact as current product authority.

## 2. Permanent design decisions

| Decision | Required interpretation |
|---|---|
| Deterministic-first | Azazel-Edge-derived deterministic arbitration is the only decision and enforcement authority. |
| Advisory planes | M.I.O., Knowledge, local/remote models, and user interfaces provide bounded advice, explanations, or presentation; they cannot execute an action. |
| Deception plane | Deception materializes only an approved bounded environment; it does not select, authorize, or extend an engagement. |
| Fabric | Fabric owns reusable descriptive contracts and fixtures, never a decision core or deployment authority. |
| Standalone operation | Nexus and Boot remain useful in Core without external Knowledge, Deception, remote cognition, or cloud connectivity. |
| Capability gating | Effective capability is the intersection of resource, topology, verified assets, trust, and health. RAM alone never enables capture, enforcement, or deception. |
| Commissioning | Interface roles are based on inventory plus explicit operator confirmation. Never infer internal/external roles from names, link state, or a default route alone. |
| Failure behavior | Optional-component failure degrades `FULL -> LITE -> CORE`; it never grants a new authority or blocks the deterministic control path. |
| Evidence claims | Command success is not proof of network or tactical effect. Facts, inferences, and unknowns remain distinct. |

## 3. Product map and ownership

| Repository | Product responsibility | Do not put here |
|---|---|---|
| [Azazel](https://github.com/01rabbit/Azazel) | doctrine, naming, product map, series-level plans, authority rules | product runtime code |
| [Azazel-Edge](https://github.com/01rabbit/Azazel-Edge) | deterministic reference core, evidence/arbiter/audit semantics, bounded M.I.O. cognitive contracts, lightweight concept and Pi validation | generic rugged-PC installer assumptions or a second authority |
| [Azazel-Gadget](https://github.com/01rabbit/Azazel-Gadget) | constrained personal defensive implementation | general series contracts or Nexus deployment policy |
| [Azazel-Knowledge](https://github.com/01rabbit/Azazel-Knowledge) | advisory CTI and signed Knowledge Lite artifacts | commands, enforcement, or authoritative decisions |
| [Azazel-Fabric](https://github.com/01rabbit/Azazel-Fabric) | versioned shared contracts, fixtures, release truth | product policy, privileged execution, topology control |
| [Azazel-Deception](https://github.com/01rabbit/Azazel-Deception) | bounded environment materialization, evidence, reset | engagement choice, routing, final approval |
| [Azazel-Nexus](https://github.com/01rabbit/Azazel-Nexus) | persistent rugged x86_64 integration, commissioning, M.I.O. provider lifecycle, embedded Lite components, recovery, integrated HIL | a replacement decision authority or device-specific Edge defaults |
| [Azazel-Boot](https://github.com/01rabbit/Azazel-Boot) | civil emergency removable-media environment, per-host commissioning, portable encrypted evidence | writes to internal host storage by default or a promise to support unqualified hardware |

## 4. Edge and Nexus succession rule

Nexus is the successor integration product for validated Edge concepts. Edge is
not obsolete: it remains the reference implementation for deterministic core
behavior and a bounded proving ground for future concepts.

| Work type | Default home |
|---|---|
| Arbiter, evidence semantics, audit meaning, Outcome-as-Evidence, M.I.O. SituationFrame/hypothesis/grounding, no-model fallback | Edge |
| rugged x86_64 commissioning, model/provider operation, local/remote routing, Mission Packs, Knowledge Lite embedding, integrated degraded-mode and HIL | Nexus |
| reusable wire shapes, fixtures, compatibility and release truth | Fabric |
| signed knowledge content and full advisory-node behavior | Knowledge |
| bounded decoy runtime and reset evidence | Deception |

An experiment begins in Edge when it tests a lightweight core concept. It may be
adopted by Nexus only after its contract, authority boundary, failure behavior,
test evidence, and rollback/recovery behavior are explicit. A Nexus capability
is backported to Edge only through a new issue naming the minimal
reference-core value. Do not reopen a closed historical Edge issue as a
shortcut.

The detailed successor rule and the required inheritance ledger are tracked in
[Azazel-Nexus #7](https://github.com/01rabbit/Azazel-Nexus/issues/7).

## 5. Active starting points

### Nexus R0 integration

- [#2](https://github.com/01rabbit/Azazel-Nexus/issues/2): align specification, Fabric source of truth, and product-local provisioning.
- [#3](https://github.com/01rabbit/Azazel-Nexus/issues/3): signed offline M.I.O. Mission Pack lifecycle.
- [#4](https://github.com/01rabbit/Azazel-Nexus/issues/4): rugged x86_64 M.I.O. HIL and degraded-mode validation.
- [#5](https://github.com/01rabbit/Azazel-Nexus/issues/5): runtime profiles, local/remote routing, and deterministic degradation.
- [#6](https://github.com/01rabbit/Azazel-Nexus/issues/6): embedded Knowledge Lite and optional full-node advisory integration.
- [#7](https://github.com/01rabbit/Azazel-Nexus/issues/7): Edge-to-Nexus inheritance ledger and successor rules.

### Edge reference core and proof

- [#400](https://github.com/01rabbit/Azazel-Edge/issues/400): Outcome-as-Evidence proof; no hot-path replacement.
- [#372](https://github.com/01rabbit/Azazel-Edge/issues/372): Pi-class evaluation/replay evidence.
- [#305](https://github.com/01rabbit/Azazel-Edge/issues/305): bounded fact/observation export to Knowledge.
- [#408](https://github.com/01rabbit/Azazel-Edge/issues/408): current execution order and research gates.
- [#325](https://github.com/01rabbit/Azazel-Edge/issues/325) and [#358](https://github.com/01rabbit/Azazel-Edge/issues/358): Edge-controlled AZ-06 integration and security gates.

### R0 cross-repository work

- [Fabric release compatibility](https://github.com/01rabbit/Azazel-Fabric/blob/main/docs/release-compatibility.md): current release truth and observed consumer pins. The R0 truth-reconciliation issue is closed; do not reopen it for new integration work.
- [Knowledge #73](https://github.com/01rabbit/Azazel-Knowledge/issues/73): bounded signed Knowledge Lite artifact.
- [Deception #35](https://github.com/01rabbit/Azazel-Deception/issues/35): assurance truth and bounded Lite profiles.
- [Boot #1](https://github.com/01rabbit/Azazel-Boot/issues/1): safe removable-media product bootstrap.

## 6. Delivery rules for an external team

Before implementing, write or update an issue that names:

- the owning repository and the contract owner;
- the authority boundary and what must remain advisory/descriptive;
- exact release/pin or immutable image/asset version;
- resource, topology, verified-asset, trust, and health gates separately;
- standalone/degraded behavior and what is unavailable in each state;
- audit/provenance, rollback, recovery, and failure-injection expectations;
- test evidence required before making an operational claim.

Use released packages and signed assets. Do not copy product source trees into
Nexus or Boot. Do not convert a configuration overlay, package manifest, model
response, M.I.O. recommendation, or capability report into executable
authority.

For a change that affects a protected network, an installation path, a service
unit, enforcement, storage, trust, or recovery procedure, require a reviewed
implementation plan and a safe test environment before rollout.

## 7. Status language

Use these terms precisely:

- **target contract**: intended behavior; not yet release evidence;
- **implemented**: code and focused tests exist;
- **verified**: declared test/evidence gate has passed;
- **supported**: documented release, security/support posture, and operational
  evidence exist for the declared environment;
- **experimental**: bounded concept/HIL work; not a production claim;
- **retired**: intentionally not inherited; link the successor or rationale.

Never collapse these into a blanket claim that a product, model, environment,
or security property is complete.

## 8. Handoff completion check

An external team should be able to answer “yes” to all of the following before
starting implementation:

- Do we know which repository owns the requested behavior and which owns its
  shared contract?
- Can we identify the only decision/enforcement authority?
- Do we know the active issue rather than an archived or closed predecessor?
- Can the requested feature fail without breaking Core operation?
- Are resource capacity and topology eligibility being evaluated separately?
- Is there a testable rollback/recovery and audit story?
- Are we making only claims supported by current evidence?

If any answer is “no,” update this handoff or the owning issue before writing
product code.
