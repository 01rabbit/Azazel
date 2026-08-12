---
title: AZ-06 Container-First Deception Host
nav_exclude: false
---

# AZ-06 Azazel-Deception Host — Container-First Architecture Baseline

Status: **active bootstrap architecture**. Repository: [01rabbit/Azazel-Deception](https://github.com/01rabbit/Azazel-Deception). Naming and series accession were ratified on 2026-08-13; implementation sequencing remains tracked in [Azazel#61](https://github.com/01rabbit/Azazel/issues/61).

## Decision

AZ-06 is a **portable, capability-aware, container-first deception runtime**, not a Raspberry Pi-specific appliance.

Raspberry Pi 5 is the minimum reference host for lightweight profiles. The same control plane and deception-package identity must scale to x86 mini PCs, larger servers, and future multi-node deployments without changing Edge authority or package semantics.

> Hardware supplies capacity. The package defines the narrative. AZ-06 supplies the safe runtime. Edge remains the authority.

## Current bootstrap implementation

`01rabbit/Azazel-Deception` now contains:

- host capability discovery
- fail-closed bootstrap package validation
- deterministic, non-executing placement planning
- a static Linux reference package
- an isolated Docker Compose reference asset with no host ports or external network
- ARM64/AMD64 portability requirements
- CI and deterministic bootstrap tests
- safety, contract-integration, architecture, and roadmap documentation

Live activation is intentionally disabled until the canonical Azazel-Fabric deception-environment contracts and the Azazel-Edge activation/termination path are implemented and tested.

## Architectural layers

```text
Deception Package
  Narrative / persona / artifacts / credentials / allowed transitions
                         |
                         v
AZ-06 Control Plane
  capability detection / validation / placement / lifecycle / evidence
                         |
                         v
Runtime Adapter
  Docker Compose initially; Podman and KVM/libvirt later
                         |
                         v
Execution Host
  Raspberry Pi 5 / ARM64 SBC / x86 mini PC / server / future cluster
```

The layers remain separable:

- `DeceptionPackage` describes the coherent environment and safety requirements.
- The AZ-06 control plane validates packages, compares requirements with host capabilities, selects only a package-authored deployment tier, and controls local lifecycle.
- Runtime adapters translate an approved plan into container or VM operations.
- Hardware is replaceable capacity and does not become part of the narrative contract unless a profile explicitly requires a capability.

## Initial portability baseline

Phase 1 supports or targets:

- OCI images
- `linux/arm64` and `linux/amd64`
- Docker Compose as the first reference runtime
- Linux container deception profiles
- immutable versioned images and signed package manifests once the Fabric contract lands
- no requirement for GPU, KVM, Kubernetes, or an online LLM

Podman may follow as an equivalent rootless-capable runtime. KVM/libvirt and cluster orchestration are later adapters and are not prerequisites for the first live release.

## Host capability model

Every AZ-06 node publishes a signed/authenticated capability report once the canonical Fabric shape exists. The bootstrap repository currently emits a descriptive local shape containing node identity, architecture, CPU, memory, storage, available runtime adapters, KVM/GPU flags, and supported profile classes.

Capability reports are descriptive. They never authorize package activation. Edge remains the activation and transition authority.

## Package runtime requirements

Every deployable package declares minimum and optional capabilities. Missing required capabilities fail closed. The runtime never silently approximates required narrative components or weakens isolation to fit weaker hardware.

The initial reference package supports both `arm64` and `amd64`, requires Docker Compose, prohibits production access and egress, and offers explicit `lite` and `standard` tiers.

## Deployment tiers

| Tier | Reference host | Intended scope |
|---|---|---|
| `lite` | Raspberry Pi 5 / ARM64 SBC, 8–16 GB | one to three lightweight Linux decoys, fixed traces, low-interaction services |
| `standard` | N100/N305-class x86, 16–32 GB, NVMe | multiple containers, richer file/credential paths, deterministic persona activity |
| `heavy` | x86 host, 32–64 GB+, KVM | later mixed containers/VMs, Windows-capable profiles, multi-segment environments |
| `cluster` | multiple nodes | future distributed environment classes and higher concurrency |

A tier changes **capacity and explicitly optional components**, not the logical truth of the narrative. Required components cannot be removed by automatic degradation.

## Scaling model

### Vertical scaling

The same package and AZ-06 control-plane semantics may move from Raspberry Pi 5 to a larger x86 host. Higher-capacity hosts may increase approved concurrency, optional surfaces, evidence retention, and interaction depth.

### Horizontal scaling

Multiple AZ-06 nodes may advertise different capability classes. Edge may approve a target node or capability class, but Edge must not become a Docker, KVM, Proxmox, or Kubernetes scheduler. AZ-06 owns local placement inside the approved package, tier, budget, and network boundary.

Initial releases do not support live migration of an active attacker session. Migration means terminate, preserve evidence, reset, redeploy on the new host, and require a new Edge activation decision.

## Runtime adapter boundary

Target adapter interface:

- `inspect_capabilities()`
- `validate_package()`
- `plan_deployment()`
- `activate_environment()`
- `apply_approved_transition()`
- `collect_status()`
- `terminate_environment()`
- `reset_environment()`
- `export_evidence()`

Initial adapter path:

- Docker Compose

Future adapters:

- Podman / Podman Compose
- KVM/libvirt
- Proxmox integration
- K3s/Kubernetes only after single-node authority, isolation, reset, and evidence semantics are stable

Runtime-specific identifiers never become authority-bearing identifiers.

## State separation

Keep four state classes separate:

1. **OCI image** — immutable executable content.
2. **Signed Deception Package** — narrative, manifests, constraints, tiers, and transitions.
3. **Runtime state** — current approved environment state and bounded session data.
4. **Evidence store** — interaction evidence, audit references, outcomes, and teardown records.

No authoritative state depends only on an ephemeral container filesystem. Reset preserves required evidence while destroying attacker-modified runtime state and invalidating decoy credentials.

## LLM boundary

LLM use is optional and belongs primarily to package preparation:

```text
LLM draft
  -> deterministic schema and consistency validation
  -> operator or policy approval
  -> frozen, versioned, signed Deception Package
  -> runtime execution without LLM dependency
```

Permitted uses include narrative/persona drafts, synthetic document drafts, consistency suggestions, and operator-facing report drafting.

Prohibited uses include runtime action selection, autonomous container/VM creation, arbitrary port exposure, unapproved credential issuance, free-form transition selection, and Edge authority override.

Approved environments remain executable when an LLM is absent or stopped.

## Edge co-location profiles

Containerization permits a limited co-located profile on Azazel-Edge for development and demonstrations, but this is not the recommended field architecture.

Allowed co-located bootstrap profile:

- one static Linux environment
- small number of allowlisted low-interaction services
- no runtime LLM
- strict CPU, memory, PID, storage, duration, connection, and bandwidth limits
- read-only root filesystem where possible
- no privileged containers
- no host networking
- no Docker socket mount
- no access to Edge control APIs or protected networks
- egress denied by default
- deterministic reset

Recommended field profile: a separate AZ-06 host or stronger isolated virtualization boundary on a dedicated decoy segment.

## Security invariants

- Edge remains the sole activation, transition-approval, downgrade, routing, budget, and termination authority.
- Capability negotiation never grants authority.
- No package may request unrestricted egress or production access.
- Unsupported architecture, runtime, tier, digest/signature, or capability fails closed.
- Multi-architecture images must be digest-pinned and verified before live release.
- Runtime adapters enforce resource/network limits independently of narrative content.
- A compromised decoy workload must not reach the AZ-06 control plane, Edge control APIs, protected networks, runtime socket, or host management interfaces.
- Existing Edge, Gadget, Knowledge, and Fabric behavior remains unchanged unless AZ-06 integration is explicitly enabled.

## Delivery sequence

1. Repository bootstrap and naming ratification — **complete**.
2. Extend Fabric with canonical capability, package, tier, runtime-adapter, placement, lifecycle, image, evidence, and outcome contracts.
3. Promote the Docker Compose adapter from non-executing reference asset to feature-disabled runtime code.
4. Run the same static Linux reference package on both ARM64 and AMD64.
5. Validate resource limits, isolation, evidence export, termination, and deterministic reset.
6. Integrate Edge in shadow/replay mode before live activation.
7. Add standard-tier multi-container profiles.
8. Add deterministic persona/artifact/credential and finite-state transition features.
9. Add KVM or cluster adapters only after single-node properties are proven.

## Acceptance criteria

- The same signed reference package runs on supported ARM64 and AMD64 hosts with equivalent narrative and audit semantics.
- Host capabilities and package requirements are versioned and validated before activation.
- Unsupported packages fail closed with an explicit reason.
- Deployment-tier selection cannot remove required narrative components.
- AZ-06 can move from Pi 5 to x86 without changing Edge authority or package identity.
- Runtime state and evidence survive controlled redeployment without relying on container-local authoritative state.
- LLM absence does not affect execution of an approved package.
- Co-located Edge operation is limited to development/demo profiles; field guidance recommends separation.
