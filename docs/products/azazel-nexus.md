---
title: Azazel-Nexus Integrated Node
parent: Products
nav_order: 7
---

# Azazel-Nexus Integrated Node

Back to: [Products Index](README.md) | Related: [Product Map](product-map.md)

Azazel-Nexus (AZ-07) is the integrated field-node control plane for a rugged
Linux system. It integrates released components without creating a second
decision or enforcement authority: Fabric describes, Knowledge advises, Edge
decides and enforces, and Nexus commissions and presents the node.

## Current status

Current GitHub `main` at the audit baseline is
`375695a39ed52a53dc6dcaccfb6eacfad08cb96c`.

Software boundaries implemented and locally checked include:

- read-only inventory, resource profiling, commissioning and status CLI;
- activation controller, systemd unit policy, audit/watchdog boundaries and
  M.I.O. routing policy;
- offline Knowledge Lite import/quarantine/read-only serving;
- loopback-only Deception Lite lifecycle and state display;
- HIL preflight and refusal paths for unsupported or unmeasured targets.

These are software claims about the checked code and tests. They are not a
release, deployment, or hardware-support claim.

## Hardware-unverified boundary

No target rugged x86_64 Debian 13 node, 8 GiB measurement campaign, LUKS/TPM
state, NIC commissioning session, provider execution, or runtime HIL result is
available in this audit. The following therefore remain unverified:

- systemd enforcement and privilege boundaries on the target;
- Core reserve and local model-provider execution;
- commissioning against real interfaces and composite identities;
- storage, reboot, watchdog, power-loss and recovery behavior;
- external Knowledge/Deception deployment and any real endpoint or credential.

The repository contains no commissioned production endpoint, credential, real
model, or hardware identity. Those values must be supplied by an authorized
operator during a separately evidenced deployment; they are not inferred from
CI or fixtures.

## Authority boundary

Nexus must not become an alternate arbiter. It may display advisory context,
commissioned state, and verified evidence, but it cannot turn Knowledge,
Deception, a model provider, a package, or local capacity into an enforcement
decision. Provider admission and activation remain separate gates.

See the [Azazel series audit](../series-status-audit.md), the
[Nexus repository](https://github.com/01rabbit/Azazel-Nexus), and its
[support matrix](https://github.com/01rabbit/Azazel-Nexus/blob/main/docs/support-matrix.md)
for the current evidence boundary.
