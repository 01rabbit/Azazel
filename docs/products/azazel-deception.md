---
title: Azazel-Deception Host
parent: Products
nav_order: 6
---

# Azazel-Deception Host

Back to: [Products Index](README.md) | Related: [Product Map](product-map.md)

Azazel-Deception (AZ-06) is the engagement-environment plane. It materializes
only Edge-approved deception packages, records lifecycle evidence, and resets
without becoming an independent decision or enforcement authority.

## Current status

The current GitHub `main` audit baseline is
`5ef49c966b4c90f7bace8fdce6ddc03530f50c90`.

The current-main source was checked with the existing Fabric `v0.9.0rc4`
declaration: `590 passed, 8 skipped`. This is software evidence for package
validation, placement, lifecycle/evidence/reset behavior, and the non-enforcing
adapter boundary. It is not a deployment or hardware-support claim.

## Safety and authority boundary

- Edge remains the sole arbiter and enforcement authority.
- Deception consumes approved packages; it does not create or override an
  engagement decision.
- Live activation remains gated by the canonical Fabric contract and Edge
  authorization path.
- Unsupported capability, invalid package, failed verification, or unsafe host
  conditions must fail closed.

## Hardware-unverified boundary

No physical isolation, egress containment, hostile-host exercise, restart/drift
campaign, Edge-to-reset deployment, key ceremony, or physical HIL result is
available in this audit. The repository therefore does not claim a supported
Pi, x86, network, container runtime, or live engagement environment.

No real credential, endpoint, secret, host identity, or production package was
introduced by this audit. The current Fabric pin and release state were not
changed; the open Fabric rc5 migration gate remains an owner decision.

See the [series audit](../series-status-audit.md), the
[Deception repository](https://github.com/01rabbit/Azazel-Deception), and the
[container-first architecture](../concepts/azazel-deception-host-container-first.md)
for the evidence boundary and design context.
