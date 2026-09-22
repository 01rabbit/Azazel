# Future platform profiles — kept, and kept out of v1

Status: **not a support statement.** Every profile below is a candidate for a
later evaluation. None is implemented, none is supported, and none appears in
any compatibility list. The v1 baseline is Debian 13 / amd64, fixed by
[program plan §15, finding OF-07](nexus-boot-program-plan.md).

This document exists so that the alternatives are **recorded in one place
rather than argued again in each repository**. A profile named here has not
been evaluated; it has been written down.

## Why one baseline, and why the others are not deleted

A hardware-in-the-loop measurement is taken under one kernel, one allocator and
one service manager, and those belong to the distribution. A campaign run
across two distributions produces evidence for neither, because nothing in
either product can say by how much they differ.

Deleting the alternatives would lose the reasons they were considered. Naming
them as supported would claim an evaluation nobody has run. Both failures are
avoided by keeping them here, in a document whose status line says what it is.

## The profiles

| profile | why it was considered | what would have to happen first |
| --- | --- | --- |
| **Ubuntu 26.04 LTS / amd64** | an LTS with a long support window, wide hardware enablement, and a signed shim chain already trusted by most firmware | a Debian 13 campaign passes; then a separate campaign measures this profile's own Core reserve, because a reserve does not transfer between distributions |
| **Fedora / amd64** | recent kernels reach hardware sooner, which matters for a rugged machine whose NICs are newer than an LTS kernel | as above, plus a position on a release cadence shorter than the program's own evidence cycle: a profile that moves faster than it can be measured cannot carry a measured claim |
| **RHEL family / amd64** (including rebuilds) | a long, contractual support window, and the family an operator's existing estate is most likely to already run | as above, plus a statement of which member of the family the evidence is for — a rebuild is a different entry until tested, by the same rule [support matrix](https://github.com/01rabbit/Azazel-Nexus/blob/main/docs/support-matrix.md) §5 applies to firmware versions |

## What is true of every row

- **No implementation work.** No packaging, no unit, no installer path, no image
  definition, and no CI job for any profile here.
- **No support claim.** Neither product's support matrix gains a row, and no
  document may describe a profile here as supported, qualified, tested, or
  recommended.
- **No compatibility-list entry.** A machine running one of these is not a
  qualified entry, whatever it is observed to do.
- **The gate is evidence, not preference.** A profile moves out of this document
  by a campaign with a recorded result, in a new program finding — not by
  somebody finding it convenient.

## What this document does not establish

- That any profile here will ever be adopted. Recording a candidate is not a
  plan to adopt it.
- That Debian 13 has been measured. It has not: OF-07's own verification clause
  says no image has been built and no host installed.
- That these are the only alternatives. They are the ones that were raised.
