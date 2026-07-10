# Azazel-Grimoire Advisor

Back to: [Products Index](README.md) | Related: [Deterministic Defense](../concepts/deterministic-defense.md)

Repository: [01rabbit/Azazel-Grimoire](https://github.com/01rabbit/Azazel-Grimoire)

Formal series designation: **`Azazel-Grimoire Advisor`**, series number **AZ-04**. Formerly `Azazel-CTI` (working name); see [Naming Convention](../specs/naming.md) for the ratified decision.

A grimoire never casts its own spells: this node holds the series' accumulated record of threats and reactions, but the reader — Azazel-Edge's deterministic arbiter — decides. Its generated detection rules are likewise drafts it never deploys.

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
