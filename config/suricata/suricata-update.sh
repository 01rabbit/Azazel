

#!/usr/bin/env bash
#
# suricata-update.sh
# Updates Suricata rules without the built‑in suricata-update test
# then performs an explicit manual test and service restart.
#
# Usage:
#   ./suricata-update.sh
# (Run with a user that can sudo without a password or be ready to enter one.)

set -euo pipefail


ENABLE_CONF="/etc/suricata/enable.conf"
DISABLE_CONF="/etc/suricata/disable.conf"
SURICATA_CONF="/etc/suricata/suricata.yaml"

# ------------------------------------------------------------------
# (Re)generate enable.conf and disable.conf so that every update
# run is self‑contained.  Feel free to customise these templates.
# ------------------------------------------------------------------

echo "==> Writing ${ENABLE_CONF}"
sudo tee "${ENABLE_CONF}" >/dev/null <<'EOL'
# ---------- core attack classes ----------
enable classification:attempted-admin
enable classification:attempted-user
enable classification:shellcode-detect
enable classification:trojan-activity
enable classification:protocol-command-decode
enable classification:web-application-attack
enable classification:bad-unknown

# ---------- protocol focus ----------
enable group:ja3-fingerprints
enable group:tls-events
enable group:ssh
enable group:postgres

# ---------- custom SIDs ----------
enable sid:2027750   # SSH brute‑force 5 in 60 s
enable sid:2030342   # PostgreSQL auth failed > n
EOL

echo "==> Writing ${DISABLE_CONF}"
sudo tee "${DISABLE_CONF}" >/dev/null <<'EOL'
# ---------- high-noise / not needed ----------
disable classification:policy-violation
disable classification:icmp-event
disable classification:non-standard-protocol

# ---------- protocol groups we don't monitor ----------
disable group:oracle
disable group:telnet
disable group:scada
disable group:voip
disable group:activex

# ---------- duplicate / noisy signatures ----------
disable sid:2100367  # TLS certificate expired
disable sid:2210051  # TCP timestamp option missing
EOL


echo "==> Fetching and installing rule updates (testing skipped)…"
sudo suricata-update --no-test \
  --enable-conf="${ENABLE_CONF}" \
  --disable-conf="${DISABLE_CONF}" \
  -f

echo "==> Performing manual Suricata configuration test…"
sudo suricata -T -c "${SURICATA_CONF}"

echo "==> Restarting Suricata service…"
sudo systemctl restart suricata

echo ">> Update complete."