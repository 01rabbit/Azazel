# Product Map

Back to: [Products Index](README.md) | Related: [Naming Convention](../specs/naming.md)

## Doctrine to Implementation

- **Doctrine layer:** Azazel naming and doctrine hub ([README](../../README.md))
- **Implementation layer:** [Azazel-Edge](https://github.com/01rabbit/Azazel-Edge), [Azazel-Gadget](https://github.com/01rabbit/Azazel-Gadget)
- **Knowledge / advisory plane:** [Azazel-CTI](https://github.com/01rabbit/Azazel-CTI) (working name) — an optional, advisory-only CTI node that enriches edge decisions without holding authority
- **Contracts layer:** [Azazel-Common](https://github.com/01rabbit/Azazel-Common) — the shared contracts library the series speaks, not a decision core

## Positioning

Azazel is the doctrine.

Azazel-Edge and Azazel-Gadget are concrete implementation variants optimized for different operational contexts.

Azazel-CTI (working name) and Azazel-Common are complements to the appliances, not alternatives to them: the CTI node advises the deterministic edge, and Azazel-Common supplies the shared contracts that let the series interoperate.

Formal naming for externally presented products follows `Azazel-<Form> <Role> - Cyber Scapegoat Gateway`.

## Selection Guide

- Choose **Azazel-Edge** for edge SOC/NOC and field gateway operations.
- Choose **Azazel-Gadget** for personal tactical defense on untrusted Wi-Fi.
- Add **Azazel-CTI** (working name) when you want an optional, advisory-only knowledge plane that enriches edge decisions with deterministic threat context. It never commands, and the edge stays fully functional if it is absent, slow, or wrong.
- Reach for **Azazel-Common** when you are building on the series and need the shared contracts layer; it is the common language, not a decision core.
- Read this repository when you need naming, philosophy, architecture framing, and cross-product doctrine.
