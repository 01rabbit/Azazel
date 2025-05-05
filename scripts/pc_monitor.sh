#!/usr/bin/env bash
PC_IP="192.168.40.82"
COMPOSE="docker compose -f /opt/azazel/docker-compose.yml"

if ping -c1 -W1 $MAC_IP >/dev/null 2>&1; then
  $COMPOSE up -d vector        # Vectorを確実に起動
