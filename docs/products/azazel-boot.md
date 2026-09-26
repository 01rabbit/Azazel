---
title: Azazel-Boot Responder
parent: Products
nav_order: 3
---

# Azazel-Boot Responder

Back to: [Products Index](README.md) | Related: [Product Map](product-map.md)

Azazel-Boot (AZ-03) is the removable-media responder workstream. Its safety
contract keeps host storage quarantined and separates artifact building from
media writing. Boot does not become an additional decision or enforcement
authority; Edge remains the sole arbiter.

## Current status

The current hardware-unverified prototype evidence is recorded in the
[Boot repository's R11 report](https://github.com/01rabbit/Azazel-Boot/blob/work/prototype-runtime-20260926/docs/prototype-evidence-boot-runtime-r11.md).
It covers an unsigned Debian 13 amd64 ISO, initramfs/C5 inspection, and a QEMU
cold-boot/userspace handoff with a regular-file block-device fixture. It is
prototype evidence only; the ISO is not a release image and the QEMU result is
not a hardware result. The Boot implementation and report are being reconciled
on the `work/prototype-runtime-20260926` branch; the default branch may not yet
contain them.

## Hardware-unverified boundary

No removable medium has been written and no laptop has booted. Real-device
hotplug behavior, physical host-storage quarantine, LUKS/TPM, firmware,
power-loss, recovery, and no-host-write HIL remain unverified. The compatibility
list remains empty; QEMU must not be interpreted as platform support.

The GitHub `main` Docs workflow currently fails before any step with runner
infrastructure evidence (`runner_id: 0`); it is not a package or hardware test
result. The configured default branch discrepancy is recorded in the series
audit and has not been changed.

## Decision boundary

Production builder selection remains open; `live-build` was used only for
prototype construction. No host disk or physical media was written, and no
storage was unlocked. Edge remains the sole decision/enforcement authority.

See the [series audit](../series-status-audit.md), the
[Boot repository](https://github.com/01rabbit/Azazel-Boot), and its
[support matrix](https://github.com/01rabbit/Azazel-Boot/blob/main/docs/support-matrix.md)
for the current evidence boundary.
