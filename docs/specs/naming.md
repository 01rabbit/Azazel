---
title: Naming
nav_order: 6
nav_exclude: false
---

# Naming Convention

Back to: [README](../../README.md) | [Product Map](../products/product-map.md)

## Canonical Structure

Formal name format:

`Azazel-<Form> <Role>`

Recommended external format:

`Azazel-<Form> <Role> - Cyber Scapegoat Gateway`

`Cyber Scapegoat Gateway` is the fixed external banner phrase.

## Form Vocabulary

- `Gadget`: USB gadget direct-connect class (smallest and most portable form).
- `Edge`: resident edge class for boundary operation on SBC/miniPC hardware.
- `Boot`: bootable rapid-response class (portable USB boot operation).
- `Nexus`: persistent integrated rugged Linux deployment class.
- `Fabric`: cross-product interoperability and shared-contract class.
- `Knowledge`: resident threat-knowledge and intelligence-support class.
- `Deception`: portable engagement-environment execution class that materializes bounded attacker-facing deception packages without owning decision authority.

## Role Vocabulary

- `Gateway`: boundary gateway for multiple endpoints or small networks.
- `Shield`: forward defensive layer for a single user or endpoint.
- `Probe`: observation and measurement focused role with minimal control.
- `Responder`: civil emergency role for rapid assessment, bounded local response, evidence handling, and recovery support.
- `Advisor`: advisory knowledge provider without enforcement authority.
- `Contract`: shared schemas, interfaces, and interoperability definitions.
- `Host`: execution host that materializes approved isolated environments and owns their local lifecycle, evidence export, and reset.

Do not introduce extra Form or Role words without updating this specification first.

Edge, Gadget, Boot, and Nexus are defensive deployment classes. Deception is the
attacker-facing engagement-environment execution class. Fabric and Knowledge
are support classes that make the Azazel System work as a series. Every
product follows the uniform `Azazel-<Form> <Role>` grammar.

## AZ Numbering

`AZ-xx` is a series accession number, assigned in the order a repository
joined the Azazel series or explicitly reserved for a named future product.
An activated repository retains its matching prior reservation. It is not
limited to appliance form factors; the knowledge-plane node, contracts
library, and engagement-environment runtime carry numbers too.

Current assignments:

- `AZ-01`: Azazel-Edge Gateway
- `AZ-02`: Azazel-Gadget Shield
- `AZ-03`: Azazel-Boot Responder
- `AZ-04`: Azazel-Knowledge Advisor
- `AZ-05`: Azazel-Fabric Contract
- `AZ-06`: Azazel-Deception Host
- `AZ-07`: Azazel-Nexus Gateway

## Legacy Name Mapping

- `Azazel-Pi` -> `Azazel-Edge` (formerly)
- `Azazel-Zero` -> `Azazel-Gadget` (formerly)
- `Azazel-USB` -> `Azazel-Boot` (same meaning)
- `Azazel-CTI` -> `Azazel-Knowledge` (formerly, working name)
- `Azazel-Common` -> `Azazel-Fabric` (formerly)

Use legacy names only when migration context is required.

## Ratified Designations

### 2026-07-10

- CTI node: repository `01rabbit/Azazel-Knowledge`, formal name
  **`Azazel-Knowledge Advisor`**, series number `AZ-04`. Formerly `Azazel-CTI`.
- Contracts library: repository `01rabbit/Azazel-Fabric`, formal name
  **`Azazel-Fabric Contract`**, series number `AZ-05`. Formerly `Azazel-Common`.

### 2026-08-13

- Engagement-environment runtime: repository `01rabbit/Azazel-Deception`,
  formal name **`Azazel-Deception Host`**, series number **`AZ-06`**,
  codename **`THEATRE`**.
- `Deception` and `Host` are ratified into the Form and Role vocabularies.
- AZ-06 is a software/runtime class, not a Raspberry Pi-specific product.
  OCI containers are the initial standard execution unit; Raspberry Pi 5 is
  the minimum reference host for lightweight profiles, while ARM64/AMD64 and
  larger x86 hosts provide portable scaling targets.
- AZ-06 never becomes a second decision authority: Azazel-Edge remains the
  final activation, routing, transition, budget, downgrade, and termination
  authority.

### 2026-09-18

- Civil emergency removable-media environment: repository
  `01rabbit/Azazel-Boot`, formal name **`Azazel-Boot Responder`**, series
  number **`AZ-03`**. This activates the prior AZ-03 reservation for the
  bootable Azazel-Boot class; the prior reserved `Probe` role understated its
  bounded response and evidence-handling responsibilities.
- Persistent integrated node: repository `01rabbit/Azazel-Nexus`, formal name
  **`Azazel-Nexus Gateway`**, series number **`AZ-07`**.
- `Nexus` and `Responder` are ratified into the Form and Role vocabularies.
- Boot is for civil emergency use from removable USB SSD media on declared
  compatible laptops. Nexus is for sustained deployment on a rugged x86_64
  Linux PC. Both preserve Azazel-Edge as the sole deterministic enforcement
  authority.

## Codenames

Each product may carry a development codename: a single uppercase word,
shown in the repository README directly under the title as a `Codename:`
block quote, and used for changelogs, release names, and internal milestones.
Codenames never replace formal external naming.

Current assignments:

- `AZ-01` Azazel-Edge Gateway — codename `SENTINEL`.
- `AZ-02` Azazel-Gadget Shield — codename `TACMOD`.
- `AZ-03` Azazel-Boot Responder — no codename assigned.
- `AZ-04` Azazel-Knowledge Advisor — codename `GRIMOIRE`: the accumulated book of threats; it advises but never commands.
- `AZ-05` Azazel-Fabric Contract — codename `COVENANT`: the binding agreement the series' products sign.
- `AZ-06` Azazel-Deception Host — codename `THEATRE`: the controlled stage on which Edge-approved deception environments are materialized, observed, and reset.
- `AZ-07` Azazel-Nexus Gateway — no codename assigned.

## Naming Examples

- `Azazel-Edge Gateway`
- `Azazel-Gadget Shield`
- `Azazel-Boot Responder`
- `Azazel-Knowledge Advisor`
- `Azazel-Fabric Contract`
- `Azazel-Deception Host`
- `Azazel-Nexus Gateway`

## External Presentation Wording

Recommended wording for conference pages, repositories, and talks:

- "Azazel uses the `Azazel-<Form> <Role>` naming convention."
- "Use `Cyber Scapegoat Gateway` as the fixed external banner phrase."
- "Azazel-Edge and Azazel-Gadget are concrete defensive implementations of the doctrine."
- "Azazel-Deception Host is the container-first Engagement Environment Plane that materializes Edge-approved deception packages."
- "Azazel applies delaying action to cyberspace through detect, decide, delay, redirect, observe, and bounded deception loops."
- For MITRE Engage relationship claims, prefer `Engage-aligned` or `Engage-informed`; do not claim certification.

Avoid vague claims. Prefer clear operational verbs: detect, decide, delay, redirect, observe, materialize, reset, buy time.

## Restricted Terms

- Do not use `Jamming` in names or tags.
- Use `Delay` or `Throttle` where wording alternatives are needed.
