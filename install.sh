#!/bin/bash

# === Azazel Installation Script (with tee) ===
# This script runs all 3 setup phases and logs output to both screen and file

set -euo pipefail
trap 'echo "[ERROR] An error occurred at line $LINENO"; exit 1' ERR

LOG_FILE="install.log"
: > "$LOG_FILE"

log() {
    echo "[INFO] $1" | tee -a "$LOG_FILE"
}

run_step() {
    local step=$1
    local script=$2
    log "Running $step..."
    if [[ -x "$script" ]]; then
        sudo "$script" 2>&1 | tee -a "$LOG_FILE"
        log "$step completed."
    else
        echo "[ERROR] $script is not executable or not found." | tee -a "$LOG_FILE"
        exit 1
    fi
}

log "Starting Azazel installation"

run_step "STEP 1 - Base Setup" "./1_install_azazel.sh"
run_step "STEP 2 - Container Setup" "./2_setup_containers.sh"
run_step "STEP 3 - Service Configuration" "./3_configure_services.sh"

log "Azazel installation completed successfully"
