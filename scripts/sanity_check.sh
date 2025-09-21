#!/usr/bin/env bash
set -euo pipefail

REQUIRED=(suricata vector opencanary)

for svc in "${REQUIRED[@]}"; do
  if ! systemctl is-enabled --quiet "$svc"; then
    echo "[azazel] warning: service $svc is not enabled" >&2
  fi
  if ! systemctl is-active --quiet "$svc"; then
    echo "[azazel] warning: service $svc is not running" >&2
  fi
done
