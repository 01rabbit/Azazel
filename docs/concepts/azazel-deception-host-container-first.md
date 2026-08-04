---
title: AZ-06 Container-First Deception Host
nav_exclude: false
---

# AZ-06 Azazel-Deception Host — Container-First Architecture Proposal

Status: **provisional design**. This document supports [Azazel#61](https://github.com/01rabbit/Azazel/issues/61). The product name, AZ number, and new naming vocabulary remain subject to ratification.

## Decision

AZ-06 is defined as a **portable, capability-aware, container-first deception runtime**, not as a Raspberry Pi-specific appliance.

Raspberry Pi 5 is the minimum reference host for lightweight profiles. The same control plane and signed deception packages must scale to x86 mini PCs, larger servers, and future multi-node deployments without changing Edge authority or package semantics.

> Hardware supplies capacity. The package defines the narrative. AZ-06 supplies the safe runtime. Edge remains the authority.

## Architectural layers

```text
Deception Package
  Narrative / persona / artifacts / credentials / allowed transitions
                         |
                         v
AZ-06 Control Plane
  capability detection / validation / scheduling / lifecycle / evidence
                         |
                         v
Runtime Adapter
  Docker or Podman initially; KVM/libvirt and cluster adapters later
                         |
                         v
Execution Host
  Raspberry Pi 5 / ARM64 SBC / x86 mini PC / server / cluster
```

The layers must remain separable:

- `DeceptionPackage` describes the coherent environment and its safety requirements.
- The AZ-06 control plane validates packages, compares requirements with host capabilities, selects a permitted deployment tier, and controls lifecycle.
- Runtime adapters translate the approved plan into container or VM operations.
- Hardware is replaceable capacity and must not become part of the narrative contract unless a profile explicitly requires a capability.

## Initial portability baseline

Phase 1 must support:

- OCI images
- `linux/arm64` and `linux/amd64`
- Docker Compose as the first reference runtime
- Linux container deception profiles
- immutable versioned images and signed package manifests
- no requirement for GPU, KVM, Kubernetes, or an online LLM

Podman support may follow as an equivalent rootless-capable runtime. KVM/libvirt and cluster orchestration are later adapters and must not be prerequisites for the first release.

## Host capability model

Every AZ-06 node must publish a signed or authenticated capability report containing at least:

```yaml
host_capabilities:
  node_id: az06-node-a
  architecture: arm64
  cpu_cores: 4
  memory_mb: 8192
  storage_free_mb: 64000
  container_runtime: docker
  runtime_version: "..."
  kvm_available: false
  gpu_available: false
  network_features:
    vlan: true
    macvlan: true
  supported_profile_classes:
    - static_linux
    - low_interaction_services
```

Capability reports are descriptive. They do not authorize package activation. Edge remains the activation and transition authority.

## Package runtime requirements

Every deployable package must declare minimum and optional capabilities:

```yaml
runtime_requirements:
  architectures:
    - arm64
    - amd64
  minimum_cpu_cores: 2
  minimum_memory_mb: 2048
  minimum_storage_mb: 8192
  requires_kvm: false
  requires_gpu: false
  required_runtime_features:
    - read_only_rootfs
    - resource_limits
    - isolated_network
```

A package must fail closed when required capabilities are absent. The runtime must not silently approximate required narrative components.

## Deployment tiers

A package may define explicit, validated tiers:

| Tier | Reference host | Intended scope |
|---|---|---|
| `lite` | Raspberry Pi 5 / ARM64 SBC, 8–16 GB | One to three lightweight Linux decoys, fixed persona traces, low-interaction services |
| `standard` | N100/N305-class x86, 16–32 GB, NVMe | Multiple containers, richer file and credential paths, deterministic persona activity |
| `heavy` | x86 host, 32–64 GB+, KVM | Mixed containers and VMs, Windows-capable profiles, multi-segment environments |
| `cluster` | Multiple nodes | Distributed environment classes and higher concurrency; future scope |

A tier changes **capacity and explicitly optional components**, not the logical truth of the narrative.

Required and optional components must be declared:

```yaml
components:
  primary_file_server:
    required: true
  auxiliary_mail_server:
    required: false
    minimum_tier: standard
  simulated_backup_server:
    required: false
    minimum_tier: heavy
```

The control plane may select only a package-authored tier that satisfies all required components and remains within an Edge-approved budget.

## Scaling model

### Vertical scaling

The same package and control plane may move from Raspberry Pi 5 to a larger x86 host. Higher-capacity hosts may increase approved concurrency, optional surfaces, evidence retention, and interaction depth.

### Horizontal scaling

Multiple AZ-06 nodes may advertise different capability classes:

```text
Azazel-Edge
  |- AZ-06 node A: ARM64 lightweight Linux profiles
  |- AZ-06 node B: x86/KVM Windows-capable profiles
  `- AZ-06 node C: isolated OT/IoT profiles
```

Edge selects an approved profile and target capability class. Edge must not become a general-purpose container scheduler. AZ-06 owns placement within the constraints of the signed package and Edge decision.

Initial releases should not support live migration of an active attacker session. Migration means terminate, preserve evidence, reset, redeploy on the new host, and issue a new Edge activation decision.

## Runtime adapter boundary

Define a narrow adapter interface such as:

- `inspect_capabilities()`
- `validate_package()`
- `plan_deployment()`
- `activate_environment()`
- `apply_approved_transition()`
- `collect_status()`
- `terminate_environment()`
- `reset_environment()`
- `export_evidence()`

Initial adapter:

- Docker Compose

Future adapters:

- Podman Compose
- KVM/libvirt
- Proxmox integration
- K3s/Kubernetes only after single-node authority, isolation, reset, and evidence semantics are stable

Runtime-specific identifiers must not leak into the portable package authority model.

## State separation

Keep four state classes separate:

1. **OCI image** — immutable executable content.
2. **Signed Deception Package** — narrative, manifests, constraints, tiers, and transitions.
3. **Runtime state** — current approved environment state and bounded session data.
4. **Evidence store** — interaction evidence, audit references, outcomes, and teardown records.

No authoritative state may depend only on an ephemeral container filesystem. Reset must preserve required evidence while destroying attacker-modified runtime state and invalidating decoy credentials.

## LLM boundary

LLM use is optional and belongs primarily to package preparation:

```text
LLM draft
  -> deterministic schema and consistency validation
  -> operator or policy approval
  -> frozen, versioned, signed Deception Package
  -> runtime execution without LLM dependency
```

Permitted uses:

- narrative and persona drafts
- honey-document drafts
- consistency review suggestions
- operator-facing report drafting

Prohibited uses:

- runtime action selection
- autonomous container or VM creation
- arbitrary port exposure
- credential issuance outside approved manifests
- free-form transition selection
- Edge authority override

An AZ-06 node may host an optional local LLM container for offline preparation, but active environments must remain operational when the model is absent or stopped. Larger models may run on an external preparation node or GPU host.

## Edge co-location profiles

Containerization permits a limited co-located profile on Azazel-Edge for development and demonstrations, but not as the recommended field architecture.

### Allowed co-located profile

- one static Linux environment
- small number of allowlisted low-interaction services
- no runtime LLM
- strict CPU, memory, PID, storage, duration, and bandwidth limits
- read-only root filesystem where possible
- no privileged containers
- no host networking
- no Docker socket mount
- no access to Edge control APIs or protected networks
- egress denied by default
- deterministic reset

### Recommended field profile

Use a separate AZ-06 host or stronger isolated virtualization boundary on a dedicated decoy segment. Attacker-facing workloads must not share the Edge failure and compromise domain when mission availability matters.

## Security invariants

- Edge remains the sole activation, transition-approval, downgrade, routing, and termination authority.
- Capability negotiation never grants authority.
- No package may request unrestricted egress or production access.
- Unsupported architecture, runtime, tier, image digest, or capability fails closed.
- Multi-architecture images must be digest-pinned and verified.
- Runtime adapters must enforce resource and network limits independently of package content.
- A compromised decoy workload must not reach the AZ-06 control plane, Edge control APIs, protected networks, runtime socket, or host management interfaces.
- Existing Edge, Gadget, Knowledge, and Fabric behavior remains unchanged unless AZ-06 integration is explicitly enabled.

## Delivery sequence

1. Ratify product boundary and container-first architecture.
2. Extend Fabric with host capability, package requirement, tier, runtime-adapter, placement, and lifecycle contracts.
3. Implement Docker Compose adapter and multi-architecture CI fixtures.
4. Implement one static Linux reference package on both ARM64 and AMD64.
5. Validate resource limits, isolation, evidence export, and deterministic reset.
6. Integrate Edge in shadow/replay mode before live activation.
7. Add standard-tier multi-container profiles.
8. Add KVM or cluster adapters only after single-node properties are proven.

## Acceptance criteria

- The same signed reference package runs on supported ARM64 and AMD64 hosts with equivalent narrative and audit semantics.
- Host capabilities and package requirements are versioned and validated before activation.
- Unsupported packages fail closed with an explicit reason.
- Deployment-tier selection cannot remove required narrative components.
- AZ-06 can move from Pi 5 to x86 without changing Edge authority or package identity.
- Runtime state and evidence survive controlled redeployment without relying on container-local authoritative state.
- LLM absence does not affect execution of an approved package.
- Co-located Edge operation is explicitly limited to development/demo profiles; field guidance recommends separation.
