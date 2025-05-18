#!/usr/bin/env bash
#
# suricata_lua_setup.sh
# Copies Lua scripts (delay.lua, ja3.lua) from this repository directory
# to /etc/suricata/lua and sets correct ownership and permissions.
#
# Usage:
#   ./suricata_lua_setup.sh
#
# Prerequisites:
#   - Run with a user that has password‑less sudo or be prepared to enter the password.
#   - The files delay.lua and ja3.lua must reside in the same directory as this script.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="/etc/suricata/lua"

echo "Creating destination directory: $DEST_DIR"
sudo mkdir -p "$DEST_DIR"
sudo chown suricata:suricata "$DEST_DIR"
sudo chmod 750 "$DEST_DIR"

for lua_file in delay.lua ja3.lua; do
    SRC="$SCRIPT_DIR/$lua_file"
    if [[ ! -f "$SRC" ]]; then
        echo "Error: $lua_file not found in $SCRIPT_DIR" >&2
        exit 1
    fi
    echo "Installing $lua_file to $DEST_DIR"
    sudo install -m 640 -o suricata -g suricata "$SRC" "$DEST_DIR/$lua_file"
done

echo "Done. Lua scripts installed to $DEST_DIR."