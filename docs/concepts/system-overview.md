---
title: Concepts
nav_order: 3
nav_exclude: false
---

# System Overview

Back to: [README](../../README.md) | Related: [Products](../products/README.md)

Azazel defines a defense doctrine centered on active control of attacker tempo.

Core loop:

- Detect
- Decide
- Delay
- Redirect
- Observe
- Buy time

This loop is implemented differently by each product variant while preserving shared principles and naming.

## Deployment and support products

- **Azazel-Boot Responder (AZ-03)** is a user-assistance/tooling companion for user-prepared Debian Live persistence and use of the existing Nexus tools installer. It does not create bootable media; separate-PC verification remains pending.
- **Azazel-Nexus Gateway (AZ-07)** is a persistent, self-contained deployment for a rugged x86_64 Linux PC.

Nexus consumes shared Azazel-Fabric contracts and keeps deterministic decision and enforcement authority in Azazel-Edge. Resource tier, interface topology, optional external services, and cognition availability may change capability, but never the authority boundary.

See also: [Delaying Action](../philosophy/delaying-action.md) | [Deterministic Defense](deterministic-defense.md)
