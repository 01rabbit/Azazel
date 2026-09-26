---
title: Azazel-Fabric Contract
parent: Products
nav_order: 5
---

# Azazel-Fabric Contract

Back to: [Products Index](README.md) | Related: [Naming Convention](../specs/naming.md)

Repository: [01rabbit/Azazel-Fabric](https://github.com/01rabbit/Azazel-Fabric)

Development codename: `COVENANT` — the binding agreement the series' products sign. Codenames follow the series convention (see [Naming Convention](../specs/naming.md)) and never appear in formal external naming.

Formal series designation: **`Azazel-Fabric Contract`**, series number **AZ-05**. Formerly `Azazel-Common`; see [Naming Convention](../specs/naming.md) for the ratified decision.

Subtitle: **Shared contracts and interoperability foundation for the Azazel System**.

Azazel-Fabric holds the shared schemas, state representations, and exchange contracts — the series' common language. It is deliberately not a decision core; "Core" was avoided so it cannot be mistaken for an execution center above the arbiter.

## Role

The shared contracts library for the Azazel series — the common language spoken across products. It is deliberately **not** a decision core: it holds no arbiter, evaluator, or execution logic.

## Doctrine Implementation Focus

- Provides shared schemas and contracts so each product can interoperate without importing another product's decision logic.
- Enforces doctrine at the type boundary: the CTI advisory envelope carries an advisory-only invariant, and directive-shaped fields are rejected by validators.
- Single dependency (pydantic v2) and tag-pinned versioning so consumers pin an exact release.

## Modules

- `schema`: `StateSnapshot`, `ModeState`, `ActionIntent`, `AuditEvent`, `TrustCapsule`, `DecisionExplanation`.
- `cti_contracts`: the CTI advisory envelope with an enforced advisory-only invariant.
- `view`: `StatusView`, the shared status view-model.

## Consumer Status

- **Azazel-Gadget**: current GitHub `main` (`7aeb923`) declares the stable
  Fabric pin `v0.8.0` in `requirements.txt` and uses the `StatusView` boundary.
  This source declaration is not a production-deployment certification.
- **Azazel-Edge**: current GitHub `main` declares the optional candidate pin
  `v0.9.0rc4`; the arbiter remains usable without Fabric.
- **Azazel-Knowledge Advisor**: current GitHub `main` declares optional
  `v0.9.0rc2` for its API boundary; the core remains dependency-minimal.
- **Azazel-Deception**: current GitHub `main` declares candidate `v0.9.0rc4`.
- **Azazel-Nexus / Azazel-Boot**: current GitHub `main` declares optional
  pins `v0.9.0rc2` and `v0.9.0rc1`, respectively.

## Package and License

- Distribution name `azazel-fabric`, import as `azazel_fabric` (from v0.3.0;
  the v0.1.0/v0.2.0 tags keep the former `azazel-common` /
  `azazel_common` identifiers). The latest stable tag observed is `v0.8.0`;
  `v0.9.0rc5` is a candidate, not a stable release.
- License: MIT.

See also: [Product Map](product-map.md) | [Naming Convention](../specs/naming.md)
