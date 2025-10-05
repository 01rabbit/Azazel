# Architecture Overview

```text
[Ingress] → [Sensor: Suricata] → [Event Bus] → [Correlator/Scorer]
      ↘→ [Lures: OpenCanary]    → [Policy Engine] → [tc/nftables actions]
                                   ↘→ [Notifier] → [Mattermost / Local UI]
```

Core profiles: **medical / ops / public / suspect**. Modes: **Portal / Shield / Lockdown** with windowed thresholds and timed unlocks.
