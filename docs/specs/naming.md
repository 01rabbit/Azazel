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
