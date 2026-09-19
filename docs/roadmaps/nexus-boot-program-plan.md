# Azazel Nexus and Boot Cross-Repository Development Plan

Status: proposed program baseline
Scope: Azazel, Azazel-Fabric, Azazel-Edge, Azazel-Knowledge, Azazel-Deception, Azazel-Nexus, and Azazel-Boot

## 1. Purpose

This plan coordinates two deployment products that share Azazel contracts and defensive components:

- **Azazel-Nexus** is a persistent installation on a rugged Linux PC for sustained field operation. It contains Edge, local cognition, Knowledge Lite, Deception Lite, operator functions, audit, and network enforcement. External Knowledge and Deception nodes expand capacity.
- **Azazel-Boot** is a civil emergency environment started from a bootable USB SSD on varied laptop hardware. It favors rapid startup, limited host modification, clear operator setup, and encrypted portable evidence.

The program reuses existing product implementations through released packages and signed assets. It does not copy source trees into Nexus or Boot.

## 2. Permanent authority and ownership rules

The series rule applies to every phase:

> Fabric describes. Knowledge advises. Edge decides and enforces. Deception materializes an Edge-approved environment. Nexus and Boot integrate these products without creating another decision authority.

| Concern | Owning repository | Other repositories may do |
| --- | --- | --- |
| Series doctrine, naming, product map | Azazel | Link and conform |
| Shared schemas, canonical bytes, validation, test fixtures | Azazel-Fabric | Pin a released tag and implement adapters |
| Evidence, deterministic evaluation, arbiter, enforcement | Azazel-Edge | Configure and call published interfaces |
| Full knowledge, correlation, signed tactical bundle production | Azazel-Knowledge | Consume advisory results or verified bundles |
| Deception packages, safe lifecycle, evidence export | Azazel-Deception | Request only through an Edge-approved lease |
| Persistent appliance integration and embedded Lite runtimes | Azazel-Nexus | Assemble released components and hold deployment policy |
| Portable emergency environment and per-boot setup | Azazel-Boot | Assemble released components within the Boot profile |

Fabric owns representations and deterministic, side-effect-free validation. Filesystem writes, package installation, network changes, model execution, container lifecycle, and operator rendering remain in the product that performs them.

## 3. Program dependency graph

```text
Azazel doctrine and product definitions
                  |
                  v
Fabric provisioning + mission-profile contracts
      |                 |                    |
      v                 v                    v
Edge adapters     Knowledge bundles    Deception packages
      \                 |                    /
       \                |                   /
        +---------- Nexus integration -----+
        |                                   |
        +----------- Boot integration ------+
                         |
                         v
              cross-product release gate
```

The critical path is Fabric contract release -> producer/consumer adapters -> Nexus/Boot integration -> hardware and emergency exercises. Product-local implementation that does not depend on a new contract may proceed in parallel.

### 3.1 Independent admission dimensions

RAM capacity does not prove that a host can safely capture, enforce, or isolate deception traffic. Nexus and Boot compute effective capability from independent records:

```text
effective capability = resource profile
                     ∩ topology profile
                     ∩ verified asset set
                     ∩ current trust/health state
```

`ResourceProfile` records CPU, usable RAM, storage, and thermal/power budgets. `TopologyProfile` records commissioned interfaces, capture support, management reachability, and proven isolation properties. A 32 GB host with one unsuitable NIC may qualify for Standard local cognition while remaining in observe-only Core networking and keeping Deception disabled. The UI shows each capability state as well as the overall `CORE`, `LITE`, or `FULL` summary.

## 4. Shared configuration and release flow

Each source repository publishes a versioned artifact. Nexus and Boot import it through a product adapter, apply a deployment overlay, validate the result against Fabric, render runtime configuration, and activate it transactionally.

```text
released source artifact + deployment overlay
                  |
          parse and normalize
                  |
          Fabric validation
                  |
            dry-run plan
                  |
       operator review and approval
                  |
     render to a staging directory
                  |
        activate and health-check
                  |
      receipt or explicit rollback state
```

Rules:

1. Source settings and signed packages are read-only inputs.
2. Site changes are overlays with author, reason, base digest, schema version, and expiry where appropriate.
3. Generated files are disposable output under `/run`; an operator edits the overlay, not generated Suricata, nftables, model, or container files.
4. An adapter accepts a declared range of source and Fabric versions. Unknown or incompatible versions fail during dry-run.
5. Activation is a product-local, generation-based transaction with declared irreversible effects. No plan may promise that packets already forwarded, conntrack state, or external observations can be undone.
6. Every release records component versions, hashes, signatures, SBOM references, profile, hardware inventory, and applied overlay digest.

### 4.1 Product-local admission

Cryptographic authenticity is one input to admission. Nexus and Boot independently require all of these gates in order:

```text
authenticity
  -> exact tested compatibility tuple
  -> semantic content policy
  -> resource/topology admission
  -> operator or policy-authority approval
  -> staged activation
```

The product admission policy uses separately provisioned offline roots and delegated roles for OS images, Edge packages, Knowledge bundles, Deception packages, models, and emergency overlays. It records threshold rules, rotation, revocation, target product/profile/architecture, required feature IDs, minimum security epoch, and maximum rollback version. A signature from the wrong role or a correctly signed obsolete/incompatible artifact is rejected. An installation-generated device key proves local continuity only until a site/operator identity enrolls it.

Field releases use a deny-by-default set of tested tuples containing exact artifact and adapter/compiler digests, schema features, OS ABI, CPU features, architecture, profile, and overlay schema. Broad version ranges are descriptive compatibility claims and cannot authorize activation.

### 4.2 Configuration ownership and staged activation

Every configurable field has an owner and allowed mutable layer. Deployment overlays may bind commissioned interfaces, choose an allowed component subset, reduce resource limits, and add labels. Edge action policy, approval requirements, lease ceilings, trust roots, signing-key locations, executable commands, routes, firewall rules, services, container mounts/capabilities, and authority fields cannot be changed by a deployment overlay.

The product activation controller is the only component permitted to unmask operational services and issue generation-scoped systemd credentials. It validates the operator/site signature, hardware inventory digest, policy digest, security epoch, generation counter, expiry, renderer digest, and every generated-file digest on every boot. Operational units are preset disabled and remain unavailable without a verified generation.

Activation follows this order:

1. validate inputs and product-local admission policy;
2. render into a private versioned staging directory with bounded unprivileged extractors;
3. preflight configuration and establish a local-console or independent-management failsafe;
4. install a deny exposure barrier, then atomically switch policy-owned kernel objects;
5. start passive sensors and verify actual state;
6. enable bounded routes and Deception last;
7. persist the authoritative receipt and required audit checkpoint before reporting completion.

Each adapter owns tagged resources and supplies idempotent apply, undo, and reconcile operations with before/after generation hashes. Failure withdraws exposure, expires affected leases, stops or quarantines Deception, restores only owned last-known-good resources, and reports `ROLLBACK_INCOMPLETE` until observed state matches. Software rollback never restores obsolete trust state, policy, or hardware bindings.

### 4.3 Time, lease, and management safety

Temporary action leases use a boot/session-bound monotonic deadline and a durable trusted absolute deadline; the earlier safe deadline wins. Persisted leases never resume after reboot without reauthorization. When time is untrusted, new disruptive actions stop and existing actions follow their predeclared safe expiry/fence behavior. Overlapping actions serialize on a resource key and rollback removes intent-owned handles rather than replacing an entire ruleset.

Before the first disruptive kernel mutation, the enforcement supervisor persists and synchronizes the intent, lease, owned-resource record, expiry, and release task. The operation order is `prepare + fsync -> apply -> verify -> persist receipt`. A prepare or sync failure produces zero kernel changes. Recovery reconciles every tagged kernel object to a durable owner/release record before accepting new work.

Policy signing, intent signing, update signing, commissioning approval, audit checkpoint, and recovery use separate credential roles. Only the Edge arbiter workload identity can use the intent-signing credential. Activation and rendering may install a sealed/systemd credential for that identity but cannot read or reuse it. Enforcement verifies both the signature and authenticated arbiter workload identity.

Management paths are excluded from ordinary action scope. A high-impact network change requires an independent management path or physical local console and a two-stage commit: if the operator does not acknowledge verified reachability within the lease window, the enforcement supervisor rolls it back. Single-interface Boot systems default to observe/evaluate/explain/audit and expose enforcement eligibility separately.

### 4.4 Bounded artifact handling

The product extractor accepts declared regular files only and rejects absolute/traversal paths, symlinks, hardlinks, devices, FIFOs, sparse files, nested archives, duplicate or Unicode/case-colliding normalized paths, unexpected metadata, and undeclared output. It enforces compressed size, expanded size, file count, per-file size, path depth, inode, time, and staging-volume quotas. It hashes while writing, syncs, reopens without following links, rehashes, validates semantics, and then promotes a complete tree. Delta bundles require an exact base digest and declared final tree digest.

Model admission additionally restricts formats, tokenizer formats, parser/runtime versions, quantization, context size, and memory needs. Model-supplied code, dynamic loaders, native plugins, pickle-like executable serialization, tools, and network fetch during load are forbidden. Models run under a dedicated account with read-only assets, no secrets, no control sockets, no network by default, syscall/LSM confinement, and hard cgroup budgets.

### 4.5 Audit, persistence, and recovery state

Core audit, intent/lease journal, evidence, Deception telemetry, Knowledge cache, models, extraction staging, and Boot persistence use separate quotas or filesystems. The Core audit and lease journal have reserved space, I/O, memory, and process priority. Untrusted inputs have bounded item size, rate, cardinality, concurrency, bytes, and inodes; pressure quarantines or sheds the source before consuming Core reserves, with durable loss counters and visible sensor health.

A product checkpoint binds product/node/boot identity, log/security epoch, monotonic sequence, previous checkpoint, current head, active versions, policy/inventory generation, and wall/monotonic time. Nexus uses a TPM-backed counter where available and an independent signed anchor receipt. Boot uses two-copy signed checkpoints and an operator-carried or remote anchor when available. Audit assurance profiles distinguish `ROLLBACK_ANCHORED` from `LOCAL_CONTINUITY_ONLY`. The latter forbids live Deception, disruptive actions, and claims of rollback-verified finalized evidence unless a named emergency policy records explicit operator acceptance; exports are labeled as locally consistent and not rollback verified. Failure of a required anchor receipt fences new high-impact work, withdraws exposure according to the active lease, preserves observation, and creates a visible custody exception. Activation, action completion, update, evidence finalization, and shutdown require a synchronous checkpoint according to policy. Recovery authority cannot sign ordinary field checkpoints or hide a discontinuity.

Boot creates encrypted persistence on first use outside the reproducible base image. It uses journal/WAL and explicit sync boundaries, redundant metadata, a dirty-shutdown marker, boot-time repair/quarantine, and separate security state. USB cloning creates a new node/session identity and carries no active or one-shot lease. Surprise USB removal fences new actions; a RAM-resident supervisor withdraws owned disruptive rules and routes independently of persistence, then shows a reboot requirement.

## 5. Program releases and gates

These releases are capability gates rather than calendar commitments. A gate closes only when its evidence is stored and review findings are resolved.

### R0 — Baseline and ownership freeze

Deliverables:

- ratify Nexus and Boot product definitions in Azazel;
- decide whether the existing `Azazel-Boot Probe` designation accurately covers the intended emergency control capabilities and update the naming record if it does not;
- create a cross-repository compatibility matrix and release vocabulary;
- record existing Fabric pins and identify obsolete plans or conflicting status claims; the initial audit must reconcile Fabric's package version `0.8.0` with older README examples, Knowledge's current pin with older adoption prose, and Deception's current pin with older status prose;
- define evidence required from software tests, virtual labs, and physical hardware tests;
- create one issue in each repository for its workstream and link it to this plan.

Exit gate:

- every contract and runtime capability has one owner;
- no required item is assigned to two repositories or to none;
- current stable release pins are reproducible from a clean environment.

### R1 — Fabric provisioning contract release

Deliverables:

- add `provisioning_contracts` with `HardwareInventory`, `ResourceProfile`, `TopologyProfile`, `ProductManifest`, `AssetManifest`, `ModelManifest`, `InterfaceAssignment`, `CommissioningRecord`, `ProposedGenerationDescriptor`, observation-only `ActivationReceipt`, and `CompatibilityManifest`;
- add `mio_contracts` for local situation frames, sanitized remote frames, advisory results, and provenance-preserving merge output;
- define Nexus and Boot product names in open extension registries;
- provide canonical serialization, digest helpers, rejection of directive-bearing advisory fields, and golden fixtures;
- publish a feature-to-minimum-Fabric-version matrix so products can converge deliberately without forcing an untested simultaneous pin change;
- recursively reject command, unit, route, firewall, device-path, executor, boolean authorization, and trust-decision fields from descriptive provisioning objects;
- define audit checkpoint, security-state, privacy, bounded-artifact, and structured claim-set projections while leaving trust decisions and chain enforcement product-local;
- execute the release in three steps: R1a draft schema/conformance kit, R1b signed release-candidate digest, and R1c stable tag after downstream evidence.

Exit gate:

- all new models round-trip through canonical JSON;
- malformed, directive-bearing, unknown-version, expired, and digest-mismatched fixtures fail closed;
- Edge, Knowledge, Deception, Nexus, and Boot candidate adapters pass the same golden fixtures;
- the release contains no installer, decision, network, container, or model execution code.
- static checks confirm that the new modules do not import operating-system probing, network, subprocess, installer, or runtime-control code.
- Fabric CI runs only Fabric code and fixtures; each consumer pins the candidate digest and publishes a signed conformance attestation that a separate program workflow aggregates.
- each nonexperimental cross-product contract has at least one real producer and two real consumers before R1c.

### R2 — Installer and commissioning foundation

Deliverables:

- Nexus base installer and Boot image builder consume the same Fabric provisioning contracts;
- detect usable RAM in MiB after firmware reservation through one product-local selector: less than 7168 diagnostic, 7168–15359 `core`, 15360–31743 `lite`, and 31744 or more `standard`, subject to the measured Core reserve. Each boundary is the nominal size it admits **minus a 1024 MiB firmware-reservation allowance** (8192−1024, 16384−1024, 32768−1024); see [OF-01](#of-01--the-ram-selectors-thresholds-contradict-the-tiers-the-plan-assumes) for why the boundaries are not the nominal sizes themselves;
- evaluate the resource and topology profiles separately and enable only their verified intersection;
- inventory interfaces by stable identity and keep all operational roles unassigned until commissioning;
- use a composite interface identity (bus path, permanent MAC, VID/PID or PCI identity, serial where present, driver/firmware, wireless PHY, and physical label); zero or multiple matches fail closed and MAC-only matching is insufficient;
- provide one guided setup flow for administrator identity, encrypted storage, deployment profile, asset source, network roles, validation, and activation;
- support signed online manifests and encrypted offline installation bundles through the product-local release-admission policy;
- implement a separate `ASSET_ACQUISITION` state using one operator-selected interface in an outbound-only namespace with endpoint allowlists, metadata/certificate pinning, no forwarding or listening services, bounded downloads, and cleanup of routes, credentials, DNS, proxy state, and association;
- render Suricata and product configuration only after an operator confirms interface roles;
- record a signed installation inventory and activation receipt.
- close the commissioning service after activation; re-entry requires a physical local action, strong administrator authentication, maintenance state, and explicit handling of active leases before roles can change.

> **OF-01 (§15) is resolved.** The boundaries above were moved on 2026-09-19 so that a host of each nominal class reaches the tier named after it. They are derived, not chosen: nominal minus a stated 1024 MiB firmware-reservation allowance. No product may substitute its own numbers; a product that believes the allowance is wrong raises a finding rather than diverging locally.

Exit gate:

- a nontechnical operator can complete a clean installation or USB startup from the written quick-start guide;
- outside the bounded `ASSET_ACQUISITION` state, no capture, forwarding, Wi-Fi association, external module link, or remote cognition starts before commissioning;
- changed NIC identity returns the affected capability to `COMMISSIONING_REQUIRED`;
- model download or verification failure leaves a working Core environment.
- old-generation replay, renderer/config replacement, path substitution, parallel boot races, and service-default fallback produce zero operational packets/actions.
- a deployment overlay cannot weaken Edge approval, scope, lease, policy, or trust settings.
- observation roles remain Layer-3 unnumbered and transmit zero DHCP, RA, mDNS, LLDP, Wi-Fi probe, or other packets through link flap, resume, and driver reload tests.

### R3 — Deterministic Core integration

Deliverables:

- package Edge evidence, evaluator, arbiter, enforcement, explanation, and audit interfaces for x86_64 systemd deployment;
- preserve existing constrained-device support as a separate compatibility profile; Nexus and Boot do not call the current device-specific network installer;
- add a Nexus/Boot adapter without moving Edge authority into the integrator;
- map Fabric evidence, decision, receipt, state, audit, and notification projections alongside Edge-native records;
- generate capture configuration for one or more approved observation interfaces;
- implement action leases, idempotency, effective-state verification, rollback, and adapter fencing;
- expose Core health through the common status view.

Exit gate:

- the same captured scenario yields byte-stable deterministic decisions on replay;
- M.I.O., Knowledge, Deception, UI, Nexus, and Boot cannot call privileged enforcement directly;
- an expired, replayed, widened, or unsigned action is rejected and audited;
- enforcement verification failure fences new actions for the affected scope and preserves lease expiry.
- clock jumps, reboot, overlapping leases, resource drift, audit pressure, and supervisor failure cannot extend a lease or remove another action's resources.
- management lockout tests prove two-stage rollback through an independent path or physical console.
- injected ENOSPC, EIO, and sync failures before and after each apply transition prove zero unjournaled kernel mutation and a recoverable release record for every applied object.
- each adjacent service identity fails to read/use the arbiter credential, forge or replay a signed intent under another identity, or connect directly to enforcement; each attempt is audited.

### R4 — Embedded Lite capability

Deliverables:

- Knowledge publishes a signed, size-bounded tactical bundle profile for Knowledge Lite;
- Nexus and Boot implement a read-only cache runtime that preserves citations and freshness labels;
- Deception publishes a Lite package tier with explicit resource and isolation requirements;
- use neutral artifact profile IDs such as `nexus-embedded-lite`, `boot-emergency-lite`, `knowledge-full-node`, and `deception-full-host`; deployment policy remains in product overlays;
- Nexus implements Deception Lite on a dedicated bridge; Boot enables it only after current-host isolation tests pass;
- local M.I.O. uses an approved resource-specific model and a Fabric advisory result contract;
- resource governor reserves Core CPU, memory, I/O, PIDs, audit space, and lease-journal capacity; it sheds remote work, optional model work, background imports, Deception expansion, and then Deception before reducing security-relevant capture.
- continuously evaluate a product-owned isolation attestation over interface identities, routes, ruleset generation, namespaces, sysctls, DNS, IPv4/IPv6/link-local/multicast reachability, and allowed peers.

Exit gate:

- Nexus completes detect -> explain -> decide -> redirect -> audit without external nodes;
- Boot completes the Core loop on 8 GB and adds verified Lite functions at 16 GB (this gate was unmeetable as written until **OF-01** was resolved on 2026-09-19; under the corrected R2 boundaries a nominal 8 GB host reaches `core` and a nominal 16 GB host reaches `lite`, provided its firmware reserves no more than 1024 MiB);
- invalid knowledge is rejected; dataset-specific expiry, decay, and confidence ceilings make expired security-sensitive entries unavailable and preserve material staleness through M.I.O. narrative and voice;
- a decoy cannot reach protected, management, control-plane, or Internet zones in the physical test topology.
- the isolation test covers IPv4, IPv6, DNS, link-local, multicast, container gateways, host services, and runtime sockets.
- isolation drift installs a kernel drop/quarantine barrier and withdraws the route before runtime cleanup; telemetry flood cannot consume the reserved Core audit/lease capacity.
- malformed model/parser/tokenizer assets cannot execute code or access evidence, secrets, control sockets, or a network.

### R5 — Full Knowledge and Deception extensions

Deliverables:

- Nexus module manager discovers only provisioned AZ-04/AZ-06 peers, then verifies mTLS identity, signed manifest, version, role, freshness, and segmentation;
- Knowledge supplies signed tactical bundle synchronization plus cited full context;
- Deception accepts bounded, expiring Edge decisions and exports evidence/outcomes through Fabric contracts;
- Nexus selects Lite or Full destinations according to deterministic policy;
- Knowledge routing is a pure, transaction-pinned decision over compatibility, authenticated health, deadline, freshness, generation, and circuit-breaker epoch; deterministic hysteresis, cooldown, and a minimum stable-health window prevent cross-transaction flapping. The replay record contains route inputs, source/reason, both generations, and breaker epoch; conflicting Full/Lite claims remain separate and cited;
- Lite/Full Deception switching uses a unique environment/lease namespace and one active route binding per selector, with prepare, old-route withdrawal, new binding, verification, and old-environment cleanup;
- Boot can consume a preapproved emergency Knowledge bundle; live external modules remain an explicit deployment option.

Exit gate:

- external nodes add context or engagement capacity without changing Edge authority;
- module loss, identity change, expired manifest, bad signature, or failed isolation produces `FULL -> LITE` with an audit event;
- no sensitive raw evidence crosses a module boundary outside its declared contract;
- loss of either external node does not interrupt Core operation.
- valid-certificate slow streams, oversized responses, decompression, cloned module state, replayed health, and response floods remain within per-peer quotas and Core service objectives.

### R6 — M.I.O. dual cognition

Deliverables:

- local-first cognitive router with explicit deadlines and resource budgets;
- allowlist sanitizer with privacy classes, aliases deterministic only within a declared mission/request scope, redaction records, rate/size limits, and deny-on-ambiguity;
- egress-only remote adapter using an approved endpoint and workload identity;
- merger that preserves claim provenance and displays disagreement;
- one closed untrusted-output policy for local and remote models, including parser bounds, Unicode/control normalization, inert rendering, no links/tools/file access, and no imperative action path;
- mission- or request-scoped aliases, coarse time/count buckets, bounded cadence/size classes, provider retention/region admission data, and cumulative privacy budgets;
- deterministic voice queue independent of model output, followed by optional M.I.O. explanation;
- UI presentation for `CORE ONLY`, `LOCAL`, and `HYBRID` states.

Exit gate:

- restricted frames and sanitizer failures produce zero remote egress;
- malformed or hostile remote responses render as inert advisory text;
- local/remote disagreement cannot change an active Edge decision;
- remote loss returns to local cognition, and local-model loss returns to deterministic Core explanations.
- the merger freezes a structured claim set with source/model/generation/input/freshness/confidence/limitations before producing narrative text; contradictions remain separate and replayable.
- a remote response cannot request or trigger follow-up disclosure; every follow-up is a new locally constructed and audited sanitized frame.
- privacy tests prove alias consistency within its declared lifetime and different mappings across missions/requests after key rotation; cross-mission correlation is prohibited.

### R7 — Product-specific field readiness

Nexus deliverables:

- LUKS2 storage, TPM-sealed key option, measured boot evidence, A/B update, recovery media, long-duration audit retention, power-loss handling, and rugged-PC hardware qualification;
- HIL exercises for all approved NIC layouts, disk pressure, thermal pressure, battery shutdown, clock anomaly, adapter restart, and route drift.

Boot deliverables:

- signed immutable A/B boot image, read-only root, redundant signed boot metadata, one-shot trial boot, encrypted USB persistence with dirty-shutdown recovery, and an explicit no-host-storage-write rule;
- quarantine non-Boot block devices in the initramfs before activation: no host swap/resume, automount, filesystem repair/journal replay, LVM/md/ZFS activation, firmware updater, enrollment tool, or write-capable host mount;
- define `VERIFIED_FIRMWARE`, `EXTERNALLY_VERIFIED_MEDIA`, and `UNVERIFIED_PLATFORM` trust classes and limit integrity/evidence claims to their demonstrated assurance;
- per-host commissioning, driver inventory, temporary setup connection, portable evidence export, controlled shutdown, and a USB removal procedure;
- emergency operator workflow tested on a declared laptop compatibility set.

Exit gate:

- a failed update returns to the prior verified generation without losing the last valid audit checkpoint;
- Nexus passes a sustained field workload for its resource tier;
- Boot starts on every supported compatibility-class device and leaves internal storage unchanged in the verification test;
- Boot HIL records zero content writes to internal block devices until an operator explicitly selects an export target, and separately reports any unavoidable firmware NVRAM change;
- recovery procedures are executable from offline media by an operator who did not build the system.
- power interruption after every inactive-slot, boot-metadata, checkpoint, and persistence-migration write leaves one verified bootable generation and the last valid audit checkpoint recoverable; a failed trial restores any required persistence snapshot.

### R8 — Cross-product release candidate

Deliverables:

- exact released component pins, SBOMs, signatures, source revisions, migration notes, and compatibility matrix;
- clean-room Nexus installation and Boot media build from released artifacts only;
- full scenario replay, failure injection, recovery, and evidence export;
- two independent builders reproduce the unsigned immutable payload digest from pinned toolchain and repository snapshots; signatures attest that subject digest separately;
- final expert and adversarial review records with finding disposition.

Exit gate:

- every P0/P1 review finding is closed and every accepted P2 risk has an owner and expiry;
- no test uses an unpublished branch or unpinned mutable artifact;
- release evidence can be verified offline;
- doctrine, implementation documents, status pages, and actual behavior agree.
- old but correctly signed, cross-role, revoked, mixed-version, semantically prohibited, and resource-hostile artifacts are rejected by product admission policy.

## 6. Repository plans

### 6.1 Azazel

Purpose: doctrine and program coordination.

Backlog:

1. Register the active Boot repository and ratify its civil emergency role, persistence rules, and deployment class.
2. Register Nexus and its sustained rugged-PC role in the product map.
3. Publish the authority matrix and shared terminology used by all seven repositories.
4. Maintain this cross-repository plan and a compatibility table that links released versions rather than branches.
5. Link release evidence and residual risks; avoid duplicating product implementation details.

Completion evidence: current product map, naming decision, linked release matrix, and no contradictory status claims across the doctrine pages.

### 6.2 Azazel-Fabric

Purpose: common language and interoperability assurance.

Backlog:

1. Reconcile documentation status against shipped tags before adding contracts; package metadata is the factual starting point, and prose is corrected to match verified releases and consumer pins.
2. Design `provisioning_contracts` and `mio_contracts` as additive modules.
3. Add product-neutral compatibility claim models, structural validation, canonical bytes/digests, and golden fixtures; make no admission decision.
4. Add invariants for advisory-only data, bounded leases, privacy classification, and authority provenance.
5. Publish a conformance kit that each consumer runs in its own CI to produce a signed attestation; aggregate pinned attestations in the separate program release workflow.
6. Publish a stable tag and adoption guide update.

Completion evidence: tagged release, changelog, API reference, golden-fixture version, and green downstream compatibility runs.

### 6.3 Azazel-Edge

Purpose: deterministic decision and enforcement plane for Nexus and Boot.

Backlog:

1. Define a supported x86_64 package and preserve existing constrained-device profiles.
2. Inventory current daemons and extract stable service/API boundaries where scripts still share process or file state; split deterministic arbitration from privileged nftables/`tc` execution through a typed local interface.
3. Add deployment profile inputs for interface roles, capture sources, storage paths, and enforcement adapters.
4. Add Fabric projections and import adapters behind exact release pins.
5. Complete Knowledge request/response integration with deadline and no-context fallback.
6. Complete authenticated Deception lease, heartbeat, reconciliation, and routing integration.
7. Prove action leasing, rollback, restart recovery, and no-enforcement-bypass in virtual and physical labs.
8. Keep the existing device-specific installer as a compatibility path and prevent it from being selected by Nexus/Boot packages or profiles.

Completion evidence: release package, service inventory, contract tests, deterministic replay corpus, adapter receipts, and HIL report.

### 6.4 Azazel-Knowledge

Purpose: full advisory knowledge node and producer of bounded Lite bundles.

Backlog:

1. Reconcile the existing Fabric adoption documentation and pin one released contract version for the API extra.
2. Complete Edge-facing Fabric CTI validation while preserving the existing deterministic and dependency-minimal core.
3. Define the tactical Lite bundle selection algorithm, capacity limits, freshness, rollback anchor, signature, provenance, archive expansion limits, and local-sensitive-data export policy.
4. Add full-node mTLS service identity, manifest, health, rate limits, and offline behavior.
5. Add Nexus context and bundle synchronization tests; malformed or unavailable responses resolve to no advisory context.
6. Add Deception outcome ingest and effectiveness advice without creating an activation or enforcement path.
7. Preserve the current constrained-hardware target while certifying the Full Node and bundle builder on declared generic Linux AMD64/ARM64 profiles; the Full Node remains external to the Nexus chassis.
8. Enforce a default field allowlist for Lite export, deterministic redaction/pseudonymization, secret canaries, source classification, signed export-policy digest, destination/retention receipt, and dataset-specific freshness ceilings.

Completion evidence: signed bundle fixture, reproducible export, API compatibility report, unplug test, audit-chain evidence, and deterministic scoring replay.

### 6.5 Azazel-Deception

Purpose: safe, package-driven Lite and Full deception environments.

Backlog:

1. Reconcile roadmap, implementation status, live-gate checklist, actual Fabric pin, and test evidence, then close remaining physical isolation, route drift, restart, and supply-chain policy gates.
2. Keep live activation behind an authenticated, expiring, one-shot Edge decision and operator kill switch.
3. Publish a bounded Lite tier suitable for Nexus and conditionally for Boot.
4. Complete mTLS transport, key provisioning/rotation, heartbeat, reconciliation, evidence finalization, external evidence-head anchoring, and deterministic reset.
5. Add signed package and image compatibility for the target x86_64 profiles.
6. Deliver outcome export to Knowledge through Fabric fact-only contracts.
7. Start richer narratives or personas only after the live safety gate is closed.
8. Prove deployment overlays are monotonic reductions of a signed package and cannot add services, images, ports, routes, DNS, mounts, capabilities, commands, credentials, or resource ceilings.
9. Require container/runtime confinement, dedicated identities, device deny-all, read-only proc/sys views, syscall and LSM policy, no shared writable volumes or runtime sockets, and an admitted host kernel/runtime security baseline.
10. Separate route withdrawal from runtime cleanup: lease expiry or isolation loss removes exposure within a fixed watchdog bound and leaves failed cleanup visibly quarantined.
11. Use per-environment ephemeral encryption keys or bounded encrypted/tmpfs state, controlled swap and core dumps, isolated runtime logs, lure-credential invalidation, cryptographic erase, and a post-crash/reboot/reset scan of all declared persistence paths; only finalized exported evidence is retained.

Completion evidence: signed package, SBOM/provenance verification, physical isolation report, replay/expiry results, kill-switch drill, and evidence-chain export.

### 6.6 Azazel-Nexus

Purpose: persistent, self-contained field integration.

Backlog:

1. Turn the implementation specification into packages, systemd units, service accounts, local sockets, and deployment manifests.
2. Build the guided installer with automatic RAM profile selection and signed online/offline assets.
3. Build commissioning, interface-role inventory, dry-run rendering, activation receipts, and rollback.
4. Integrate Edge Core, deterministic voice, Operator Plane, and append-only/hash-chain audit.
5. Add Knowledge Lite, Deception Lite, local M.I.O., and resource governance.
6. Add optional AZ-04/AZ-06 modules and `FULL -> LITE -> CORE` degradation.
7. Add A/B updates, recovery, evidence custody, HIL certification, and operator training material.
8. Implement the generation-scoped activation controller, field ownership map, release admission policy, continuous isolation attestation, management failsafe, independent audit anchor, and reserved Core resources.

Completion evidence: reproducible installation image, signed profile, standalone scenario, extension-loss scenario, recovery drill, and resource-tier qualification report.

### 6.7 Azazel-Boot

Purpose: portable civil emergency environment from a USB SSD.

Backlog:

1. Bootstrap the repository with license, security policy, contribution guide, Fabric pin, package layout, CI, threat model, and architecture decision records.
2. Build a reproducible signed boot image with read-only root and encrypted persistence; use firmware verification where the supported hardware permits and provide a documented portable passphrase/recovery path when platform ownership is unavailable. Install updates to the inactive slot, verify the full digest before selection, promote only after a health-confirmed trial boot, and automatically fall back on failure. Persistence migrations are backward compatible or require a verified pre-trial snapshot and restore path.
3. Implement RAM-based profile selection, driver/hardware inventory, and per-host commissioning.
4. Import released Edge packages and emergency profiles through explicit adapters.
5. Add bounded Knowledge Lite and local M.I.O.; keep Core usable when model assets are absent.
6. Gate Deception Lite on current-host isolation capability and tests.
7. Implement portable audit/evidence storage, encrypted export, update, rollback, and controlled shutdown.
8. Publish a laptop compatibility matrix and run civil emergency exercises with nontechnical operators; product claims refer to the tested compatibility envelope rather than arbitrary laptops.
9. Enforce initramfs host-storage quarantine, immutable A/B slots, persistence integrity/repair, media trust classes, RAM-resident release supervision, and surprise-removal recovery.

Completion evidence: reproducible USB image, clean boot on the compatibility set, no-host-disk test, offline Core operation, encrypted evidence export, and operator exercise report.

## 7. Parallel execution model

After R0, work proceeds in four parallel lanes with explicit synchronization points:

| Lane | Repositories | May proceed independently | Synchronization gate |
| --- | --- | --- | --- |
| Contracts | Fabric, Azazel | schemas, fixtures, doctrine | Fabric release candidate |
| Decision and knowledge | Edge, Knowledge | product-local packaging and tests | CTI contract candidate |
| Deception | Deception, Edge | package/isolation and shadow tests | authenticated lease candidate |
| Deployment | Nexus, Boot | installer/image builder, UI, hardware inventory | provisioning contract candidate |

Consumers test a Fabric release candidate in CI, then pin the stable tag. Development branches or editable checkouts are allowed in local integration work but cannot satisfy a release gate.

## 8. Quantitative service objectives

Initial release gates use measurable targets. A later change may revise a target only with benchmark evidence and an updated compatibility entry.

| Objective | Initial target |
| --- | --- |
| Core ready after encrypted-volume unlock | within 120 seconds |
| Source/interface failure visible | within 10 seconds |
| P0 visual/voice alert queued after decision | within 2 seconds |
| Lease-expiry rollback starts | within 5 seconds of expiry; completion bound is action-specific |
| Local M.I.O. failure reflected as `CORE ONLY` | within 30 seconds |
| External Knowledge, Deception, or remote cognition loss | 100% continuation of deterministic evidence, evaluation, enforcement lease, and audit paths |
| Audit ordering | action/receipt is durable before it is reported as complete |
| Deception isolation drift | detect within 2 seconds and withdraw attacker-route exposure within 5 seconds, independent of runtime cleanup |
| Boot host storage | zero content writes from initramfs entry through shutdown until an explicit export target is approved |
| Observation interface | zero transmitted frames during a 10-minute link/RA/DHCP/resume stress interval |
| Hostile load | Core audit, lease expiry, and health SLOs remain within bounds at each declared ingress quota |

Resource and performance targets are recorded separately for 8, 16, 32, and 64 GB classes. A faster model or larger cache cannot consume the Core reserve.

## 9. Review and correction workflow

Every program release uses the same review loop.

### 9.1 Authoring review

The owning repository prepares:

- design change and responsibility statement;
- contract or API diff;
- implementation and migration plan;
- test evidence and rollback procedure;
- updated compatibility entry and known risks.

### 9.2 Specialist review

At least four independent perspectives review the complete change:

1. **Series architect:** ownership, dependency direction, authority, and backward compatibility.
2. **Security and supply-chain reviewer:** trust boundaries, secrets, signatures, identities, update, rollback, and fail-closed behavior.
3. **Linux and field-operations reviewer:** installation, hardware variance, networking, storage, power, recovery, and operator burden.
4. **Contracts and data reviewer:** schema evolution, canonical bytes, provenance, freshness, audit, privacy, and deterministic replay.

Each finding records severity (`P0` release blocker, `P1` required, `P2` bounded risk, `P3` improvement), evidence, affected requirement, proposed correction, owner, and verification. Authors revise the plan or implementation and reviewers verify the resolution. A written disagreement is retained; it is not erased by editing the original finding.

### 9.3 Integrated verification

After specialist findings are resolved, an independent reviewer runs the documented build and tests from clean released inputs. The reviewer checks the resulting behavior and artifacts rather than relying on the author's logs.

### 9.4 Adversarial review

The release candidate is then reviewed with hostile assumptions:

- malicious or malformed Fabric, Knowledge, Deception, M.I.O., and configuration payloads;
- stale/replayed/expired decisions and identity substitution;
- compromised decoy attempting protected-network, management, host, or Internet access;
- remote response attempting instruction or data exfiltration;
- partial install, power loss, disk exhaustion, clock rollback, and failed update;
- NIC reorder, missing adapter, hostile DHCP/DNS, and accidental management lockout;
- USB removal, untrusted laptop storage, persistence tampering, and unsupported hardware;
- component version skew and a validly signed but policy-incompatible asset.
- archive traversal, decompression bombs, duplicate paths, and delta-bundle base confusion;
- alternate Deception egress over IPv6, DNS, link-local, multicast, metadata endpoints, and mounted runtime sockets;
- model and advisory content designed to resemble executable operator instructions.

Adversarial reviewers produce reproducible cases and expected safe outcomes. All P0/P1 findings return to specialist review after correction. New or changed controls receive focused regression tests. The final candidate repeats clean-room verification.

### 9.5 Release decision

A release is eligible when:

- all P0/P1 findings are resolved and independently verified;
- P2 findings have an owner, mitigation, expiry, and operator-visible limitation;
- two independent builders reproduce the same unsigned immutable payload digest from pinned inputs; each signed envelope verifies the same subject digest, authorized signer role, and provenance;
- rollback and recovery have been exercised;
- current documentation matches observed behavior;
- the authority invariant and standalone Core behavior hold under every tested failure.

## 10. Initial specialist review record

The first review of this plan used three independent specialist perspectives: contracts/release/Boot, Edge/Linux/Nexus, and Knowledge/Deception/data isolation. The following findings were accepted and incorporated before adversarial review.

| Finding | Severity | Resolution in this plan |
| --- | --- | --- |
| SR-01 Fabric prose and actual package/consumer versions disagree | P1 | R0 and Fabric backlog require a release truth audit before new contract work |
| SR-02 RAM alone could enable unsafe networking or Deception | P1 | resource and topology profiles are independent and effective capability is their verified intersection |
| SR-03 the existing Edge network installer makes device-specific assumptions | P1 | Nexus/Boot consume packages and adapters; they do not invoke that installer |
| SR-04 Nexus duplicated schema ownership intended for Fabric | P1 | Fabric owns canonical provisioning/M.I.O. shapes; products own runtime policy and execution |
| SR-05 Knowledge Lite ownership was ambiguous | P1 | Knowledge builds signed bounded artifacts; Nexus/Boot own embedded readers and storage |
| SR-06 Deception documentation overstates and understates completed gates in different places | P1 | Deception starts with a truth/evidence reconciliation and retains physical gaps as open |
| SR-07 Boot's “any laptop” goal is not testable | P1 | Boot publishes and qualifies a declared compatibility envelope |
| SR-08 TPM and firmware trust cannot be assumed on emergency laptops | P2 | Boot has portable encrypted-persistence recovery and reports platform verification capability |
| SR-09 Fabric could grow into an installer/runtime | P1 | R1 includes a static no-side-effect boundary gate |
| SR-10 consumers need different current Fabric features | P2 | compatibility is feature-to-minimum-version; convergence occurs after consumer candidate tests |

## 11. Initial adversarial review record

Three reviewers then attacked the revised plan from supply-chain/Boot, Linux/network/authority, and Knowledge/Deception/model perspectives. Findings with the same root cause are consolidated below; the full review evidence remains attached to the planning change.

| Finding | Highest severity | Correction applied |
| --- | --- | --- |
| AR-01 Fabric activation descriptions could become executable authority | P0 | replaced `ActivationPlan` with descriptive `ProposedGenerationDescriptor`; recursive directive rejection and no-side-effect gates added |
| AR-02 a valid signature could admit obsolete, cross-role, mixed, or semantically hostile assets | P0 | product-local delegated trust, security epochs, exact tested tuples, semantic/resource gates, and hostile signed-asset tests added |
| AR-03 “atomic/full rollback” overstated multi-service reversibility | P0 | generation activation now declares irreversible effects, ordered exposure barriers, owned-resource reconciliation, and `ROLLBACK_INCOMPLETE` |
| AR-04 Boot could write host disks or firmware state before user-space policy starts | P0 | initramfs storage quarantine, forbidden autoactivation paths, zero-write HIL, and separate NVRAM reporting added |
| AR-05 commissioning record replacement/replay or overlay changes could bypass Edge policy | P0 | boot-time generation validation, preset-disabled units, activation controller, field ownership, and policy-key isolation added |
| AR-06 clock changes, reboot, overlapping leases, or management lockout could leave controls active | P0 | monotonic/session leases, resource ownership, restart reauthorization, two-stage management commit, and physical recovery added |
| AR-07 event/model/module floods could starve audit and lease release | P0 | Core reservations, separate quotas/filesystems, bounded ingress, source quarantine, and hostile-load SLOs added |
| AR-08 model/tokenizer artifacts could execute code or reach secrets | P0 | inert format policy, parser/runtime pinning, model sandbox, no dynamic code/tools/network, and malformed-model tests added |
| AR-09 Deception isolation could fail after initial certification | P0 | continuous isolation attestation, kernel quarantine before cleanup, fixed route-withdrawal bound, and route-drift tests added |
| AR-10 audit or Boot state could be rewritten, rolled back, or cloned | P0 | security epochs, signed chained checkpoints, independent anchors, separate recovery authority, clone identity reset, and limitation display added |
| AR-11 archive extraction and delta handling accepted dangerous but signed content | P1 | complete bounded regular-file extractor and target-tree digest requirements added |
| AR-12 NIC identity, link flap, setup networking, or service race could activate the wrong path | P1 | composite identity, ambiguous-match refusal, isolated asset acquisition, zero-transmit observation, and generation-bound service start added |
| AR-13 Full/Lite knowledge and Deception switching could oscillate, collide, or misattribute evidence | P1 | transaction-pinned knowledge routing, separate conflicting claims, global environment/lease identity, and ordered route switching added |
| AR-14 local/remote model text could socially or technically bypass the advisory boundary | P1 | one inert closed output contract, structured claim set, privacy budgets, no automatic follow-up, and lower-priority explanatory voice added |
| AR-15 Boot reproducibility, update, persistence, and surprise removal lacked executable definitions | P1 | unsigned-payload reproducibility, immutable A/B slots, redundant metadata, dirty recovery, trust classes, and RAM-resident release supervision added |
| AR-16 Deception overlays/runtime and Knowledge Lite export could expand access or leak data | P1 | monotonic-reduction overlays, container confinement, export allowlists/redaction, signed policy digest, and privacy canary tests added |

All P0/P1 corrections require focused specialist verification and clean-room adversarial rerun before their affected release gate can close. Documentation changes record the intended control; implementation evidence is still required by R1–R8.

Final focused re-review status: **PASS** from all three review tracks. Each reviewer rechecked only its previously open findings after correction: Fabric/Boot/release engineering (3), Edge/Linux/network authority (2), and Knowledge/Deception/model/data (5). This pass approves the development plan as a review baseline; it does not substitute for the implementation and hardware evidence required at each release gate.

## 12. Cross-product test matrix

| Test | Fabric | Edge | Knowledge | Deception | Nexus | Boot |
| --- | --- | --- | --- | --- | --- | --- |
| Canonical contract and golden fixture | owner | consume | consume | consume | consume | consume |
| Deterministic scenario replay | fixture | owner | scoring replay | lifecycle replay | integrate | integrate |
| Missing dependency/module | schema result | continue | advisory unavailable | stop new activation | degrade | degrade |
| Signature/version failure | reject | reject | reject bundle | reject package/decision | quarantine | reject asset |
| Interface identity change | assignment model | fence scope | N/A | fence route | recommission | recommission |
| Resource pressure | profile model | protect Core | bound cache | bound runtime | shed to Core | shed to Core |
| Network isolation | contract | route authority | N/A | decoy boundary | HIL owner | per-host gate |
| Audit/evidence integrity | projection | decision chain | advisory chain | outcome chain | system anchor | portable anchor |
| Update/recovery | compatibility | package | package/data | package/runtime | A/B system | image/persistence |

## 13. Initial issue order

1. Azazel: ratify the Nexus/Boot product map and this program plan.
2. Fabric: reconcile release status and design provisioning/M.I.O. contracts.
3. Boot: repository bootstrap and threat model using Fabric's day-one adoption guide.
4. Nexus: align the implementation specification with actual Fabric, Edge, Knowledge, and Deception packages.
5. Edge: x86_64 service packaging and stable integrator boundary.
6. Knowledge: Lite bundle profile and Edge CTI boundary closure.
7. Deception: close physical live gate and define Lite tier.
8. Nexus/Boot: installer and image-builder vertical slice.
9. All consumers: Fabric release-candidate compatibility run.
10. Nexus/Boot: Core field and emergency exercises, followed by Lite and Full capability gates.

## 14. Program definition of done

The program is complete when a Nexus can be installed and operate standalone on its declared rugged-PC classes, and a Boot USB SSD can start a usable civil emergency Core on its declared laptop classes. Both use released, pinned Azazel components and Fabric contracts; both retain deterministic Edge authority; both expose actual capability and degradation; both produce verifiable audit and evidence exports; and both can be recovered using offline instructions and media.

## 15. Open program findings

Sections 10 and 11 record findings that were corrected before this plan was published. This section records findings raised against the published plan that are **not yet resolved**. A finding stays here, unresolved and unedited in substance, until the owner decides; the plan text it concerns is left as written so that no product silently implements a different rule. Findings use the fields of §9.2: severity, evidence, affected requirement, proposed correction, owner, and verification.

### OF-01 — the RAM selector's thresholds contradict the tiers the plan assumes

- **Raised:** 2026-09-19, during a cross-repository documentation verification pass.
- **Severity:** proposed `P1`. It blocks the R2 selector implementation and makes the R4 Boot exit gate unmeetable as written. The owner confirms the severity together with the resolution.
- **Decision issue:** [Azazel #74](https://github.com/01rabbit/Azazel/issues/74), closed as completed.
- **Status:** **resolved 2026-09-19 by owner decision.** Candidate resolution 1 (move the thresholds) was chosen. The resolution is recorded below; §5 R2 and the R4 exit gate carry the corrected boundaries, and the propagated documents were updated in the same change.

**Evidence.** §5 R2 specifies one product-local selector over usable RAM in MiB after firmware reservation: less than 8192 `diagnostic`, 8192–16383 `core`, 16384–32767 `lite`, 32768 or more `standard`. Usable RAM is always below the nominal module size, because firmware reserves some of it, and each threshold is set at exactly the nominal size it is meant to admit (8192 MiB = 8 GiB, 16384 MiB = 16 GiB, 32768 MiB = 32 GiB). A host of a given nominal size therefore never reaches the threshold named after it; it always falls one tier below.

A measurement on a nominal 16 GB Linux host: `/proc/meminfo` reports `MemTotal: 16481980 kB`, which is 16,095 MiB of usable RAM — 289 MiB short of the 16384 MiB `lite` threshold. That host selects `core`, not `lite`. By the same argument a nominal 8 GB host selects `diagnostic`, not `core`. The Nexus capability model additionally subtracts the measured Core reserve before selection, which moves every host further down, never up.

**What it contradicts.**

1. §5 R4 exit gate: "Boot completes the Core loop on 8 GB and adds verified Lite functions at 16 GB." Under the R2 selector an 8 GB host is `diagnostic` (no policy activation) and a 16 GB host is `core` (no Lite functions), so the gate cannot be met on the hardware it names.
2. The R0 exit criterion in the [R0 baseline](nexus-boot-r0-baseline.md): "RAM tiers of 8 GB, 16 GB, and 32 GB or more select resource envelopes independently of topology." The nominal tier names in that criterion do not select the envelopes the rest of the program attaches to them.
3. [Azazel-Nexus #5](https://github.com/01rabbit/Azazel-Nexus/issues/5), whose scope quotes the same four thresholds and whose acceptance criterion reads "An 8 GiB system operates deterministic Core with no model or remote dependency." An 8 GiB system selects `diagnostic` under the quoted thresholds.

§8 of this plan records resource and performance targets for "8, 16, 32, and 64 GB classes" — nominal class names — which is the same mismatch of units seen from the reporting side.

**Where the thresholds have propagated.** Verified by inspection on 2026-09-19:

| Document or issue | Where |
|---|---|
| `Azazel-Nexus/docs/capability-model.md` | §2 resource-profile table, four rows; `standard` repeated at the worked example |
| `Azazel-Nexus/docs/IMPLEMENTATION_SPEC.md` | resource-profile table, four rows |
| `Azazel-Nexus/docs/operations.md` | resource-profile table, four rows, with companion hardware |
| `Azazel-Nexus/docs/mio-runtime.md` | capacity-envelope table, four rows, plus the eligibility vocabulary mapped onto them |
| `Azazel-Boot/docs/architecture.md` | §3.1, prose, explicitly inheriting the thresholds from this plan and explicitly declining to choose its own |
| [Azazel-Nexus #5](https://github.com/01rabbit/Azazel-Nexus/issues/5) | scope and acceptance criteria |
| [Azazel-Nexus #2](https://github.com/01rabbit/Azazel-Nexus/issues/2) (closed) | scope item 4 |
| [Azazel-Boot #8](https://github.com/01rabbit/Azazel-Boot/issues/8) | premised on applying this selector after measuring Boot's Core reserve |

`Azazel-Nexus/docs/nexus-integrated-node.md` states a related but separate requirement — "16384 MiB of usable RAM or more" for a self-contained Nexus — which inherits the same mismatch if the tier names are read as nominal sizes. No implementation of this four-tier selector exists in any repository, so the contradiction is still confined to documents and issues.

**Resolution (owner decision, 2026-09-19): candidate 1 — move the thresholds.**

| usable MiB after firmware reservation | tier |
|---|---|
| less than 7168 | `diagnostic` |
| 7168 – 15359 | `core` |
| 15360 – 31743 | `lite` |
| 31744 or more | `standard` |

Each boundary is **the nominal size it admits minus a 1024 MiB firmware-reservation allowance**: 8192−1024, 16384−1024, 32768−1024. The numbers are derived from that one constant, so they are revisable by changing the constant rather than by re-arguing three numbers.

**Basis for the 1024 MiB allowance.** Firmware reservation on x86_64 comprises UEFI runtime services, ACPI tables, kernel-reserved regions, and — the large and variable term — integrated-GPU stolen memory, an aperture commonly 512 MiB and configurable in firmware setup. The one measurement this program holds is 289 MiB on a virtual host with no integrated GPU. 1024 MiB covers that case with room for a 512 MiB aperture and margin.

**What the allowance is not.** It is not a claim about how much memory a tier needs. The tier names a **hardware class**; whether that class can actually run the work is decided separately by the measured Core reserve, which the selector clause already makes it "subject to" and which remains unmeasured. Keeping those two questions apart is what makes a generous allowance safe: a too-generous allowance admits a host to its nominal class and the Core reserve check then decides what it can do, whereas a too-small allowance excluded every host from its own class with no recourse.

**Residual risk, stated rather than smoothed over.** A host whose firmware reserves more than 1024 MiB — a 2 GiB integrated-GPU aperture, for instance — still falls one tier below its nominal class. The remedy is measurement across the declared hardware sets, not a larger guess. Until those measurements exist, a host that appears to be mis-tiered is evidence about the allowance and is raised as a finding.

**One further correction the decision forces.** The finding above records that the Nexus capability model additionally subtracted the measured Core reserve *before* selection, moving every host further down. That subtraction is incompatible with thresholds derived as nominal minus a firmware allowance: it would displace every host by the reserve amount a second time, and the tier would stop naming a hardware class. The selector's only input is therefore the usable-RAM reading after firmware reservation, and the Core reserve is applied **after** selection, as the constraint the selector clause makes the tier "subject to". The three Nexus sentences that said otherwise were corrected in the same change.

**Not resolved by this decision:** the vocabulary mismatch recorded as OF-02 below.

**Superseded — the candidates as they were stated before the decision.** Retained so the decision can be read against the alternatives it rejected.

1. **Move the thresholds** so that a host of each nominal class lands in the intended tier — for example by setting each boundary below the nominal size by a margin covering firmware reservation and the measured Core reserve. Requires a defensible margin, which requires measurement across the declared hardware sets.
2. **Key the selector on nominal RAM** (installed module size) rather than usable RAM, and treat usable RAM as a separate recorded measurement. Changes what the selector reads, and needs a reliable nominal-size source on both rugged PCs and borrowed laptops.
3. **Accept the current arithmetic and restate the prose** so that "8 GB" everywhere means ">= 8192 MiB usable" — that is, keep the thresholds and correct the R4 gate, the R0 exit criterion, Nexus #5, and the propagated tables to speak in usable MiB rather than nominal classes. Changes which physical machines qualify.

**Affected requirements:** §5 R2 selector deliverable; §5 R4 Boot exit gate; §8 class names; R0 baseline exit criterion on RAM tiers.

**Owner:** Azazel (this plan owns the selector; Nexus and Boot inherit it and must not diverge from it locally).

**Verification.** Done for the documentation half: the rule is stated once here, and §5 R2, the R4 exit gate, the R0 exit criterion, and the propagated Nexus and Boot tables were corrected in the same change. **Not yet done:** the first implementation of the selector must carry a test that asserts the tier selected for a **measured** host, not for a nominal label. Until that exists the correction is written down and unproven, which is the same standard this program applies elsewhere.

### OF-02 — the selector's output vocabulary and the capability-state vocabulary do not match

- **Raised:** 2026-09-19, while implementing the R1a provisioning contracts. Separate from OF-01 and not resolved by it.
- **Severity:** proposed `P2`. It does not block the selector, but it makes any mapping from a selected tier to a reported capability state a local invention.
- **Status:** **open — owner decision required.** Raised for decision as [Azazel #77](https://github.com/01rabbit/Azazel/issues/77).

**Evidence.** §5 R2's selector emits four values: `diagnostic`, `core`, `lite`, `standard`. §3.1's capability summary has three: `CORE`, `LITE`, `FULL`. `diagnostic` has no capability-state counterpart, and `standard` and `FULL` are never reconciled anywhere in this plan. A product that selects `standard` and must report a capability state has no stated rule for which one to report, and a product that selects `diagnostic` has no state at all.

**Why it was not decided alongside OF-01.** OF-01 was an arithmetic defect with a measurable cause. This is a naming decision with consequences for what each state means: whether `standard` and `FULL` are the same thing under two names, whether `diagnostic` is a capability state or the absence of one, and whether a four-value resource vocabulary should map onto a three-value capability vocabulary at all — given that effective capability is an intersection of four dimensions and is not determined by the resource one.

**What was done in the meantime.** `azazel_fabric.provisioning_contracts` encodes **neither** vocabulary as a contract field: a `ResourceProfile` carries measured usable MiB and no tier, and `assert_no_resource_tier_claim` rejects any tier or capability-state field. `registry.CAPABILITY_STATES` exists only so two products name the same summary the same way. Resolving OF-02 therefore changes no contract and invalidates no fixture.

**Affected requirements:** §5 R2 selector deliverable; §3.1 capability summary; any product that must report a state derived from a tier.

**Owner:** Azazel.

**Verification when resolved:** the mapping — or the decision that there is none — is stated once in this plan, and no product derives a capability state from a resource tier by a locally invented rule.
