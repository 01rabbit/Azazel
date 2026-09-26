---
title: Azazel-Edge
parent: Products
nav_order: 1
---

# Azazel-Edge

Back to: [Products Index](README.md) | Related: [Deterministic Defense](../concepts/deterministic-defense.md)

Repository: [01rabbit/Azazel-Edge](https://github.com/01rabbit/Azazel-Edge)

Development codename: `SENTINEL` (see [Naming Convention](../specs/naming.md)).

Formerly known as `Azazel-Pi`.

## Role

Field-oriented edge SOC/NOC gateway for constrained or temporary networks.
Raspberry Pi 5 is a design target; physical deployment and HIL evidence remain
pending.

## Doctrine Implementation Focus

- Deterministic decision loop at the edge
- IDS-triggered response progression
- Delay and selective redirect actions
- Local operation with limited cloud dependency

## Typical Use Cases

- Temporary security monitoring in field networks
- Event and conference network defense staging
- Local response where internet connectivity is unreliable

See also: [Product Map](product-map.md) | [Delaying Action](../philosophy/delaying-action.md)
