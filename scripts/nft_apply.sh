#!/usr/bin/env bash
set -euo pipefail

RULESET=${1:-/etc/azazel/nftables/azazel.nft}

if [[ ! -f "$RULESET" ]]; then
  echo "ruleset not found: $RULESET" >&2
  exit 1
fi

nft -f "$RULESET"
