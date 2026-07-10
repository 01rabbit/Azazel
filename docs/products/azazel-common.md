# Azazel-Common

Back to: [Products Index](README.md) | Related: [Naming Convention](../specs/naming.md)

Repository: [01rabbit/Azazel-Common](https://github.com/01rabbit/Azazel-Common)

Formal series designation: pending.

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

- **Azazel-Gadget**: consuming it in production, pinned to v0.2.0 (emits and reads `StatusView`).
- **Azazel-Edge**: design-stage adapter plan only.
- **Azazel-CTI**: adoption not yet decided.

## Package and License

- Distribution name `azazel-common`, import as `azazel_common`; current release v0.2.0.
- License: TBD (no LICENSE file yet).

See also: [Product Map](product-map.md) | [Naming Convention](../specs/naming.md)
