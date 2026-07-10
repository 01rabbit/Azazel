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
- `Fabric`: cross-product interoperability and shared-contract class.
- `Knowledge`: resident threat-knowledge and intelligence-support class.

## Role Vocabulary

- `Gateway`: boundary gateway for multiple endpoints or small networks.
- `Shield`: forward defensive layer for a single user or endpoint.
- `Probe`: observation and measurement focused role with minimal control.
- `Advisor`: advisory knowledge provider without enforcement authority.
- `Contract`: shared schemas, interfaces, and interoperability definitions.

Do not introduce extra Form or Role words without updating this specification first.

Edge, Gadget, and Boot are the defensive deployment classes; Fabric and
Knowledge are the support classes that make the Azazel System work as a
series. With `Fabric Contract`, every product now follows the uniform
`Azazel-<Form> <Role>` grammar — there is no longer a library-repository
exception.

## AZ Numbering

`AZ-xx` is a series accession number, assigned in the order a repository
joined the Azazel series. It is not limited to appliance form factors; the
knowledge-plane node and the contracts library carry numbers too.

Current assignments:

- `AZ-01`: Azazel-Edge
- `AZ-02`: Azazel-Gadget
- `AZ-03`: Azazel-Boot (reserved)
- `AZ-04`: Azazel-Knowledge Advisor
- `AZ-05`: Azazel-Fabric Contract

## Legacy Name Mapping

- `Azazel-Pi` -> `Azazel-Edge` (formerly)
- `Azazel-Zero` -> `Azazel-Gadget` (formerly)
- `Azazel-USB` -> `Azazel-Boot` (same meaning)
- `Azazel-CTI` -> `Azazel-Knowledge` (formerly, working name)
- `Azazel-Common` -> `Azazel-Fabric` (formerly)

Use legacy names only when migration context is required.

## Ratified Designations (2026-07-10)

The owner ratified two series designations on 2026-07-10 (ADR-0001 for the CTI
node records the same decision):

- CTI node: repository `01rabbit/Azazel-Knowledge`, formal name
  **`Azazel-Knowledge Advisor`**, series number `AZ-04`. Formerly `Azazel-CTI`
  (working name).
- Contracts library: repository `01rabbit/Azazel-Fabric`, formal name
  **`Azazel-Fabric Contract`**, series number `AZ-05`. Formerly
  `Azazel-Common`.

The vocabulary these designations introduce (`Knowledge`, `Advisor`,
`Fabric`, `Contract`) now lives in the Form Vocabulary and Role Vocabulary
sections above. Interim candidates (Azazel-Grimoire Advisor,
Azazel-Covenant) were considered and superseded the same day, before
adoption; `Grimoire` and `Covenant` were retained as the two products'
development codenames (see Codenames).

## Codenames

A product may carry a development codename, used for changelogs, release
names, and internal milestones. Codenames never appear in formal external
naming — the `Azazel-<Form> <Role>` line above is canonical.

- `AZ-04` Azazel-Knowledge Advisor — codename **Grimoire**: the accumulated
  book of threats. A grimoire never casts its own spells — the node drafts
  detection rules but never deploys them; the reader (Azazel-Edge's
  deterministic arbiter) decides.
- `AZ-05` Azazel-Fabric Contract — codename **Covenant**: the binding
  agreement the series' products sign.

## Naming Examples

- `Azazel-Edge Gateway`
- `Azazel-Gadget Shield`
- `Azazel-Boot Probe`
- `Azazel-Knowledge Advisor`
- `Azazel-Fabric Contract`

## External Presentation Wording

Recommended wording for conference pages, repositories, and talks:

- "Azazel uses the `Azazel-<Form> <Role>` naming convention."
- "Use `Cyber Scapegoat Gateway` as the fixed external banner phrase."
- "Azazel-Edge and Azazel-Gadget are concrete implementations of the doctrine."
- "Azazel applies delaying action to cyberspace through detect, decide, delay, redirect, and observe loops."

Avoid vague claims. Prefer clear operational verbs: detect, decide, delay, redirect, observe, buy time.

## Restricted Terms

- Do not use `Jamming` in names or tags.
- Use `Delay` or `Throttle` where wording alternatives are needed.
