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

## Role Vocabulary

- `Gateway`: boundary gateway for multiple endpoints or small networks.
- `Shield`: forward defensive layer for a single user or endpoint.
- `Probe`: observation and measurement focused role with minimal control.

Do not introduce extra Form or Role words without updating this specification first.

## Legacy Name Mapping

- `Azazel-Pi` -> `Azazel-Edge` (formerly)
- `Azazel-Zero` -> `Azazel-Gadget` (formerly)
- `Azazel-USB` -> `Azazel-Boot` (same meaning)

Use legacy names only when migration context is required.

## Pending Designations

Two series repositories exist without a formal `Azazel-<Form> <Role>` designation:

- `Azazel-CTI`: presented under a working name. Its ADR-0001 defers the formal series name.
- `Azazel-Common`: the shared contracts library for the series.

The current Form vocabulary (`Gadget`, `Edge`, `Boot`) covers appliance form factors and does not yet cover a knowledge-plane node such as the CTI node, nor a contracts library. Formal designations for both are pending a spec extension. No new Form or Role words are introduced here; per the rule above, that requires updating this specification first.

## Proposed Vocabulary Extension (draft — pending owner ratification)

This section is a **proposal only**. Nothing below is a valid name until the
owner ratifies it (for the CTI node, that decision is additionally recorded in
its ADR-0001). Until then, external-facing text keeps the working names.

### Proposed new vocabulary

- Form `Keep` (proposed): resident companion knowledge-node class — an SBC that
  stands *behind* the gateway and holds the series' records and threat
  knowledge. The castle register matches the existing vocabulary: the `Gateway`
  is the gatehouse; the keep is the stronghold where knowledge is kept.
- Role `Oracle` (proposed): advisory intelligence role — answers questions with
  context, confidence, reasons, and recommendations, and holds no command
  authority. An oracle is consulted; it never commands.

### Proposed designations

- CTI node: repository `Azazel-Keep`, formal name **`Azazel-Keep Oracle`**.
  Alternatives considered: `Azazel-Watch Oracle` (watchtower register; rejected
  because the node analyzes stored knowledge rather than observing live
  traffic), Role `Advisor` (plainer; kept as fallback if `Oracle` reads as too
  authoritative).
- Contracts library: repositories that are libraries rather than deployable
  appliances take the form `Azazel-<Name>` with **no Role suffix** (forcing a
  Form/Role pair onto a library would dilute both vocabularies). Recommended
  name: **`Azazel-Covenant`** — a covenant is a binding agreement, which is
  precisely what a contracts library holds, and the register matches the
  Leviticus origin of the series name. Alternatives: `Azazel-Canon` (the
  shared canon of schemas), or retaining `Azazel-Common` (explicitly
  legitimate: it is honest, already deliberate — "Common", not "Core" — and a
  rename has real cost since consumers pin the repository URL by git tag).

### Migration cost note

Renaming is not free: the CTI node's Python namespace (`azazel_cti`), CLI
(`azctl`), systemd/container names, and the umbrella site would all move; the
contracts library is pinned by URL from Azazel-Gadget's `requirements.txt`.
Ratification should therefore be bundled with a migration checklist, and the
legacy mapping section above extended (`Azazel-CTI -> Azazel-Keep (formerly)`,
`Azazel-Common -> Azazel-Covenant (formerly)`) at switch time.

## Naming Examples

- `Azazel-Edge Gateway`
- `Azazel-Gadget Shield`
- `Azazel-Boot Probe`

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
