# Paths
DEPLOY_SCRIPT=./deploy.sh
INSTALL_STEP_1=./1_install_azazel.sh
INSTALL_STEP_2=./2_setup_containers.sh
INSTALL_STEP_3=./3_configure_services.sh

# Full installation process
install:
	sudo $(INSTALL_STEP_1)
	sudo $(INSTALL_STEP_2)
	sudo $(INSTALL_STEP_3)

# Deploy azazel_runtime to /opt/azazel
deploy:
	sudo $(DEPLOY_SCRIPT)

# View service logs
logs:
	tail -f /opt/azazel/logs/*.log

# Clean deployed runtime (use with caution!)
clean:
	sudo rm -rf /opt/azazel/*
	sudo rm -rf /opt/mattermost/*

# Start/stop services
start:
	sudo systemctl start mattermost suricata docker

stop:
	sudo systemctl stop mattermost suricata docker

status:
	sudo systemctl status mattermost suricata docker