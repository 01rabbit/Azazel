# azazel_runtime

This directory represents the runtime layout of the Azazel system after installation.

## Structure

- `bin/`: Shell scripts for automation (e.g., log backup)
- `config/`: Configuration files for services like Fluent Bit, Vector, OpenCanary
- `containers/`: Docker Compose definitions and container-related files
- `data/`: Persistent data such as PostgreSQL volumes
- `logs/`: Operational logs and service outputs

> All subdirectories include `.keep` files to ensure they remain under version control.

**Note:** This is a template for the structure under `/opt/azazel/` in real deployment.