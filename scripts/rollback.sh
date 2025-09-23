#!/usr/bin/env bash
set -euo pipefail

TARGET_ROOT="/opt/azazel"
CONFIG_ROOT="/etc/azazel"

rm -rf "$TARGET_ROOT"
rm -rf "$CONFIG_ROOT"

systemctl disable --now azctl.target || true
