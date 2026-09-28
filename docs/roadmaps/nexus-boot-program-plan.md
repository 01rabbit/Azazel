# Azazel Nexus and Boot Cross-Repository Development Plan

Status: proposed program baseline, with the owner-approved Boot scope correction below (2026-09-28)
Scope: Azazel, Azazel-Fabric, Azazel-Edge, Azazel-Knowledge, Azazel-Deception, Azazel-Nexus, and Azazel-Boot

## 1. Purpose

This plan coordinates the Nexus deployment product and defines cross-repository doctrine. Boot is a user-assistance companion rather than a bootable deployment product:

- **Azazel-Nexus** is a persistent installation on a rugged Linux PC for sustained field operation. It contains Edge, local cognition, Knowledge Lite, Deception Lite, operator functions, audit, and network enforcement. External Knowledge and Deception nodes expand capacity.
- **Azazel-Boot** is a user-assistance/tooling companion used inside an operating environment already supplied and started by the user. It does not create/remaster an OS, build or write boot media, or provide Boot-owned OS persistence. Its concrete tool set and host-side effects remain to be specified.

### Owner scope correction — Azazel-Boot (2026-09-28)

The owner has decided that Boot will **not** create Debian Live or another OS,
select an image builder, write/partition/format removable media, or own the
bootable-SSD/initramfs/persistence/HIL product path described elsewhere in
this historical proposal. Those Boot-specific requirements are retired, not
pending implementation. The corresponding Boot issues have been closed as
not planned, not as engineering acceptance.

Boot may later provide a small helper installer and user-assistance tools for
a responder workflow distinct from Nexus. The tool inventory, supported host
environments, trust/input model, privileges, installation effects and rollback
are undecided. Do not implement an installer until one concrete tool proposal
is reviewed. Nexus remains the persistent appliance installer. This correction
does not authorize provider admission, network fetch, model acquisition or
Edge activation, and does not relax Edge's sole decision/enforcement authority.

For current work, this decision supersedes Boot-specific deployment, runtime,
resource-tier, commissioning, persistence, firmware, and hardware acceptance
criteria throughout §§3–8 and the Boot service-objective assignments. Any
remaining reference to the former USB/Linux-Live product is historical context,
not a current Boot requirement.

Nexus reuses existing product implementations through released packages and signed assets. A future Boot helper may consume a released contract only when a concrete proposal requires it. The program does not copy source trees into either repository.

## 2. Permanent authority and ownership rules

The series rule applies to every phase:

> Fabric describes. Knowledge advises. Edge decides and enforces. Deception materializes an Edge-approved environment. Nexus integrates these products without creating another decision authority. Boot creates no decision authority; any future helper is limited to an approved user-assistance scope.

| Concern | Owning repository | Other repositories may do |
| --- | --- | --- |
| Series doctrine, naming, product map | Azazel | Link and conform |
| Shared schemas, canonical bytes, validation, test fixtures | Azazel-Fabric | Pin a released tag and implement adapters |
| Evidence, deterministic evaluation, arbiter, enforcement | Azazel-Edge | Configure and call published interfaces |
| Full knowledge, correlation, signed tactical bundle production | Azazel-Knowledge | Consume advisory results or verified bundles |
| Deception packages, safe lifecycle, evidence export | Azazel-Deception | Request only through an Edge-approved lease |
| Persistent appliance integration and embedded Lite runtimes | Azazel-Nexus | Assemble released components and hold deployment policy |
| User assistance and optional tool-installation helper | Azazel-Boot | Guide use of a user-provided environment; no OS-image or media construction |

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
                         |
                         v
                Nexus release gate
```

The critical path is Fabric contract release -> producer/consumer adapters -> Nexus integration -> hardware and emergency exercises. Boot has no contract dependency until a concrete helper proposal is approved.

### 3.1 Independent admission dimensions

RAM capacity does not prove that a Nexus host can safely capture, enforce, or isolate deception traffic. Nexus computes effective capability from independent records:

```text
effective capability = resource profile
                     ∩ topology profile
                     ∩ verified asset set
                     ∩ current trust/health state
```

`ResourceProfile` records CPU, usable RAM, storage, and thermal/power budgets. `TopologyProfile` records commissioned interfaces, capture support, management reachability, and proven isolation properties. A 32 GB Nexus host with one unsuitable NIC may qualify for Standard local cognition while remaining in observe-only Core networking and keeping Deception disabled. Nexus reports each capability state and the overall `CORE`, `LITE`, or `FULL` summary. That summary and the resource profile are reported **separately and are never derived from each other** ([OF-02](#of-02--the-selectors-output-vocabulary-and-the-capability-state-vocabulary-do-not-match)): the host above selects the `standard` resource tier and still summarises as `CORE`, because capability is the intersection of four dimensions and the resource dimension does not decide it. Boot has no resource-tier or operational-capability contract.

## 4. Shared configuration and release flow

This section specifies Nexus. Boot has no runtime configuration, artifact-admission, or activation pipeline; a future tool helper requires a separately approved proposal.

Each source repository publishes a versioned artifact. Nexus imports approved artifacts through product adapters, applies a deployment overlay, validates against Fabric, renders runtime configuration, and activates it transactionally. A future Boot helper has no such pipeline unless its approved proposal requires one.

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

Cryptographic authenticity is one input to admission. Nexus requires all of these gates in order:

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

Management paths are excluded from ordinary action scope. A high-impact network change requires an independent management path or physical local console and a two-stage commit: if the operator does not acknowledge verified reachability within the lease window, the enforcement supervisor rolls it back.

### 4.4 Bounded artifact handling

The product extractor accepts declared regular files only and rejects absolute/traversal paths, symlinks, hardlinks, devices, FIFOs, sparse files, nested archives, duplicate or Unicode/case-colliding normalized paths, unexpected metadata, and undeclared output. It enforces compressed size, expanded size, file count, per-file size, path depth, inode, time, and staging-volume quotas. It hashes while writing, syncs, reopens without following links, rehashes, validates semantics, and then promotes a complete tree. Delta bundles require an exact base digest and declared final tree digest.

Model admission additionally restricts formats, tokenizer formats, parser/runtime versions, quantization, context size, and memory needs. Model-supplied code, dynamic loaders, native plugins, pickle-like executable serialization, tools, and network fetch during load are forbidden. Models run under a dedicated account with read-only assets, no secrets, no control sockets, no network by default, syscall/LSM confinement, and hard cgroup budgets.

### 4.5 Audit, persistence, and recovery state

Core audit, intent/lease journal, evidence, Deception telemetry, Knowledge cache, models, extraction staging, and Nexus persistence use separate quotas or filesystems. The Core audit and lease journal have reserved space, I/O, memory, and process priority. Untrusted inputs have bounded item size, rate, cardinality, concurrency, bytes, and inodes; pressure quarantines or sheds the source before consuming Core reserves, with durable loss counters and visible sensor health.

A product checkpoint binds product/node/boot identity, log/security epoch, monotonic sequence, previous checkpoint, current head, active versions, policy/inventory generation, and wall/monotonic time. Nexus uses a TPM-backed counter where available and an independent signed anchor receipt. Audit assurance profiles distinguish `ROLLBACK_ANCHORED` from `LOCAL_CONTINUITY_ONLY`. The latter forbids live Deception, disruptive actions, and claims of rollback-verified finalized evidence unless a named emergency policy records explicit operator acceptance; exports are labeled as locally consistent and not rollback verified. Failure of a required anchor receipt fences new high-impact work, withdraws exposure according to the active lease, preserves observation, and creates a visible custody exception. Activation, action completion, update, evidence finalization, and shutdown require a synchronous checkpoint according to policy. Recovery authority cannot sign ordinary field checkpoints or hide a discontinuity.

## 5. Program releases and gates

These releases are capability gates rather than calendar commitments. A gate closes only when its evidence is stored and review findings are resolved.

### R0 — Baseline and ownership freeze

Deliverables:

- ratify the Nexus product definition and Boot's user-assistance role in Azazel;
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
- define Nexus and Boot product names in open extension registries, without implying a Boot runtime consumer;
- provide canonical serialization, digest helpers, rejection of directive-bearing advisory fields, and golden fixtures;
- publish a feature-to-minimum-Fabric-version matrix so products can converge deliberately without forcing an untested simultaneous pin change;
- recursively reject command, unit, route, firewall, device-path, executor, boolean authorization, and trust-decision fields from descriptive provisioning objects;
- define audit checkpoint, security-state, privacy, bounded-artifact, and structured claim-set projections while leaving trust decisions and chain enforcement product-local;
- execute the release in three steps: R1a draft schema/conformance kit, R1b signed release-candidate digest, and R1c stable tag after downstream evidence.

Exit gate:

- all new models round-trip through canonical JSON;
- malformed, directive-bearing, unknown-version, expired, and digest-mismatched fixtures fail closed;
- Edge, Knowledge, Deception, and Nexus candidate adapters pass the same golden fixtures; Boot conformance is deferred until an approved helper requires a contract;
- the release contains no installer, decision, network, container, or model execution code.
- static checks confirm that the new modules do not import operating-system probing, network, subprocess, installer, or runtime-control code.
- Fabric CI runs only Fabric code and fixtures; each consumer pins the candidate digest and publishes a signed conformance attestation that a separate program workflow aggregates.
- each nonexperimental cross-product contract has at least one real producer and two real consumers before R1c.

### R2 — Installer and commissioning foundation

Deliverables:

- Nexus base installer consumes the required released contracts. Any future Boot helper's contract consumption is deferred until a concrete proposal is approved;
- for Nexus only, detect usable RAM in MiB after firmware reservation through one product-local selector: less than 7168 diagnostic, 7168–15359 `core`, 15360–31743 `lite`, and 31744 or more `standard`, subject to the measured Core reserve. Each boundary is the nominal size it admits **minus a 1024 MiB firmware-reservation allowance** (8192−1024, 16384−1024, 32768−1024); see [OF-01](#of-01--the-ram-selectors-thresholds-contradict-the-tiers-the-plan-assumes) for why the boundaries are not the nominal sizes themselves;
- for Nexus, evaluate resource and topology profiles separately and enable only their verified intersection;
- for Nexus, inventory interfaces by stable identity and keep operational roles unassigned until commissioning;
- for Nexus, use a composite interface identity (bus path, permanent MAC, VID/PID or PCI identity, serial where present, driver/firmware, wireless PHY, and physical label); zero or multiple matches fail closed and MAC-only matching is insufficient;
- provide one guided setup flow for administrator identity, encrypted storage, deployment profile, asset source, network roles, validation, and activation;
- support signed online manifests and encrypted offline installation bundles through the product-local release-admission policy;
- implement a separate `ASSET_ACQUISITION` state using one operator-selected interface in an outbound-only namespace with endpoint allowlists, metadata/certificate pinning, no forwarding or listening services, bounded downloads, and cleanup of routes, credentials, DNS, proxy state, and association;
- render Suricata and product configuration only after an operator confirms interface roles;
- record a signed installation inventory and activation receipt.
- close the commissioning service after activation; re-entry requires a physical local action, strong administrator authentication, maintenance state, and explicit handling of active leases before roles can change.

> **OF-03 (§15) applies to Nexus only.** Nexus targets UEFI with Secure Boot enabled through a signed shim chain. Disabling Secure Boot is a fallback that requires the machine owner's agreement, known recovery-key location, and restoration at the end of the session. Boot runs inside an OS selected and started by the user; it does not change or attest host firmware. No product enrolls its own key into host firmware.

> **OF-01 (§15) is resolved.** The boundaries above were moved on 2026-09-19 so that a host of each nominal class reaches the tier named after it. They are derived, not chosen: nominal minus a stated 1024 MiB firmware-reservation allowance. No product may substitute its own numbers; a product that believes the allowance is wrong raises a finding rather than diverging locally.

Exit gate:

- a nontechnical operator can follow the Nexus installation guide;
- outside the bounded `ASSET_ACQUISITION` state, no capture, forwarding, Wi-Fi association, external module link, or remote cognition starts before commissioning;
- changed NIC identity returns the affected capability to `COMMISSIONING_REQUIRED`;
- model download or verification failure leaves a working Core environment.
- old-generation replay, renderer/config replacement, path substitution, parallel boot races, and service-default fallback produce zero operational packets/actions.
- a deployment overlay cannot weaken Edge approval, scope, lease, policy, or trust settings.
- observation roles remain Layer-3 unnumbered and transmit zero DHCP, RA, mDNS, LLDP, Wi-Fi probe, or other packets through link flap, resume, and driver reload tests.

### R3 — Deterministic Core integration

Deliverables:

- package Edge evidence, evaluator, arbiter, enforcement, explanation, and audit interfaces for x86_64 systemd deployment;
- preserve existing constrained-device support as a separate compatibility profile; Nexus does not call the current device-specific network installer;
- add a Nexus adapter without moving Edge authority into the integrator;
- map Fabric evidence, decision, receipt, state, audit, and notification projections alongside Edge-native records;
- generate capture configuration for one or more approved observation interfaces;
- implement action leases, idempotency, effective-state verification, rollback, and adapter fencing;
- expose Core health through the common status view.

Exit gate:

- the same captured scenario yields byte-stable deterministic decisions on replay;
- M.I.O., Knowledge, Deception, and Nexus cannot call privileged enforcement directly;
- an expired, replayed, widened, or unsigned action is rejected and audited;
- enforcement verification failure fences new actions for the affected scope and preserves lease expiry.
- clock jumps, reboot, overlapping leases, resource drift, audit pressure, and supervisor failure cannot extend a lease or remove another action's resources.
- management lockout tests prove two-stage rollback through an independent path or physical console.
- injected ENOSPC, EIO, and sync failures before and after each apply transition prove zero unjournaled kernel mutation and a recoverable release record for every applied object.
- each adjacent service identity fails to read/use the arbiter credential, forge or replay a signed intent under another identity, or connect directly to enforcement; each attempt is audited.

### R4 — Embedded Lite capability

Deliverables:

- Knowledge publishes a signed, size-bounded tactical bundle profile for Knowledge Lite;
- Nexus implements a read-only cache runtime that preserves citations and freshness labels;
- Deception publishes a Lite package tier with explicit resource and isolation requirements;
- use neutral artifact profile IDs such as `nexus-embedded-lite`, `knowledge-full-node`, and `deception-full-host`; deployment policy remains in product overlays;
- Nexus implements Deception Lite on a dedicated bridge;
- local M.I.O. uses an approved resource-specific model and a Fabric advisory result contract;
- resource governor reserves Core CPU, memory, I/O, PIDs, audit space, and lease-journal capacity; it sheds remote work, optional model work, background imports, Deception expansion, and then Deception before reducing security-relevant capture.
- continuously evaluate a product-owned isolation attestation over interface identities, routes, ruleset generation, namespaces, sysctls, DNS, IPv4/IPv6/link-local/multicast reachability, and allowed peers.

Exit gate:

- Nexus completes detect -> explain -> decide -> redirect -> audit without external nodes;
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
- Nexus can consume a preapproved emergency Knowledge bundle; live external modules remain an explicit deployment option.

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

- maintain the non-operational user-assistance/tooling scaffold; no runtime installer or deployment artifact is required in this release;
- if a concrete helper is later approved, define its narrow host/tool effects and tests before implementation.

Exit gate:

- a failed update returns to the prior verified generation without losing the last valid audit checkpoint;
- Nexus passes a sustained field workload for its resource tier;
- no Boot implementation or hardware claim is made without a separately approved helper proposal.
- Nexus recovery procedures are executable from offline instructions by an operator who did not build the system.

### R8 — Cross-product release candidate

Deliverables:

- exact released component pins, SBOMs, signatures, source revisions, migration notes, and compatibility matrix;
- clean-room Nexus installation from released artifacts only;
- full scenario replay, failure injection, recovery, and evidence export;
- Nexus verifies the exact artifacts published by the repositories that own them; Boot is not an OS-image publisher.
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

1. Record the Boot user-assistance/tooling role; defer concrete tool and installation proposals until separately specified.
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

Purpose: deterministic decision and enforcement plane integrated by Nexus.

Backlog:

1. Define a supported x86_64 package and preserve existing constrained-device profiles.
2. Inventory current daemons and extract stable service/API boundaries where scripts still share process or file state; split deterministic arbitration from privileged nftables/`tc` execution through a typed local interface.
3. Add deployment profile inputs for interface roles, capture sources, storage paths, and enforcement adapters.
4. Add Fabric projections and import adapters behind exact release pins.
5. Complete Knowledge request/response integration with deadline and no-context fallback.
6. Complete authenticated Deception lease, heartbeat, reconciliation, and routing integration.
7. Prove action leasing, rollback, restart recovery, and no-enforcement-bypass in virtual and physical labs.
8. Keep the existing device-specific installer as a compatibility path and prevent it from being selected by Nexus packages or profiles.

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

Purpose: user assistance and optional responder-tool installation within an
operating environment supplied and started by the user. Boot does not create
Debian Live or another OS, build/write media, or provide Boot-owned persistence.

Next procedure:

1. Identify one concrete user problem and explain why the helper belongs in
   Boot rather than Nexus.
2. Declare supported host environments, authenticated inputs, privileges,
   exact host changes, network behavior, user approval, and rollback/uninstall.
3. Keep provider admission, model fetch, Edge activation and all new authority
   outside scope unless separately approved by their owners.
4. Implement only the reviewed helper and test it in synthetic or disposable
   software environments; make no hardware or OS-image claim.

No image builder, media writer, initramfs quarantine, USB-persistence, or
physical Boot HIL backlog remains. See Boot
[ADR-0012](https://github.com/01rabbit/Azazel-Boot/blob/main/docs/adr/0012-existing-environment-tooling.md).

## 7. Parallel execution model

After R0, work proceeds in four parallel lanes with explicit synchronization points:

| Lane | Repositories | May proceed independently | Synchronization gate |
| --- | --- | --- | --- |
| Contracts | Fabric, Azazel | schemas, fixtures, doctrine | Fabric release candidate |
| Decision and knowledge | Edge, Knowledge | product-local packaging and tests | CTI contract candidate |
| Deception | Deception, Edge | package/isolation and shadow tests | authenticated lease candidate |
| Deployment | Nexus, Boot | Nexus installer; Boot user-assistance proposal | approved contract for each concrete consumer |

Consumers test a Fabric release candidate in CI, then pin the stable tag. Development branches or editable checkouts are allowed in local integration work but cannot satisfy a release gate.

## 8. Quantitative service objectives

Initial release gates use measurable targets. A later change may revise a target only with benchmark evidence and an updated compatibility entry.

Each row below is assigned an owning repository, a product configuration, a start and end event, a clock, a sample rule, a pass rule, a class (software / virtual-lab / hardware-only), and an evidence path in [`service-objective-assignments.md`](service-objective-assignments.md). Until that assignment existed, no repository measured any row and none referenced one, which made this table a release gate nobody could enforce. The assignment changes no target value here; where a target proved unmeasurable as written it is recorded in §15 (OF-05, OF-06).

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
| Observation interface | zero transmitted frames during a 10-minute link/RA/DHCP/resume stress interval |
| Hostile load | Core audit, lease expiry, and health SLOs remain within bounds at each declared ingress quota |

Resource and performance targets are recorded separately for 8, 16, 32, and 64 GB classes. A faster model or larger cache cannot consume the Core reserve.

Four of the ten current rows are hardware-only in their release form (Core-ready-after-unlock, Deception isolation drift, observation-interface silence, and the power-cut half of audit ordering). The former Boot host-storage row was retired with Boot's OS/media scope on 2026-09-28. No green CI run satisfies a hardware-only row. The remaining rows have software or virtual-lab forms, and three of them — P0 alert queueing, lease-expiry rollback start, and the process-kill half of audit ordering — can be measured today.

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
| SR-09 Fabric could grow into an installer/runtime | P1 | R1 includes a static no-side-effect boundary gate |
| SR-10 consumers need different current Fabric features | P2 | compatibility is feature-to-minimum-version; convergence occurs after consumer candidate tests |

## 11. Initial adversarial review record

Three reviewers then attacked the revised plan from supply-chain/Boot, Linux/network/authority, and Knowledge/Deception/model perspectives. Findings with the same root cause are consolidated below; the full review evidence remains attached to the planning change.

| Finding | Highest severity | Correction applied |
| --- | --- | --- |
| AR-01 Fabric activation descriptions could become executable authority | P0 | replaced `ActivationPlan` with descriptive `ProposedGenerationDescriptor`; recursive directive rejection and no-side-effect gates added |
| AR-02 a valid signature could admit obsolete, cross-role, mixed, or semantically hostile assets | P0 | product-local delegated trust, security epochs, exact tested tuples, semantic/resource gates, and hostile signed-asset tests added |
| AR-03 “atomic/full rollback” overstated multi-service reversibility | P0 | generation activation now declares irreversible effects, ordered exposure barriers, owned-resource reconciliation, and `ROLLBACK_INCOMPLETE` |
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
| AR-16 Deception overlays/runtime and Knowledge Lite export could expand access or leak data | P1 | monotonic-reduction overlays, container confinement, export allowlists/redaction, signed policy digest, and privacy canary tests added |

All P0/P1 corrections require focused specialist verification and clean-room adversarial rerun before their affected release gate can close. Documentation changes record the intended control; implementation evidence is still required by R1–R8.

Final focused re-review status: **PASS** from all three review tracks. Each reviewer rechecked only its previously open findings after correction: Fabric/Boot/release engineering (3), Edge/Linux/network authority (2), and Knowledge/Deception/model/data (5). This pass approves the development plan as a review baseline; it does not substitute for the implementation and hardware evidence required at each release gate.

## 12. Cross-product test matrix

| Test | Fabric | Edge | Knowledge | Deception | Nexus | Boot |
| --- | --- | --- | --- | --- | --- | --- |
| Canonical contract and golden fixture | owner | consume | consume | consume | consume | deferred; no Boot consumer specified |
| Deterministic scenario replay | fixture | owner | scoring replay | lifecycle replay | integrate | deferred; no Boot Core specified |
| Missing dependency/module | schema result | continue | advisory unavailable | stop new activation | degrade | deferred |
| Signature/version failure | reject | reject | reject bundle | reject package/decision | quarantine | deferred until helper inputs are defined |
| Interface identity change | assignment model | fence scope | N/A | fence route | recommission | no Boot commissioning scope |
| Resource pressure | profile model | protect Core | bound cache | bound runtime | shed to Core | no Boot runtime profile |
| Network isolation | contract | route authority | N/A | decoy boundary | HIL owner | no Boot network role |
| Audit/evidence integrity | projection | decision chain | advisory chain | outcome chain | system anchor | deferred until a helper requires a record |
| Update/recovery | compatibility | package | package/data | package/runtime | A/B system | no Boot OS/media update |

## 13. Initial issue order

1. Azazel: ratify the Nexus product map, record Boot's user-assistance scope, and maintain this program plan.
2. Fabric: reconcile release status and design provisioning/M.I.O. contracts.
3. Boot: review one concrete existing-environment tool proposal; defer implementation until its scope and host effects are approved.
4. Nexus: align the implementation specification with actual Fabric, Edge, Knowledge, and Deception packages.
5. Edge: x86_64 service packaging and stable integrator boundary.
6. Knowledge: Lite bundle profile and Edge CTI boundary closure.
7. Deception: close physical live gate and define Lite tier.
8. Nexus: installer vertical slice; Boot: no implementation issue until the owner approves a concrete helper proposal.
9. All consumers: Fabric release-candidate compatibility run.
10. Nexus: Core field and emergency exercises, followed by Lite and Full capability gates.

## 14. Program definition of done

The deployment gate is complete when Nexus can be installed and operate standalone on its declared rugged-PC classes. Boot's product-definition gate is met by the accepted user-assistance scope; an implementation gate starts only after a concrete helper proposal is approved. Nexus consumes only contracts its approved design requires; Edge retains sole deterministic authority; status, evidence and claims reflect measured behavior.

## 15. Open program findings

Sections 10 and 11 record findings that were corrected before this plan was published. This section records later findings, including their resolution and residual evidence. Superseded Boot proposals are historical context, not open product requirements. Findings use the fields of §9.2: severity, evidence, affected requirement, proposed correction, owner, and verification.

### OF-01 — the RAM selector's thresholds contradict the tiers the plan assumes

- **Raised:** 2026-09-19, during a cross-repository documentation verification pass.
- **Severity:** historical `P1` for the shared selector proposal. The Boot resource-tier and R4 capability requirements were retired on 2026-09-28; remaining RAM-selector work, if any, belongs to Nexus.
- **Decision issue:** [Azazel #74](https://github.com/01rabbit/Azazel/issues/74), closed as completed.
- **Status:** the Nexus selector correction was recorded 2026-09-19. Boot-specific selector and Lite-capability work was later retired by ADR-0012 on 2026-09-28.

**Evidence.** §5 R2 specifies one product-local selector over usable RAM in MiB after firmware reservation: less than 8192 `diagnostic`, 8192–16383 `core`, 16384–32767 `lite`, 32768 or more `standard`. Usable RAM is always below the nominal module size, because firmware reserves some of it, and each threshold is set at exactly the nominal size it is meant to admit (8192 MiB = 8 GiB, 16384 MiB = 16 GiB, 32768 MiB = 32 GiB). A host of a given nominal size therefore never reaches the threshold named after it; it always falls one tier below.

A measurement on a nominal 16 GB Linux host: `/proc/meminfo` reports `MemTotal: 16481980 kB`, which is 16,095 MiB of usable RAM — 289 MiB short of the 16384 MiB `lite` threshold. That host selects `core`, not `lite`. By the same argument a nominal 8 GB host selects `diagnostic`, not `core`. The Nexus capability model additionally subtracts the measured Core reserve before selection, which moves every host further down, never up.

**What it contradicts.**

1. The R0 baseline's RAM-tier exit criterion: nominal hardware labels must not substitute for usable-RAM measurements.
2. [Azazel-Nexus #5](https://github.com/01rabbit/Azazel-Nexus/issues/5), whose scope quotes the same four thresholds and whose acceptance criterion reads "An 8 GiB system operates deterministic Core with no model or remote dependency." An 8 GiB system selects `diagnostic` under the original thresholds.

§8 of this plan records resource and performance targets for "8, 16, 32, and 64 GB classes" — nominal class names — which is the same mismatch of units seen from the reporting side.

**Where the thresholds have propagated.** Verified by inspection on 2026-09-19:

| Document or issue | Where |
|---|---|
| `Azazel-Nexus/docs/capability-model.md` | §2 resource-profile table, four rows; `standard` repeated at the worked example |
| `Azazel-Nexus/docs/IMPLEMENTATION_SPEC.md` | resource-profile table, four rows |
| `Azazel-Nexus/docs/operations.md` | resource-profile table, four rows, with companion hardware |
| `Azazel-Nexus/docs/mio-runtime.md` | capacity-envelope table, four rows, plus the eligibility vocabulary mapped onto them |
| [Azazel-Nexus #5](https://github.com/01rabbit/Azazel-Nexus/issues/5) | scope and acceptance criteria |
| [Azazel-Nexus #2](https://github.com/01rabbit/Azazel-Nexus/issues/2) (closed) | scope item 4 |

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

**Affected requirements:** §5 R2 selector deliverable; §8 Nexus resource class names; R0 baseline exit criterion on RAM tiers. Boot has no selector or Core-reserve requirement.

**Owner:** Azazel for the Nexus program frame; Nexus owns implementation and measurement. Boot does not inherit the selector.

**Verification.** The Nexus documentation correction remains a target pending measured implementation evidence. No Boot selector implementation or measurement is required under its current scope.

### OF-02 — the selector's output vocabulary and the capability-state vocabulary do not match

- **Raised:** 2026-09-19, while implementing the R1a provisioning contracts. Separate from OF-01 and not resolved by it.
- **Severity:** proposed `P2`. It does not block the selector, but it makes any mapping from a selected tier to a reported capability state a local invention.
- **Decision issue:** [Azazel #77](https://github.com/01rabbit/Azazel/issues/77), closed as completed.
- **Status:** **resolved 2026-09-19 by owner decision.** Candidate resolution 2 was chosen: **there is no mapping.** A resource tier never derives a capability state. The resolution is recorded below.

**Evidence.** §5 R2's selector emits four values: `diagnostic`, `core`, `lite`, `standard`. §3.1's capability summary has three: `CORE`, `LITE`, `FULL`. `diagnostic` has no capability-state counterpart, and `standard` and `FULL` are never reconciled anywhere in this plan. A product that selects `standard` and must report a capability state has no stated rule for which one to report, and a product that selects `diagnostic` has no state at all.

**Why it was not decided alongside OF-01.** OF-01 was an arithmetic defect with a measurable cause. This is a naming decision with consequences for what each state means: whether `standard` and `FULL` are the same thing under two names, whether `diagnostic` is a capability state or the absence of one, and whether a four-value resource vocabulary should map onto a three-value capability vocabulary at all — given that effective capability is an intersection of four dimensions and is not determined by the resource one.

**What was done in the meantime.** `azazel_fabric.provisioning_contracts` encodes **neither** vocabulary as a contract field: a `ResourceProfile` carries measured usable MiB and no tier, and `assert_no_resource_tier_claim` rejects any tier or capability-state field. `registry.CAPABILITY_STATES` exists only so two products name the same summary the same way. Resolving OF-02 therefore changes no contract and invalidates no fixture.

**Resolution — a resource tier never derives a capability state.**

The four selector values and the three capability states are **different kinds of thing**, and no mapping between them exists in either direction. `standard` and `FULL` are **not synonyms**, and `diagnostic` has no capability-state counterpart because it names the **absence** of capability rather than a kind of it.

**Why.** Effective capability is an intersection:

```text
effective capability = resource profile
                     ∩ topology profile
                     ∩ verified asset set
                     ∩ current trust/health state
```

A mapping from tier to state would make the resource dimension decide the product of four dimensions. That is the same error the whole program guards against — the one §5 R2 states as "RAM alone never enables NIC roles, capture, enforcement, or Deception". Declaring the two vocabularies synonymous would have written that error into the vocabulary itself, where it would be invisible.

**What a product reports.** The resource tier and the capability state are reported **separately**. A host that selects `standard` reports `standard` as its resource tier and, independently, whatever capability state the four-dimensional intersection yields — which may be `CORE`. That is not a contradiction to be reconciled; it is the intended and common case, and §3.1's worked example (a 32 GB host with one unsuitable NIC, Standard local cognition, observe-only Core networking, Deception disabled) is exactly it.

**What this settles in the propagated documents.** `Azazel-Nexus/docs/inheritance-ledger.md` already stated the correct rule — "the two are not synonyms and must not be used interchangeably in either repository" — and becomes the canonical statement. `Azazel-Nexus/docs/mio-runtime.md` §2's table, which declared the vocabularies synonyms, is **withdrawn**: it may map each envelope to the eligibility that envelope *permits*, but not to a capability state.

**Not a naming change.** No tier is renamed, no capability state is added or removed, and Edge's `Full-eligible` keeps its meaning — an outcome of the intersection, which is why it was never `standard`'s synonym.

**Affected requirements:** §5 R2 selector deliverable; §3.1 capability summary; any product that must report a state derived from a tier.

**Owner:** Azazel.

**Verification.** The rule is stated once here. The Nexus documents that contradicted it — `mio-runtime.md` §2's synonym table above all — are corrected by the propagation change that accompanies this decision; until that lands, this plan and those documents disagree, and this plan is authoritative. **Not yet done:** the first product that reports both a resource tier and a capability state must carry a test asserting that the state is **not** a function of the tier — that a `standard` host whose topology, assets or trust fall short reports a lower capability state. Until that exists the rule is written down and unproven.

### OF-03 — the Nexus firmware boot path and Secure Boot posture are undeclared (Boot scope retired)

- **Raised:** 2026-09-19, while writing the Nexus and Boot support matrices. The original finding covered both products; the Boot half was retired by owner decision on 2026-09-28.
- **Severity:** proposed `P2` for Nexus firmware compatibility and installer preflight.
- **Decision issue:** [Azazel #79](https://github.com/01rabbit/Azazel/issues/79), closed as completed.
- **Status:** **resolved 2026-09-19 by owner decision.** The frame below is decided; the per-machine answers are measured, not declared.

**Evidence.** The original finding compared the Nexus and Boot support matrices. Boot now runs inside an operating environment already selected and started by the user; it does not choose a firmware path or manage Secure Boot. The remaining product-level firmware questions apply to Nexus; `Azazel-Nexus/docs/IMPLEMENTATION_SPEC.md` §12 says only "UEFI Secure Boot where supported", which is not a requirement.

**Resolution — the frame, not the per-machine answer.**

1. **Nexus booting with Secure Boot enabled is the target**, via a signed chain; UEFI is assumed for Nexus.
2. **Disabling Secure Boot is a fallback, never the default**, and it is permitted only with the machine owner's explicit agreement, only after the location of the host's disk-encryption recovery key has been established, and it must be restored at the end of the session.
3. **Enrolling a product key into the host (MOK) is not adopted.** It writes a key into someone else's firmware and survives the session.
4. **A qualified Nexus hardware entry records the Secure Boot state that was observed.** Nexus does not declare Secure Boot support for a machine nobody has tested.

**Why disabling is the fallback rather than the plan.** Firmware-state changes can impose costs on the machine owner and are not a prerequisite an installer may assume.

One risk is disk-encryption recovery. Windows BitLocker with a TPM protector is commonly sealed against a PCR that measures Secure Boot state. Turning Secure Boot off can change that measurement, cause the TPM not to release the key, and require the recovery key on the next boot. A Nexus installer must not change firmware state or assume the recovery key is available.

Firmware passwords and policy can also prevent an operator from changing settings. An installation plan that requires such changes is not generally deployable.

**What this constrains.** The Nexus installer must preserve the host distribution's supported Secure Boot path and must not change firmware state. Boot has no firmware or boot-chain selection responsibility.

**What is not decided, and is not decidable here.** Whether any specific machine boots this way is a measurement. No hardware has been tested, the compatibility list is empty, and the state of the industry transition away from the expiring Microsoft UEFI CA 2011 certificate must be checked against firmware in hand rather than assumed — a machine whose firmware never received the newer CA in a database update will not trust a shim signed under it.

**Affected requirements:** Nexus installer preflight and support matrix; Boot firmware requirements were retired by Boot ADR-0012.

**Owner:** Azazel (the frame). Per-machine Secure Boot state belongs to each product's compatibility evidence.

**Verification.** Nexus must record observed firmware state in any future qualified hardware entry. No Nexus Secure Boot result is claimed. Boot does not inspect or change firmware.

### OF-04 — recorded in Azazel-Nexus

OF-04 (composition modes such as `KNOWLEDGE-EXTENDED` / `DECEPTION-EXTENDED` are composition modes only, never capability states) is recorded in `Azazel-Nexus/docs/capability-model.md` §1.1, where the composition axis it concerns is defined. The number is reserved here so this register is continuous and the gap is not read as an omission.

### OF-05 — §8's lease-expiry completion bound is action-specific, and no action declares one

**Finding.** §8 bounds the *start* of lease-expiry rollback at 5 seconds and says the completion bound "is action-specific". No action type declares a completion bound in any repository. Searching the seven repositories on 2026-09-19 finds no per-action rollback completion target anywhere.

The start half is measurable and is assigned (SO-04). The completion half is **unmeasurable as written**: a bound that defers to a per-action value which does not exist cannot pass or fail. A release gate that reads it would be reading nothing.

§4.3 does define a *state* for the incomplete case — an adapter reports `ROLLBACK_INCOMPLETE` until observed state matches — so the program can say when rollback has not finished. It cannot say when that is too late, which is what a release gate needs.

**Why this is not repaired here.** Inventing completion bounds would be revising a target without the benchmark evidence §8 requires, and the bounds belong to whoever owns each action type, not to the program document.

**Affected requirements:** §8 lease-expiry row; §5 R3 exit gate; `service-objective-assignments.md` SO-04.

**Owner:** Azazel-Edge, which owns the enforcement lease and the action types. The program plan holds the finding until Edge declares the per-action bounds and the §8 row can name where they live.

**Verification.** Resolved when every declared enforcement action type has a stated rollback completion bound in its owning repository, SO-04 cites them, and a measurement record exists. **Not yet done:** no bound is declared and nothing has been measured.

### OF-06 — §8's hostile-load row presumes declared ingress quotas that do not exist

**Finding.** §8's hostile-load row requires that "Core audit, lease expiry, and health SLOs remain within bounds at each declared ingress quota", and §5 R5's exit gate repeats it as staying "within per-peer quotas and Core service objectives". **No repository declares an ingress quota.** Searching the seven repositories on 2026-09-19 finds no declared per-peer or ingress quota value.

The row is therefore **unmeasurable as written**: "at each declared quota" ranges over an empty set, which makes the condition vacuously satisfiable. A gate that passes because there is nothing to check is worse than no gate, because it reports a pass.

**Why this is not repaired here.** Choosing quota values is a product decision with hardware-class consequences, and §8 forbids revising a target without benchmark evidence. The quotas must be declared, then measured, then recorded.

**Affected requirements:** §8 hostile-load row; §5 R5 exit gate; `service-objective-assignments.md` SO-11.

**Owner:** Azazel-Edge for the Core ingress quota; Azazel-Nexus for the per-peer module quotas its module manager admits.

**Verification.** Resolved when each owning repository declares its quota values with the hardware class they apply to, SO-11 cites them, and a measurement record exists for each — including the 120%-of-highest run that proves the quota sheds rather than merely being written down. **Not yet done:** no quota is declared and nothing has been measured.

### OF-07 — Nexus platform baseline and Boot scope

- **Raised:** 2026-09-22 during installer and deployment planning.
- **Status:** the Nexus baseline decision remains applicable to Nexus. The Boot media-build half of the original finding was retired by the owner on 2026-09-28 (see the scope correction above).

**Nexus baseline:** Debian 13 / amd64 minimal installation; signed netinst or a verified offline installation bundle; UEFI with Secure Boot enabled as the default where supported; LUKS2 required, with an optional TPM2 protector and recovery passphrase. Firmware additions beyond the declared Debian repositories are recorded in release evidence. Other distributions remain future evaluation profiles, not current support claims.

The baseline does not imply that Nexus installation, Secure Boot behavior, or hardware compatibility has been proven on a particular machine. Hardware measurements remain owned by Nexus.

**Affected requirements:** Nexus installer preflight, `Azazel-Nexus/docs/IMPLEMENTATION_SPEC.md` §§2 and 12, and the Nexus support matrix. No Boot builder, image, media, persistence, firmware, or hardware gate follows from this finding.

**Owner:** Azazel for the cross-repository frame; Azazel-Nexus for implementation and per-machine evidence.

**Verification:** maintain the Nexus baseline and record per-machine installation and compatibility evidence in the Nexus repository. Boot scope is defined by ADR-0012 in Azazel-Boot; no Boot image-building verification applies.
