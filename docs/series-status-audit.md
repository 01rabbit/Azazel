# Azazel series status audit

Audit date: 2026-09-24. This is a source-and-worktree audit, not a release
announcement. “Software complete” means the stated software boundary has been
implemented and locally checked; it never means deployed, hardware-verified, or
safe for an unreviewed environment.

## Evidence limits

GitHub inventory was retrieved on 2026-09-24 after the initial local-source
audit. Counts and the most recent `main` run below are a point-in-time snapshot,
not a substitute for each issue's body, comments, linked PRs, close reason, or
acceptance evidence. The issue numbers and candidate classifications below
come from the live open-issue inventory; they are not grounds for changing
issue state. Reconcile every acceptance checklist and linked evidence before
any closure or relabelling.

No real device, removable medium, TPM, LUKS volume, remote endpoint, credential,
or model was supplied. No hardware or network claim in this document is based
on a simulation or a unit test.

## Live GitHub inventory (2026-09-24)

| Repository | Open issues | Open PRs | Current-main checks at inspected SHA |
| --- | ---: | ---: | --- | --- |
| Azazel | 9 | 1 | `3889c546`: Pages build/deploy checks pass ([run](https://github.com/01rabbit/Azazel/actions/runs/35676530957)) |
| Azazel-Edge | 39 | 0 | `2a3e42d6`: Python, Rust, static, SBOM/dependency, and Pages checks pass ([run](https://github.com/01rabbit/Azazel-Edge/actions/runs/35551357435)) |
| Azazel-Nexus | 21 | 0 | `375695a3`: unit tests (3.11/3.12), install integration, import and pinned-Fabric checks, docs links pass ([CI](https://github.com/01rabbit/Azazel-Nexus/actions/runs/35676550679), [Docs](https://github.com/01rabbit/Azazel-Nexus/actions/runs/35676550659)) |
| Azazel-Boot | 25 | 0 | `24593009`: four checks failed before any step with `runner_id: 0`; infrastructure failure, no package/docs code result ([run](https://github.com/01rabbit/Azazel-Boot/actions/runs/35865046963)). A successful default-branch run is still required. |
| Azazel-Knowledge | 5 | 0 | `f29c29d1`: unit tests and config/docs-sync checks pass ([run](https://github.com/01rabbit/Azazel-Knowledge/actions/runs/35489021509)) |
| Azazel-Deception | 8 | 0 | `5ef49c96`: tests, portability, real-container lifecycle, virtual lab and Edge→AZ-06 E2E pass; none is physical HIL ([run](https://github.com/01rabbit/Azazel-Deception/actions/runs/35516725216)) |
| Azazel-Fabric | 4 | 0 | `07e6f82f`: test matrix for Python 3.10–3.12 passes ([run](https://github.com/01rabbit/Azazel-Fabric/actions/runs/35518603436)) |

## Repository inventory

The local HEAD column is the source state inspected for this audit. GitHub main
is recorded separately: do not infer that remote source was inspected by
reading a local branch at an older commit. Local documentation and implementation
changes listed in the worktree column are still uncommitted.

Azazel-Gadget is documented as a Fabric consumer and appears in Fabric's
compatibility tables, but it is not one of the seven repositories in this
audit's local/repository inventory; no Gadget checkout, issue inventory, or
hardware evidence is implied here.

| Repository | Audited local HEAD | Current GitHub `main` | Local worktree | Implemented boundary / conclusion | External evidence still needed |
| --- | --- | --- | --- | --- | --- |
| Azazel | `1e74d82d4025` | `3889c546635e` | `main`, local docs edits | Doctrine and product map; documentation hub, not runtime product. Remote source advanced and was not checked out. | n/a |
| Azazel-Edge | `0a1192052a13` | `2a3e42d653f6` | original feature branch + isolated `codex/edge-so-harness-414` worktree with uncommitted SO-07/logger/notification changes; original untracked `py/azazel_edge/mio/model_adapter.py.before-think-fix` preserved | Deterministic arbiter and evidence/audit. Isolated worktree adds durable P0 audit append, fail-closed recovery from malformed/torn tails, mandatory decision-ID-bound notification queueing with atomic/fsynced queue replacement, idempotent retry deduplication by decision ID, no notifier failover after audit failure, and process-safe audit-chain serialization. Current SO-07 process-kill report `r9` passes 55/55 over 11 record kinds × 5 write/flush/sync/report points; current SO-03 report `r10` passes 200/200 with a 2-second enqueue bound, verifies the resulting 400-entry audit chain, and explicitly records `hosted_ci=false` and `hardware_hil=false`; focused queue/audit/SO-07 tests pass 40, including rejection handling that does not record a sent notification. Declared-runtime full suite passes 897 with 45 skipped and 70 subtests when `gh` is excluded from PATH. Independent adversarial review passes for the SO-07 changes, and an fsync-before-write mutation fails 0/55. Hosted CI has not run; M.I.O. remains advisory and non-enforcing. | Review/merge/default-branch CI for local changes; SO-03 hosted evidence and visual/voice boundary, SO-04/OF-05, OF-06/SO-11, and physical power-cut/storage HIL. |
| Azazel-Nexus | `375695a39ed5` | `375695a39ed5` | original docs edits preserved; isolated `codex/nexus-failure-path-20260924` worktree carries the uncommitted fetch/handoff implementation and tests | CLI, commissioning, activation, audit/watchdog, Knowledge Lite, loopback Deception Lite, M.I.O. control plane, HIL preflight. Isolated latest-main handoff worktree adds guarded plan → fetch staging → existing `ModelImport` coordination and negative-path evidence; main CI and Docs pass at this commit. | Real endpoint/credential deployment, all HG-01–HG-07, target commissioning, Edge package health, and runtime HIL. |
| Azazel-Boot | `24593009a1c2` | `24593009a1c2` | `main`, local builder/quarantine/docs edits | Safe decision logic for artifact/media/writer, quarantine, persistence/dirty-write, and snapshot/recovery. No selected builder/image/writer service/initramfs/LUKS integration/operational CLI. | Main Docs run failed before steps: all four jobs had `runner_id: 0`; image, medium, laptop, and HIL evidence. |
| Azazel-Knowledge | `63c68fe82694` | `f29c29d10028` | original local docs state preserved; isolated `codex/knowledge-fixture-docs-20260924` worktree carries the uncommitted fixture correction | Advisory CTI, offline signed bundle/TAXII, local serving. Remote main advanced; latest-main isolated tests pass 1,213 with docs-sync. | Pi/LAN deployment, real Edge events, and latency evidence. |
| Azazel-Deception | `b48d5bd2cebe` | `5ef49c966b4c` | original local status state preserved; isolated current-main audit worktree carries the rc4 documentation correction | Package validation, placement, lifecycle/evidence/reset, non-enforcing adapter. Remote main advanced; control plane is not live-ready. | Isolation/egress, restart/drift, Edge-to-reset, keys, and hostile-host evidence. |
| Azazel-Fabric | `814f39d222a5` | `07e6f82f38df` | original local consumer-pin state preserved; isolated current-main audit worktree carries the table/test correction | Cross-product contracts; v0.9 remains a candidate. Remote main advanced; isolated current-main source-path suite passes 1,366 with 1 skipped and the full Ruff check passes. | Signed OCI/SBOM fixtures and actual producer/consumer/HIL adoption. |

## Next executable work and hardware boundary

This is an execution map, not an authorization to change GitHub state. Each
item is limited to the evidence and worktrees recorded above.

| Repository | Next executable software work | Work that requires hardware or external authority |
| --- | --- | --- |
| Azazel | Reconcile PR #63 and the doctrine/roadmap acceptance records; keep the umbrella documentation aligned with current product manifests. | None for the documentation hub. |
| Azazel-Edge | Submit the isolated SO-03/SO-07 evidence for owner-approved hosted CI/merge, and obtain owner decisions for SO-04/OF-05 and SO-11/OF-06. | Power-cut/storage durability, physical delivery, multi-writer behavior, and Raspberry Pi HIL. |
| Azazel-Nexus | Obtain owner-approved hosted Linux CI for the isolated #96 handoff while keeping plan, fetch staging, `ModelImport`, activation, and provider admission as separate gates. | Commissioned target, NIC/storage/TPM/LUKS checks, any real endpoint/credential, and HG-01–HG-07 HIL. |
| Azazel-Boot | Resolve ADR-0002, #47, and #49 decisions before selecting a builder, backend, writer, or recovery policy; continue contract-only negative-path tests. | Debian Live build host, removable medium, laptop compatibility, LUKS/TPM, initramfs quarantine, and B5 HIL. |
| Azazel-Knowledge | Preserve the isolated #107 fixture correction for owner review and integrate only when Edge/operator input contracts require it; keep docs-sync green. | Pi/LAN deployment, real Edge events, and latency/retention measurements. |
| Azazel-Deception | Resolve the #50 Fabric rc5 migration gate without changing the current pin; continue owner-approved external contract and live-gate review. | Host isolation/egress, hostile-host behavior, restart/drift, Edge-to-reset integration, and physical HIL. |
| Azazel-Fabric | Resolve #61/#56 trust-root and signing-key decisions; preserve the current consumer pins and release state until authorized. | None intrinsic; producer/consumer interoperability and signed OCI/SBOM adoption require authorized external fixtures. |

## Authority and dependency rules

Fabric describes. Knowledge advises. **Edge is the sole arbiter and enforcement
authority.** Nexus, Boot, M.I.O., and Deception must fail closed rather than
create an alternate authority. Knowledge and Deception are not synchronous
requirements for Edge’s deterministic decision path.

The inspected local source manifests were behind GitHub main for several
consumers. At the checked GitHub main commits, the declared exact Fabric pins
are Edge `v0.9.0rc4`, Knowledge `v0.9.0rc2`, Deception `v0.9.0rc4`, Nexus
`v0.9.0rc2`, and Boot `v0.9.0rc1`. The stale local source manifests still show
Knowledge `v0.6.0` and Deception `v0.8.0`; those values describe the older
local worktrees, not current GitHub main.

Fabric main's README and the upper consumer table in
`docs/release-compatibility.md` have stale consumer rows: they record Edge,
Knowledge, and Deception as `v0.9.0rc2`, while current main manifests record
Edge and Deception as `v0.9.0rc4` and Knowledge as `v0.9.0rc2`; the document's
later verification snapshot already records the Edge/Deception `rc4` values.
Nexus's optional `rc2` dependency and Boot's `rc1` agree with the inspected manifests.
Gadget's live README also carries an older `v0.4.0` statement while its live
`requirements.txt` declares `v0.8.0`; the local product page records the
declaration, not a deployment certification. These are documentation
mismatches, not permission to change any product pin.
Fabric main is at
`07e6f82f38df`; it includes the merged `v0.9.0rc5` candidate work, but no
product currently pins `rc5`. Fabric #61 remains an open signing-key
lifecycle/security issue; its hardening PR #62 is merged, but the issue body
explicitly says rotation is undecided and
does not authorize this audit to manipulate keys, signatures, tags, releases,
or pins.

## Live open-issue inventory and provisional classification

Issue numbers below were fetched from GitHub on 2026-09-24. All are currently
open. Classifications are provisional and based on issue bodies, available
comments, current-main source, and local evidence where explicitly noted; they
are not labels or closure decisions. Use the linked issue as the authoritative
acceptance record.

| Repository | Open issue numbers | Provisional classifications |
| --- | --- | --- |
| Azazel | #83, #68, #67, #66, #65, #64, #62, #61, #60 | #83/#66/#65/#64/#61/#60 `active implementation`; #68 `design decision required`; #67 `active implementation` (adversarial differentiation evidence); #62 `active implementation` pending reconciliation of doctrine PRs against acceptance criteria. |
| Azazel-Edge | #414, #412, #408, #400, #399, #398, #397, #396, #395, #394, #393, #392, #391, #390, #389, #388, #386, #385, #384, #383, #379, #375, #374, #373, #372, #369, #368, #358, #348, #347, #346, #344, #343, #342, #341, #340, #339, #325, #305 | `active implementation`: #414, #400, #305, #368, #369, #383–#389, #390, #391, #372; #412 and #373 `design decision required`/adversarial gate; #372 includes unmeasured Pi-class/runtime/model/resource evidence; #379 `active implementation` (repo-wide terminology migration); #392–#398/#399 are later protocol/research/planner/council/team-memory and adversarial-review stages; #339–#348 planned console track, not immediate critical path; #358/#325 require live AZ-06 safety gates. Roadmap #408 sequences immediate work at #400/#372 before later tracks. |
| Azazel-Nexus | #115, #100, #98, #97, #96, #93, #86, #85, #75, #70, #68, #56, #55, #53, #44, #17, #16, #6, #5, #4, #3 | #115/#100/#4 `blocked by external hardware`; #97/#98/#68/#44/#17 `software-complete / hardware-unverified` narrowly; #56's root/non-root CI coverage is added locally (88 targeted non-root tests pass; root suite/harness and hosted CI pending); #55/#5 audit-reason/provenance routing gaps; #96 transport plus guarded `acquire_and_handoff` plan→staging→`ModelImport` coordination are implemented in the isolated worktree (the current explicitly targeted security/boundary set passes 588 tests, including the composed FetchService→real loopback TLS transport→handoff→real `ModelImport` path, the commissioned-root-derived `/fetch` sink, fetch and inbox parent-symlink refusal, bounded missing-staging interruption, absolute-component root anchoring, dirfd-anchored handoff and cleanup, production FetchService.from_commissioned_root construction, lock-protected staging ownership through handoff, commissioned-root ModelImport mutation locking, lock-loser cleanup refusal, incomplete-transfer cleanup with replaced-inode preservation, symlink replacement refusal, path-replacement refusal under `O_NOFOLLOW`, digest path-traversal refusal, handoff-refusal fallback, sanitized import-boundary exceptions, tombstone cleanup race preservation, replaced-rendezvous cleanup safety, no-overwrite race, and file/directory fsync durability checks), while endpoint/credential deployment and HIL remain absent; #6/#16/#3 `active implementation`; #70 `design decision required`/review; #85/#86 decisions fixed but implementation not complete; #75 narrow status applies but evidence counts need refresh; #53 parent tracker. |
| Azazel-Boot | #55, #53, #52, #51, #50, #49, #48, #47, #42, #41, #40, #28, #27, #26, #17, #16, #12, #11, #10, #9, #8, #7, #6, #4, #1 | #1 `complete` for bootstrap scope only (close candidate; stale checkboxes and current Docs runner failure need reconciliation); #6/#7/#9/#10/#16/#17/#26/#27/#28/#48/#50/#51/#52 `active implementation`; #4/#11/#47 and #49's mitigation choice `design decision required`; #8/#12 `blocked by external hardware`; #40/#41/#42 `software-complete / hardware-unverified` only for narrow decision logic, with #47 still a separate software gap; #53/#55 `superseded` historical handoffs pending unique-criteria reconciliation. No issue closed. |
| Azazel-Knowledge | #107, #95, #66, #55, #21 | #107/#95/#66 `active implementation` (fixture description, read-only adapters, and research deliverables); #55 `active implementation` with software implementation demand-gated by Edge/operator need (design is complete); #21 `blocked by external hardware / field evidence`. |
| Azazel-Deception | #50, #41, #39, #35, #31, #30, #6, #3 | #50 `active implementation` / Fabric rc5 migration gate (do not change pin); #41 `blocked by external hardware`/HIL; #39 `active implementation` with external contracts and integration gates; #35 `active implementation` plus HIL; #31 software slice implemented but live integration/evidence remains; #30 `active implementation` (research deliverables remain); #6 `blocked by external hardware` and prerequisite safety/HIL gate; #3 `active implementation` (signed package and runtime evidence incomplete; not hardware-only). |
| Azazel-Fabric | #61, #56, #25, #23 | #61 `design decision required` for rotation/trust-root and active security remediation (hardening PR #62 is merged, issue remains open); #56 `design decision required` (whether tag signatures become a trust boundary); #25 `active implementation`; #23 `active implementation` (R1 residuals/R1c gates). |

The live PR inventory has one open PR in Azazel (#63, M.I.O. integration lab)
and zero in every other repository. PR #63 is reported mergeable but has no
review decision or check runs in the inspected API response; it is not merged
or evidence of M.I.O. validation. Its stated MacBook Pro M5 Pro scope is that
PR's proposed development lab, not a series compatibility or product support
claim. Merged PRs are not issue completion evidence by themselves.

### Evidence boundaries

Boot's current-main `Docs` workflow failure has four jobs with `runner_id: 0`,
no steps, and no runner name; it is infrastructure evidence, not a test result.
Additionally, GitHub currently reports Boot's `default_branch` as
`claude/zealous-edison-k5vt5j` (commit `45bc6bac717f0c64acae7705ee11e1daef258f57`),
not `main` (`24593009a1c268459a64e3a1c1dc874f1dee4da7`). The default branch is
behind and points to an older status-only commit. No branch-setting change was
made; this should be reconciled by the repository owner, and CI evidence on
`main` must not be mistaken for the configured default-branch check.
Current local Boot edits add quarantine/builder behavior but remain unreviewed
and unmerged, so are not GitHub-main completion evidence. The clean isolated
Boot audit worktree baseline passes 1,227 unit tests on the declared dependency
environment; its full Ruff check passes. The added quarantine capability check
is test-only and covers executed public decision paths, not unexecuted branches,
an initramfs, a real host disk, or hardware no-write behaviour. An independent
read-only review decomposes that result into 83 builder, 103 quarantine, and 19
boundary tests. It also confirms that permission evidence is contract-level
only: privilege refusal and audit-hook checks are present, but real uid/gid,
device-node, mount/udev, initramfs, and storage no-write behavior remain
unverified.
The original Boot clone has unrelated dirty builder/quarantine/docs edits and
was not rewritten or re-baselined here. Knowledge and Deception local test evidence applies to older
local HEADs, not newer GitHub-main commits: the isolated Knowledge latest-main
worktree passes 1,213 tests on Python 3.11 and docs-sync; Deception's local
source passes 590 tests with 8 skips when run with its source path. Nexus main CI and
Docs pass on its local baseline; the latest targeted security/boundary run has
588 pass; the latest macOS unit run has 3,175 pass, 4
skip, 39 platform-bound failures and 23 platform-bound errors. Edge's
isolated feature worktree, run with its
declared runtime and exact Fabric `v0.9.0rc4` dependency, reports 897 passed,
45 skipped and 70 subtests when `gh` is excluded from PATH; the same run with
the workstation's `gh` installed has two expected GitHub-degradation failures.
Edge's local branch is not current main and its local `origin/main`
ref is stale. Fabric main CI passes at `07e6f82f38df`,
while #61 remains open and its rotation proposal is not a decision. The local
Fabric checkout is older (`814f39d222a5`) and has dirty README /
compatibility-table edits; its source-path test run reports 1,405 passed and 3
failures, all from those two tables disagreeing on Edge, Knowledge, and
Deception pins. The separate current-main audit worktree corrected those two
tables to the directly observed declarations (Edge/Deception `rc4`, Knowledge
`rc2`); its full source-path suite now reports 1,366 passed and 1 skipped. This
is a documentation correction, not authorization to change
a consumer pin or Fabric release; the original dirty checkout remains
untouched.

Knowledge #107 now has a local, isolated latest-main documentation/test
correction: the `corrupt-truncated` fixture description identifies the
verifier's `BUNDLE_ARCHIVE_UNREADABLE` wrapper and preserved tar cause while
retaining the fail-closed guidance for unexpected exceptions. Full unit suite:
1,213 passed on Python 3.11 with the existing pinned Fabric dependency. This
work is uncommitted/unreviewed and does not change the live issue or main CI.

Deception was independently checked from current GitHub main
(`5ef49c966b4c`) in a clean audit worktree: `590 passed, 8 skipped` against
the declared Fabric `v0.9.0rc4` dependency. A stale `v0.9.0rc2` sentence in
`docs/safety-model.md` was synchronized to that existing pin; no dependency,
release, or live-gate claim changed. The original dirty Deception clone
remains untouched, and physical isolation/HIL evidence is still absent.

Nexus #96 was rechecked against its live issue comments and latest `main`:
planning, the separately signed Source Registry, TLS/pin transport, the
offline import verifier, and a guarded plan → fetch-service → staging →
`ModelImport` handoff now exist in the isolated worktree. The handoff rechecks
completion, digest, size and fixed staging identity, hashes through an
`O_NOFOLLOW` file descriptor, checks inode identity across hashing and the
non-overwriting link, does not echo resolver exception details into the
service reply, and the existing `ModelImport` inbox copy now also opens the
enumerated entry through an `O_NOFOLLOW` descriptor. The handoff does not grant
provider admission or activation authority. The fetch service now also binds
the request's model/source, digest, size and resume point to the resolved plan,
refuses malformed digest path traversal and staging symlinks, uses lock-
protected staging ownership, sanitizes import-authority exceptions, and uses a
non-overwriting rendezvous move when an
inbox race occurs. The current explicitly targeted security/boundary set passes 588
tests, including the composed loopback TLS transport and real
`acquire_and_handoff` coordinator with real `ModelImport` promotion and
incomplete-transfer cleanup, plus a safe fallback when the handoff boundary
refuses completed bytes. A subsequent full macOS run with the core and runtime
`ModelImport` now serializes public import and rollback mutations with a
commissioned-root lock. The independent adversarial review confirms the
production-constructor fixture E2E and lock ordering, while retaining the
explicit limitation that legacy `ModelImport` promotion paths remain
pathname-based after the dirfd-protected rendezvous.
distributions installed passes 3,175 tests, with 39 platform-bound failures
and 23 errors from Python-version, Unix-socket, `/proc`, and Linux
peer-credential assumptions; it is not a green cross-platform result. The
588-count run is reproducible with the declared Nexus environment and the
explicit 15-file target set: acquisition prohibitions, activation, artifact
egress, boundary static checks, model acquisition/handoff/catalog/fetchd/import/
runtime, packaging, provider registry, runtime boundary/hardening, and source
registry tests. It intentionally excludes the platform-bound socket/peer-
credential suite. The exact reproducibility command is:

```sh
TMPDIR=/tmp PYTHONPATH=src:runtime/src .venv/bin/pytest -q \
  tests/unit/test_acquisition_prohibitions.py tests/unit/test_activation.py \
  tests/unit/test_artifact_egress.py tests/unit/test_boundary_static.py \
  tests/unit/test_model_acquisition.py tests/unit/test_model_acquisition_handoff.py \
  tests/unit/test_model_catalog.py tests/unit/test_model_fetchd.py \
  tests/unit/test_model_import.py tests/unit/test_model_runtime.py \
  tests/unit/test_packaging.py tests/unit/test_provider_registry.py \
  tests/unit/test_runtime_boundary.py tests/unit/test_runtime_hardening.py \
  tests/unit/test_source_registry.py
```

The
docs-link check covers 51 Markdown files. The shipped endpoint
table is empty and no real endpoint, credential, download, or HIL evidence
exists, so #96 remains open and is not hardware-verified. The live issue body
still describes transport as not started; that issue text is stale relative to
this isolated software evidence and was not edited without user approval. No
Fabric pin or release was changed.

## Immediate, safe work

1. Continue reconciling recommendations above against live issue comments,
   linked PRs, close reasons, checks, and acceptance criteria before changing
   issue state.
2. Reconcile product documentation with actual consumer manifests and current
   GitHub main revisions without altering Fabric releases, tags, signatures,
   keys, or consumer pins.
3. Run each repository’s declared test command in its declared dependency
   environment. Edge's isolated feature worktree has now been run with its
   declared dependencies; the full suite passes when `gh` is excluded from
   PATH. Nexus's macOS failures were platform-specific and do not
   negate the green Linux CI, but are not a substitute for HIL either.
4. Continue Boot from its current `main` baseline with an independently
   reviewed build/writer boundary. Do not select a builder, download inputs,
   create a VM, mount a host disk, or write media without the explicit evidence
   and operator approvals required by its ADRs.
5. Run Nexus HIL only after a target owner and permitted hardware are available;
   its preflight and runbook must not become a claim of hardware verification.

## Completion evidence policy

An issue may move to `complete` only with its acceptance criteria and the
relevant test, negative-path, failure-path, review, and—where applicable—HIL
evidence. A merged PR, a documentation statement, a unit test, or a status
label alone is insufficient. Keep `software-complete / hardware-unverified`
issues open until their required physical evidence is recorded without raw MAC,
serial, TPM, or asset identifiers in external logs.
