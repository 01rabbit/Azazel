#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "[azazel] bootstrap requires root" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_ROOT="/opt/azazel"
CONFIG_ROOT="/etc/azazel"

mkdir -p "$TARGET_ROOT" "$CONFIG_ROOT"
rsync -a --delete "$REPO_ROOT/azazel_core" "$REPO_ROOT/azctl" "$TARGET_ROOT/"
rsync -a "$REPO_ROOT/configs/" "$CONFIG_ROOT/"
rsync -a "$REPO_ROOT/systemd/" /etc/systemd/system/

install -m 755 "$REPO_ROOT/scripts/nft_apply.sh" "$TARGET_ROOT/nft_apply.sh"
install -m 755 "$REPO_ROOT/scripts/tc_reset.sh" "$TARGET_ROOT/tc_reset.sh"
install -m 755 "$REPO_ROOT/scripts/sanity_check.sh" "$TARGET_ROOT/sanity_check.sh"
install -m 755 "$REPO_ROOT/scripts/rollback.sh" "$TARGET_ROOT/rollback.sh"

systemctl daemon-reload
systemctl enable azctl.target

cat <<MSG
[azazel] bootstrap complete.
Review /etc/azazel/azazel.yaml before starting services.
MSG
