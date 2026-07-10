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
- `Grimoire`: knowledge-node class — the series' accumulated record of threats
  and reactions. A grimoire never casts its own spells: the reader (Azazel-Edge's
  deterministic arbiter) decides. Likewise this node's generated detection
  rules are drafts it never deploys.

## Role Vocabulary

- `Gateway`: boundary gateway for multiple endpoints or small networks.
- `Shield`: forward defensive layer for a single user or endpoint.
- `Probe`: observation and measurement focused role with minimal control.
- `Advisor`: advisory intelligence role — returns context, confidence, reasons,
  and recommendations; holds no command authority.

Do not introduce extra Form or Role words without updating this specification first.

## Library Repositories

Repositories that are libraries rather than deployable appliances take the
form `Azazel-<Name>` with **no Role suffix** — forcing a Form/Role pair onto a
library would dilute both vocabularies.

- `Covenant`: the shared contracts library for the series. A covenant is a
  binding agreement, which is precisely what a contracts library holds, and
  the register matches the Leviticus origin of the series name.

## AZ Numbering

`AZ-xx` is a series accession number, assigned in the order a repository
joined the Azazel series. It is not limited to appliance form factors; the
knowledge-plane node and the contracts library carry numbers too.

Current assignments:

- `AZ-01`: Azazel-Edge
- `AZ-02`: Azazel-Gadget
- `AZ-03`: Azazel-Boot (reserved)
- `AZ-04`: Azazel-Grimoire Advisor
- `AZ-05`: Azazel-Covenant

## Legacy Name Mapping

- `Azazel-Pi` -> `Azazel-Edge` (formerly)
- `Azazel-Zero` -> `Azazel-Gadget` (formerly)
- `Azazel-USB` -> `Azazel-Boot` (same meaning)
- `Azazel-CTI` -> `Azazel-Grimoire` (formerly, working name)
- `Azazel-Common` -> `Azazel-Covenant` (formerly)

Use legacy names only when migration context is required.

## Ratified Designations (2026-07-10)

The owner ratified two series designations on 2026-07-10 (ADR-0001 for the CTI
node records the same decision):

- CTI node: repository `01rabbit/Azazel-Grimoire`, formal name
  **`Azazel-Grimoire Advisor`**, series number `AZ-04`. Formerly `Azazel-CTI`
  (working name).
- Contracts library: repository `01rabbit/Azazel-Covenant`, formal name
  **`Azazel-Covenant`** (no Role suffix; see Library Repositories above),
  series number `AZ-05`. Formerly `Azazel-Common`.

The vocabulary these designations introduce (`Grimoire`, `Advisor`,
`Covenant`) now lives in the Form Vocabulary, Role Vocabulary, and Library
Repositories sections above.

## Naming Examples

- `Azazel-Edge Gateway`
- `Azazel-Gadget Shield`
- `Azazel-Boot Probe`
- `Azazel-Grimoire Advisor`

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
