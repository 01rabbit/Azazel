#!/usr/bin/env bash
set -euo pipefail

PC_IP="192.168.40.82"
COMPOSE=(docker compose -f /opt/azazel/docker-compose.yml)

if ping -c1 -W1 "$PC_IP" >/dev/null 2>&1; then
  "${COMPOSE[@]}" up -d vector
else
  "${COMPOSE[@]}" stop vector
fi
