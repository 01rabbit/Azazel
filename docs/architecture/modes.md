# Operational modes — legacy names, not a state vocabulary

**This page is kept for continuity. The names below are not the Azazel System's
state vocabulary and must not be used as one.**

What a product is currently doing is its **Defensive State**:
`OBSERVE | NOTIFY | THROTTLE | REDIRECT | ISOLATE`. See
[Defensive State doctrine](defensive-state.md), which also explains the five
other terms that are *not* Defensive State — Threat Level, Policy Profile, AI
Runtime Tier, Engagement State, and Presentation State.

## The legacy names

- **Portal**: permissive, telemetry-first, light shaping
- **Shield**: balanced filtering, selective delays, targeted blocks
- **Lockdown**: deny-by-default, allowlist resolver (FQDN/IP), high-latency shaping

These predate the canonical vocabulary. They remain permitted as **concept
branding** and for backward compatibility — the Cyber Scapegoat Gateway is the
project's founding idea and its essays are not state documents.

**No mapping from these names to the canonical five is defined anywhere**, and
that is deliberate. Deciding what `Portal` means in canonical terms would make
a product-local word canonical by the back door. A legacy name may be carried
alongside a canonical state as opaque context; it is never translated into one.
