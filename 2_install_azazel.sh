#!/bin/bash
##############################################################################
#  Azazel one-shot installer (JA/EN) - Final docker-compose version with embedded Mattermost service and Suricata rules filter
##############################################################################
set -e

# ---------- language settings ----------
LANG_OPT=${1:-ja}; [[ $LANG_OPT =~ en ]] && L=en || L=ja

declare -A M=([
  ja_REQUIRE_ROOT]="このスクリプトはrootで実行してください。例: sudo \$0"
  [en_REQUIRE_ROOT]="Run as root. Example: sudo \$0"
  [ja_START]="Azazel 統合インストール開始"
  [en_START]="Starting Azazel installation"
  [ja_DONE]="Azazel 環境の構築が完了しました！ログアウトしてログインし直してください。"
  [en_DONE]="Azazel setup finished! Please log out and log back in."
  [ja_DOCKER_GROUP]="ユーザー '$(logname)' をdockerグループに追加しました。ログアウトしてログインし直してください。"
  [en_DOCKER_GROUP]="Added user '$(logname)' to docker group. Please log out and log back in."
)

log()    { echo -e "\e[96m[INFO]\e[0m $1"; }
success(){ echo -e "\e[92m[SUCCESS]\e[0m $1"; }
error()  { echo -e "\e[91m[ERROR]\e[0m $1"; exit 1; }

# ---------- root check ----------
[[ $(id -u) -eq 0 ]] || { error "${M[${L}_REQUIRE_ROOT]}"; }

# ---------- variables ----------
AZ_DIR=/opt/azazel
CONF_DIR=$AZ_DIR/config
DATA_DIR=$AZ_DIR/data
LOG_DIR=$AZ_DIR/logs
LOG_FILE=$LOG_DIR/install.log
MM_VER=9.9.2
ARCH=$(dpkg --print-architecture)
SITEURL="http://$(hostname -I |awk '{print $1}'):8065"
DB_STR="postgres://mmuser:securepassword@localhost:5432/mattermost?sslmode=disable"

# Prepare directories
mkdir -p "$CONF_DIR" "$DATA_DIR" "$LOG_DIR"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# Ensure current user is in docker group
if ! groups $(logname) | grep -q docker; then
  usermod -aG docker $(logname)
  log "${M[${L}_DOCKER_GROUP]}"
  cat > /usr/local/bin/azazel-resume-install.sh <<EOF
#!/bin/bash
sudo $(realpath "$0")
EOF
  chmod +x /usr/local/bin/azazel-resume-install.sh
  log "[INFO] 再ログイン後、'azazel-resume-install.sh' を実行してください / After re-login, run 'azazel-resume-install.sh'"
  exit 0
fi

# ---------- installation steps ----------
STEPS=(
  "System update & package install"
  "Suricata minimal config"
  "Directory setup"
  "Copy config files"
  "Docker-compose up"
  "Mattermost install"
  "Suricata rules filtering (SSH/HTTP/PostgreSQL focus)"
)
TOTAL=${#STEPS[@]}
STEP=0

log "${M[${L}_START]} ($(date))"

# -- 1 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
apt-get -qq update && \
apt-get -yqq install --no-install-recommends \
  curl wget git jq moreutils iptables-persistent \
  docker.io docker-compose \
  suricata suricata-update python3 python3-pip
success "Packages installed"

# -- 2 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
suricata-update || true
cp /etc/suricata/suricata.yaml{,.bak}
install -Dm644 "$(dirname "$0")/config/suricata_minimal.yaml" /etc/suricata/suricata.yaml
success "Suricata minimal config applied"

# -- 3 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
install -d "$AZ_DIR/bin" "$AZ_DIR/containers"
success "Directory structure prepared"

# -- 4 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
cp "$(dirname "$0")/config/vector.toml" "$CONF_DIR/"
cp "$(dirname "$0")/config/opencanary.conf" "$CONF_DIR/"
cp "$(dirname "$0")/config/docker-compose.yml" "$AZ_DIR/containers/"
success "Config files copied"

# -- 5 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
cd "$AZ_DIR/containers"
log "Pulling Docker containers..."
docker-compose pull >> "$LOG_FILE" 2>&1
log "Starting Docker containers..."
docker-compose up -d
success "Docker containers started"

# -- 6 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
cd /opt
MM_TAR="mattermost-$MM_VER-linux-$ARCH.tar.gz"
wget -q "https://releases.mattermost.com/$MM_VER/$MM_TAR"
tar -xzf "$MM_TAR" && rm "$MM_TAR"
if ! id mattermost &>/dev/null; then
  useradd --system --user-group mattermost
fi
chown -R mattermost:mattermost /opt/mattermost
find /opt/mattermost -type d -exec chmod 750 {} \;
find /opt/mattermost -type f -exec chmod 640 {} \;
chmod 750 /opt/mattermost/config
chmod 640 /opt/mattermost/config/config.json
jq ".ServiceSettings.SiteURL=\"$SITEURL\" | .SqlSettings.DataSource=\"$DB_STR\"" \
  /opt/mattermost/config/config.json > /tmp/config.tmp
mv /tmp/config.tmp /opt/mattermost/config/config.json

cat > /etc/systemd/system/mattermost.service <<EOF
[Unit]
Description=Mattermost
After=network.target

[Service]
Type=simple
User=mattermost
Group=mattermost
WorkingDirectory=/opt/mattermost
ExecStart=/opt/mattermost/bin/mattermost
Restart=always
RestartSec=10
LimitNOFILE=49152

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl enable --now mattermost

if systemctl is-active --quiet mattermost; then
  success "Mattermost installed and running"
else
  error "Mattermost service failed to start"
fi

# -- 7 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"

SRC_RULES="/var/lib/suricata/rules/suricata.rules"
DST_RULES="/var/lib/suricata/rules/suricata.filtered.rules"
BACKUP_RULES="/var/lib/suricata/rules/suricata.rules.bak"

if [[ -f "$SRC_RULES" ]]; then
  cp "$SRC_RULES" "$BACKUP_RULES"
  log "[INFO] 元の suricata.rules をバックアップしました -> $BACKUP_RULES"

  grep -E "port\\s*22|port\\s*80|port\\s*443|port\\s*5432|ssh|http|https|pgsql|postgresql" "$SRC_RULES" > "$DST_RULES"

  RULE_COUNT=$(wc -l < "$DST_RULES")
  success "[SUCCESS] 抽出完了。フィルタ済みルール数: $RULE_COUNT"

  cp "$DST_RULES" "$SRC_RULES"
  success "[SUCCESS] suricata.rules をフィルタ済みバージョンに置き換えました"
else
  error "[ERROR] $SRC_RULES が存在しないためフィルタ処理をスキップします"
fi

log "${M[${L}_DONE]}"
