# Product Map

Back to: [Products Index](README.md) | Related: [Naming Convention](../specs/naming.md)

## Doctrine to Implementation

- **Doctrine layer:** Azazel naming and doctrine hub ([README](../../README.md))
- **Implementation layer:** [Azazel-Edge](https://github.com/01rabbit/Azazel-Edge), [Azazel-Gadget](https://github.com/01rabbit/Azazel-Gadget)
- **Knowledge / advisory plane:** [Azazel-Knowledge Advisor](https://github.com/01rabbit/Azazel-Knowledge) (AZ-04, formerly Azazel-CTI) — an optional, advisory-only CTI node that enriches edge decisions without holding authority
- **Contracts layer:** [Azazel-Fabric Contract](https://github.com/01rabbit/Azazel-Fabric) (AZ-05, formerly Azazel-Common) — the shared contracts library the series speaks, not a decision core
- **Provisional engagement-environment plane:** `Azazel-Deception Host` (candidate AZ-06, codename `THEATRE`) — a portable, capability-aware, container-first runtime for materializing Edge-approved deception environments. This product is proposed in [Azazel#61](https://github.com/01rabbit/Azazel/issues/61); its name and accession are not yet ratified.

## Positioning

Azazel is the doctrine.

Azazel-Edge and Azazel-Gadget are concrete implementation variants optimized for different operational contexts.

Edge, Gadget, and Boot are the defensive deployment classes; Fabric and Knowledge are the support classes that make the Azazel System work as a series. The proposed Deception Host adds a separate attacker-facing engagement-environment execution plane without moving decision authority away from Edge.

Azazel-Knowledge Advisor and Azazel-Fabric Contract are complements to the appliances, not alternatives to them: the CTI node advises the deterministic edge, and Azazel-Fabric Contract supplies the shared contracts that let the series interoperate.

The proposed AZ-06 boundary is:

> Engage expresses intent. Knowledge advises. Fabric describes. Edge decides and enforces. Deception Host materializes, transitions, records, and resets.

Formal naming for externally presented products follows `Azazel-<Form> <Role> - Cyber Scapegoat Gateway`. `Deception` and `Host` remain candidate vocabulary until the naming specification is explicitly updated.

## Provisional AZ-06 Deployment Model

AZ-06 is a software/runtime class, not a Raspberry Pi-specific hardware product.

- **Minimum reference host:** Raspberry Pi 5 or equivalent ARM64 SBC for lightweight Linux container profiles.
- **Standard host:** N100/N305-class x86 mini PC with NVMe for multiple containers and richer deterministic environments.
- **Heavy host:** x86/KVM platform for VM-capable and multi-segment profiles.
- **Future cluster profile:** multiple AZ-06 nodes with distinct capability classes; Edge remains the decision authority and does not become a general-purpose scheduler.

The initial portability baseline is OCI containers, `linux/arm64` and `linux/amd64`, and a Docker Compose runtime adapter. Packages declare required capabilities and optional deployment tiers. Unsupported packages fail closed rather than silently degrading required narrative components.

The detailed proposal is documented in [AZ-06 Container-First Deception Host](../concepts/azazel-deception-host-container-first.md).

## Selection Guide

- Choose **Azazel-Edge** for edge SOC/NOC and field gateway operations.
- Choose **Azazel-Gadget** for personal tactical defense on untrusted Wi-Fi.
- Add **Azazel-Knowledge Advisor** when you want an optional, advisory-only knowledge plane that enriches edge decisions with deterministic threat context. It never commands, and the edge stays fully functional if it is absent, slow, or wrong.
- Reach for **Azazel-Fabric Contract** when you are building on the series and need the shared contracts layer; it is the common language, not a decision core.
- Evaluate the **proposed Azazel-Deception Host** when a deployment needs coherent service, artifact, credential, persona, or staged deception environments beyond Edge's bounded redirect and pre-positioned decoy capabilities. Use Pi 5 as a minimum reference host, not as a product constraint.
- Read this repository when you need naming, philosophy, architecture framing, and cross-product doctrine.
