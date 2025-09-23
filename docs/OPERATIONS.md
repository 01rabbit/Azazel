# Operations guide

This document captures the procedures for staging, operating, and maintaining
Azazel in the field. The workflow assumes deployment on Raspberry Pi OS but can
be adapted to other Debian derivatives.

## 1. Acquire a release

Pick a signed Git tag (for example `v1.0.0`) and download the installer bundle:

```bash
TAG=v1.0.0
curl -fsSL https://github.com/01rabbit/Azazel/releases/download/${TAG}/azazel-installer-${TAG}.tar.gz \
  | tar xz -C /tmp
```

The archive includes configuration templates, scripts, and systemd units.

## 2. Bootstrap the node

Run the installer on the target host:

```bash
cd /tmp/azazel-installer
sudo bash scripts/bootstrap_mvp.sh
```

The script copies the repository payload to `/opt/azazel`, pushes configuration
into `/etc/azazel`, installs systemd units, and enables the aggregate
`azctl.target`.

## 3. Configure services

1. Adjust `/etc/azazel/azazel.yaml` to reflect interface names, QoS policies, and
   alert thresholds.
2. Regenerate the Suricata configuration if a non-default ruleset is required:

   ```bash
   sudo scripts/suricata_generate.py \
     /etc/azazel/azazel.yaml \
     /etc/azazel/suricata/suricata.yaml.tmpl \
     --output /etc/suricata/suricata.yaml
   ```
3. Reload services: `sudo systemctl restart azctl.target`.

### Mode presets

The controller maintains three defensive modes. Each mode applies a preset of
delay, traffic shaping, and block behaviour sourced from `azazel.yaml`. Refer to
the [API reference – `/v1/mode`](API_REFERENCE.md#post-v1mode) section for the
remote override that activates these presets during incident response.

| Mode     | Delay (ms) | Shape (kbps) | Block | Use case |
|----------|-----------:|-------------:|:-----:|----------|
| portal   | 100        | –            |  No   | Baseline latency padding to slow automated scanning while keeping users online. |
| shield   | 200        | 128          |  No   | Elevated response once intrusion scoring passes T1; throttles attackers but preserves remote work. |
| lockdown | 300        | 64           | Yes   | Emergency containment when T2 is exceeded; combines shaping with hard blocks until the unlock timer expires. |

Transitions to stricter modes occur when the moving average of recent scores
exceeds the configured thresholds. Unlock timers enforce a cooling-off period
before the daemon steps down to a less restrictive mode. When lockdown is
entered in the field the supervising `azctl/daemon` should apply
`nft -f configs/nftables/lockdown.nft` after updating the generated allowlist.

## 4. Health checks

Use `scripts/sanity_check.sh` to confirm Suricata, Vector, and OpenCanary are
enabled and running. Systemd journal entries from the `azctl` service expose
state transitions and scoring decisions.

## 5. Rollback

To remove Azazel from a host, execute `sudo /opt/azazel/rollback.sh`. The script
deletes `/opt/azazel`, removes `/etc/azazel`, and disables the `azctl.target`.

## 6. Legacy installers

Historical provisioning scripts are stored under `legacy/` and are not supported
for new deployments.
