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

## Deployment products

- **Azazel-Boot Responder (AZ-03)** starts from removable USB SSD media for civil emergency use on a commissioned compatible laptop.
- **Azazel-Nexus Gateway (AZ-07)** is a persistent, self-contained deployment for a rugged x86_64 Linux PC.

Both consume shared Azazel-Fabric contracts and keep deterministic decision and enforcement authority in Azazel-Edge. Resource tier, interface topology, optional external services, and cognition availability may change capability, but never the authority boundary.

See also: [Delaying Action](../philosophy/delaying-action.md) | [Deterministic Defense](deterministic-defense.md)
