#!/usr/bin/env bash
# Azazel system health-check script (complete final version with raspapd special handling)

# Define paths
COMPOSE_DIR="/opt/azazel/containers"
COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yml"

# Define container services and host services
containers=(opencanary postgres vector)
services=(suricata mattermost raspapd)

# ANSI colors
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
BOLD='\e[1m'
NC='\e[0m'

# Counters for summary
up_count=0
down_count=0

print_line() {
  local name="$1"; local state="$2"

  # Special handling for raspapd
  if [[ "$name" == "service:raspapd" && "$state" == "inactive" ]]; then
    state="completed"
  fi

  local colour
  case "$state" in
    Up|active|completed) colour=$GREEN; ((up_count++)) ;;
    Down|inactive)       colour=$RED; ((down_count++)) ;;
    *)                   colour=$YELLOW; ((down_count++)) ;;
  esac
  printf "%-20s %b%s%b\n" "$name" "$colour" "$state" "$NC"
}

print_header() {
  echo -e "\n${BOLD}=== Azazel System Status $(date '+%Y-%m-%d %H:%M:%S') ===${NC}"
}

print_summary() {
  echo -e "\n${BOLD}Summary:${NC} ${GREEN}${up_count} Up${NC}, ${RED}${down_count} Down${NC}"
}

print_header

# ----- Docker containers -----
cd "$COMPOSE_DIR" || { echo "Cannot access compose directory"; exit 1; }

for c in "${containers[@]}"; do
  if docker-compose ps "$c" 2>/dev/null | grep -q "Up"; then
    state="Up"
  else
    state="Down"
  fi
  print_line "docker:$c" "$state"
done

# ----- Host services -----
for s in "${services[@]}"; do
  state=$(systemctl is-active "$s" 2>/dev/null)
  if [[ "$state" == "" ]]; then
    state="unknown"
  fi
  print_line "service:$s" "$state"
done

print_summary
