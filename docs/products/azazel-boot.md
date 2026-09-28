---
title: Azazel-Boot Responder
parent: Products
nav_order: 3
---

# Azazel-Boot Responder

Back to: [Products Index](README.md) | Related: [Product Map](product-map.md)

Azazel-Boot (AZ-03) is a user-assistance companion. The current intended flow
is for the user to prepare and start a Debian Live SSD, configure persistence,
use the existing Nexus tools installer, then check boot on a separate PC.
Boot does not install Debian, build/remaster LiveOS, write media, manage
persistence, or replace the Nexus installer. It creates no decision or
enforcement authority; Edge remains the sole arbiter.

## Current status

No exact Live image/SSD/PC combination has been qualified for the current
user-managed workflow. Former R10/R11 builder, initramfs, and QEMU records are
historical only; they do not verify this flow or satisfy its acceptance. See
the [user-prepared Live and Nexus guide](https://github.com/01rabbit/Azazel-Boot/blob/main/docs/user-prepared-live.md).

## Hardware-unverified boundary

No separate-PC boot result is recorded for the current workflow. Boot does not
claim host-storage quarantine or no-host-write behavior; Debian Live may probe
local storage for persistence. A future successful run applies only to the
exact user-supplied image, persistence configuration, Nexus release, SSD, and
PC tested. QEMU is not a substitute for that observation or a general support
claim.

## Decision boundary

No Boot image builder or media writer is in scope. The user supplies and
prepares the SSD; Boot's guide is non-mutating. Edge remains the sole
decision/enforcement authority.

See the [series audit](../series-status-audit.md), the
[Boot repository](https://github.com/01rabbit/Azazel-Boot), and its
[support matrix](https://github.com/01rabbit/Azazel-Boot/blob/main/docs/support-matrix.md)
for the current evidence boundary.

Development sequence and target gates are defined in the [Nexus and Boot
cross-repository plan](../roadmaps/nexus-boot-program-plan.md). A successful
single-PC observation does not establish general hardware support.
