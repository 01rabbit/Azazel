---
title: Architecture Overview
nav_order: 5
nav_exclude: false
---

# Architecture Overview

```text
[Ingress] → [Sensor: Suricata] → [Event Bus] → [Correlator/Scorer]
      ↘→ [Lures: OpenCanary]    → [Policy Engine] → [tc/nftables actions]
                                   ↘→ [Notifier] → [Mattermost / Local UI]
```

Core profiles: **medical / ops / public / suspect**. Modes: **Portal / Shield / Lockdown** with windowed thresholds and timed unlocks.

An optional advisory CTI node ([Azazel-CTI](https://github.com/01rabbit/Azazel-CTI), working name) can enrich the correlator and policy engine with deterministic threat context, confidence, and recommendations. It only advises: final authority stays with the deterministic arbiter, and the pipeline remains fully functional if the node is absent, slow, or wrong.
