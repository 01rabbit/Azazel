# Azazel-CTI

Back to: [Products Index](README.md) | Related: [Deterministic Defense](../concepts/deterministic-defense.md)

Repository: [01rabbit/Azazel-CTI](https://github.com/01rabbit/Azazel-CTI)

`Azazel-CTI` is a working name. Its ADR-0001 defers the formal series designation, so it is presented here under its working name until a naming spec extension lands. Formal series designation: pending.

## Role

Advisory-only, deterministic, on-premises tactical CTI node that supplies threat context to the deterministic edge without ever taking authority.

## Doctrine Implementation Focus

- **The CTI node never commands.** It returns threat context, confidence, reasons, and recommendations as advisory data only. Final authority always stays with Azazel-Edge's deterministic arbiter.
- **Fail-safe by absence.** Edge remains fully functional if the CTI node is absent, slow, or wrong.
- Offline-first operation: signed offline bundles plus optional scheduled feed pulls, so the query path carries no internet dependency.
- Deterministic, explainable scoring: the same inputs replay byte-for-byte, and every score carries a complete reason set.
- STIX 2.1 / TAXII 2.1 at the boundary only; SQLite for local storage.

## Typical Use Cases

- Enriching edge decisions with local threat context on constrained, on-premises hardware
- Deterministic, auditable scoring where explainability matters more than model complexity
- Behavioral CTI (Phase 2): reaction to pattern to similarity to advisory, shadow-gated, with no machine learning

## Target

Raspberry Pi 4, on-premises. MIT license.

See also: [Product Map](product-map.md) | [Deterministic Defense](../concepts/deterministic-defense.md)
