#!/usr/bin/env bash
##############################################################################
#  Azazel one-shot installer  (JA/EN)         https://github.com/yourrepo
##############################################################################
set -euo pipefail

# ---------- language --------------------------------------------------------
LANG_OPT=${1:-ja}; [[ $LANG_OPT =~ en ]] && L=en || L=ja
declare -A M=(
  [ja_REQUIRE_ROOT]="このスクリプトは root で実行してください。例: sudo $0"
  [en_REQUIRE_ROOT]="Run as root.  e.g. sudo $0"
  [ja_START]="Azazel 統合インストール開始"
  [en_START]="Starting Azazel installation"
  [ja_DONE]="Azazel 環境の構築が完了しました！"
  [en_DONE]="Azazel setup finished!"
)

echo_step(){ printf "\e[1;33m[Step %d/%d] %s\e[0m\n" "$1" "$TOTAL" "$2"; }
ok(){ echo -e "\e[1;32m✔ $1\e[0m"; }
err(){ echo -e "\e[1;31m✖ $1\e[0m"; exit 1; }

# ---------- root check ------------------------------------------------------
[[ $(id -u) -eq 0 ]] || err "${M[$L_REQUIRE_ROOT]}"

# ---------- variables -------------------------------------------------------
AZ_DIR=/opt/azazel
CONF_DIR=$AZ_DIR/config
DATA_DIR=$AZ_DIR/data
LOG=$AZ_DIR/logs/install.log
MM_VER=9.2.2
ARCH=$(dpkg --print-architecture)     # arm64 / amd64 …
SITEURL="http://$(hostname -I |awk '{print $1}'):8065"
DB_STR="postgres://mmuser:securepassword@localhost:5432/mattermost?sslmode=disable"

# ---------- steps -----------------------------------------------------------
STEPS=(
  "system update & packages"
  "suricata minimal config"
  "directory tree"
  "copy configs"
  "docker compose up"
  "mattermost install"
)
TOTAL=${#STEPS[@]}
STEP=0
exec > >(tee -a "$LOG") 2>&1

echo -e "\e[96m${M[$L_START]} ($(date))\e[0m"

# -- 1 -----------------------------------------------------------------------
echo_step $((++STEP)) "${STEPS[STEP-1]}"
apt-get -qq update && \
apt-get -yqq install --no-install-recommends \
  curl wget git jq iptables-persistent \
  docker.io docker-compose-plugin \
  suricata suricata-update python3 python3-pip
ok "packages"

# -- 2 -----------------------------------------------------------------------
echo_step $((++STEP)) "${STEPS[STEP-1]}"
suricata-update || true
cp /etc/suricata/suricata.yaml{,.bak}
install -Dm644 "$(dirname "$0")/config/suricata_minimal.yaml" /etc/suricata/suricata.yaml
ok "suricata"

# -- 3 -----------------------------------------------------------------------
echo_step $((++STEP)) "${STEPS[STEP-1]}"
install -d "$AZ_DIR"/{bin,logs,containers,config,data}
ok "dirs"

# -- 4 -----------------------------------------------------------------------
echo_step $((++STEP)) "${STEPS[STEP-1]}"
cp "$(dirname "$0")"/config/{vector.toml,opencanary.conf} "$CONF_DIR/"
ok "configs copied"

# -- 5 -----------------------------------------------------------------------
echo_step $((++STEP)) "${STEPS[STEP-1]}"
cp "$(dirname "$0")/config/docker-compose.yml" "$AZ_DIR/containers/"
cd "$AZ_DIR/containers"
docker compose pull && docker compose up -d
ok "containers"

# -- 6 -----------------------------------------------------------------------
echo_step $((++STEP)) "${STEPS[STEP-1]}"
cd /opt
MM_TAR="mattermost-$MM_VER-linux-$ARCH.tar.gz"
wget -q "https://releases.mattermost.com/$MM_VER/$MM_TAR"
tar -xzf "$MM_TAR" && rm "$MM_TAR"
useradd -r -U mattermost 2>/dev/null || true
chown -R mattermost:mattermost /opt/mattermost
chmod 750 /opt/mattermost/config
jq ".ServiceSettings.SiteURL=\"$SITEURL\" | .SqlSettings.DataSource=\"$DB_STR\"" \
   /opt/mattermost/config/config.json | sponge /opt/mattermost/config/config.json
install -m644 "$(dirname "$0")/config/mattermost.service" /etc/systemd/system/
systemctl daemon-reload && systemctl enable --now mattermost
systemctl -q is-active mattermost && ok "Mattermost" || err "Mattermost failed"

echo -e "\e[92m${M[$L_DONE]}\e[0m"
