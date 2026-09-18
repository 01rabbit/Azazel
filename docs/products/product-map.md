# Product Map

Back to: [Products Index](README.md) | Related: [Naming Convention](../specs/naming.md)

## Doctrine to Implementation

- **Doctrine layer:** Azazel naming and doctrine hub ([README](../../README.md))
- **Defensive implementation layer:** [Azazel-Edge Gateway](https://github.com/01rabbit/Azazel-Edge) (AZ-01), [Azazel-Gadget Shield](https://github.com/01rabbit/Azazel-Gadget) (AZ-02), [Azazel-Boot Responder](https://github.com/01rabbit/Azazel-Boot) (AZ-03), and [Azazel-Nexus Gateway](https://github.com/01rabbit/Azazel-Nexus) (AZ-07)
- **Knowledge / advisory plane:** [Azazel-Knowledge Advisor](https://github.com/01rabbit/Azazel-Knowledge) (AZ-04, formerly Azazel-CTI) — optional advisory-only CTI and Behavioral CTI node
- **Contracts layer:** [Azazel-Fabric Contract](https://github.com/01rabbit/Azazel-Fabric) (AZ-05, formerly Azazel-Common) — shared contracts and interoperability; no product decision logic
- **Engagement-environment plane:** [Azazel-Deception Host](https://github.com/01rabbit/Azazel-Deception) (AZ-06, codename `THEATRE`) — portable, capability-aware, container-first runtime for materializing Edge-approved deception environments

## Positioning

Azazel is the doctrine.

Azazel-Edge and Azazel-Gadget are defensive implementations optimized for different operational contexts. Azazel-Boot provides a removable civil emergency environment. Azazel-Nexus assembles a persistent self-contained node for rugged Linux PCs. Azazel-Deception is the attacker-facing execution plane used when a deployment needs coherent deception environments beyond Edge's bounded redirect and pre-positioned decoys.

Fabric and Knowledge remain support planes: Fabric supplies the shared language; Knowledge supplies evidence-backed advisory context. Deception executes only within an Edge-approved boundary.

The system responsibility rule is:

> Engage expresses intent. Knowledge advises. Fabric describes. Edge decides and enforces. Deception Host materializes, transitions, records, and resets.

Formal naming follows `Azazel-<Form> <Role>`. `Deception` and `Host`, the `AZ-06` accession, and codename `THEATRE` were ratified on 2026-08-13 after creation of `01rabbit/Azazel-Deception`.

## AZ-06 Deployment Model

AZ-06 is a software/runtime class, not a Raspberry Pi-specific hardware product.

- **Minimum reference host:** Raspberry Pi 5 or equivalent ARM64 SBC for lightweight Linux container profiles.
- **Standard host:** N100/N305-class x86 mini PC with NVMe for multiple containers and richer deterministic environments.
- **Heavy host:** x86/KVM platform for later VM-capable and multi-segment profiles.
- **Future cluster profile:** multiple AZ-06 nodes with distinct capability classes; Edge remains decision authority and never becomes a general-purpose scheduler.

The initial portability baseline is OCI containers, `linux/arm64` and `linux/amd64`, and a Docker Compose runtime adapter. Packages declare required capabilities and package-authored deployment tiers. Unsupported packages fail closed rather than silently degrading required narrative or isolation components.

AZ-06 bootstraps in dry-run mode: capability discovery, package validation, deterministic placement planning, a static Linux reference package, CI, and safety documentation exist in the repository. Live activation remains gated on the canonical Fabric contract and Edge authorization path.

Detailed design: [AZ-06 Container-First Deception Host](../concepts/azazel-deception-host-container-first.md).

## Selection Guide

- Choose **Azazel-Edge Gateway** for edge SOC/NOC and field gateway operations, deterministic action selection, routing, and engagement authority.
- Choose **Azazel-Gadget Shield** for personal tactical defense on untrusted Wi-Fi and fixed Engage-lite deception profiles.
- **Azazel-Boot Responder** is the target for civil emergency startup from a USB SSD on a declared compatible laptop. Its release gate requires per-host commissioning before operational networking and Core usability without optional services.
- **Azazel-Nexus Gateway** is the target for sustained operation on a rugged Linux PC with embedded Knowledge Lite and Deception Lite, local M.I.O., audit, and optional full Knowledge/Deception nodes. Its release gate requires standalone Core behavior and topology-gated enforcement.
- Add **Azazel-Knowledge Advisor** when you want optional advisory-only threat context and Behavioral CTI. Edge stays functional if Knowledge is absent, slow, malformed, or wrong.
- Use **Azazel-Fabric Contract** when you need the shared cross-product schemas and invariant vocabulary. Fabric describes; it never decides.
- Deploy **Azazel-Deception Host** when you need coherent service, artifact, credential, persona, or staged deception environments. Pi 5 is a minimum reference host, not a product constraint.
- Read this repository when you need naming, doctrine, architecture framing, responsibility boundaries, and cross-product sequencing.
