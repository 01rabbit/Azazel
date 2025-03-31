# Azazel System Architecture

## Overview
The **Azazel System** is a lightweight, deception-based cyber defense gateway designed for Raspberry Pi 5. It integrates intrusion detection, honeypot services, and automated logging with a low-power, modular setup.

## Directory Structure (Runtime)

```plaintext
/opt/azazel/
├── bin/                         # Automation scripts (e.g., log backup)
│   └── backup_logs.sh
├── config/                      # Service configuration files
│   ├── fluentbit.conf
│   ├── vector.toml
│   └── opencanary.conf
├── containers/                 # docker-compose and related container files
│   └── docker-compose.yml
├── data/                        # Persistent data (e.g., PostgreSQL volumes)
│   └── postgres/
├── logs/                        # Logs from services (excluded from Git)
│   └── install_errors.log
```

## Deployment Strategy

- Development and Git tracking are done under `~/deb/azazel/`
- Runtime files and structure are mimicked in `azazel/azazel_runtime/`
- Final deployment to `/opt/azazel/` is done using `deploy.sh`

## Git Ignore Rules

```gitignore
azazel_runtime/logs/
azazel_runtime/data/
*.log
```

## Services Overview

- **Suricata** – Intrusion detection
- **OpenCanary** – Honeypot for attacker deception
- **Fluent Bit** – Lightweight log forwarder
- **Vector** – Log processor and output to file
- **Mattermost** – Alerting platform
- **iptables**, **tc** – Network control and delay

## Installation Flow

1. `1_install_azazel.sh` – System preparation and core package installation
2. `2_setup_containers.sh` – Docker container setup
3. `3_configure_services.sh` – Configuration files and startup routines
4. `deploy.sh` – Runtime files deployed to `/opt/azazel/`

---

© 2025 Azazel Development Team