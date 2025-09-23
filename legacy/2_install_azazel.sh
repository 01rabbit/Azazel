#!/bin/bash
##############################################################################
#  Azazel one-shot installer (JA/EN) - Final docker-compose version with embedded Mattermost service and Suricata rules filter
##############################################################################

SCRIPT_BASE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# ---------- variables ----------
AZ_DIR=/opt/azazel
CONF_DIR=$AZ_DIR/config
DATA_DIR=$AZ_DIR/data
LOG_DIR=$AZ_DIR/logs
LOG_FILE=$LOG_DIR/install.log
MM_VER=9.10.2
ARCH=$(dpkg --print-architecture)
SITEURL="http://$(hostname -I |awk '{print $1}'):8080"
DB_STR="postgres://mmuser:securepassword@localhost:5432/mattermost?sslmode=disable"

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

# ------------------------------
# Suricata Luaスクリプト（delay.lua, ja3.lua）の配置・権限セットアップ関数
setup_suricata_lua_scripts() {
  LUA_SRC_DIR="$CONF_DIR/suricata/lua"
  DEST_DIR="/etc/suricata/lua"

  echo "[INFO] Installing Suricata Lua scripts: delay.lua, ja3.lua"
  mkdir -p "$DEST_DIR"
  chown suricata:suricata "$DEST_DIR"
  chmod 750 "$DEST_DIR"

  for lua_file in delay.lua ja3.lua; do
    SRC="$LUA_SRC_DIR/$lua_file"
    if [[ ! -f "$SRC" ]]; then
      echo "[ERROR] $lua_file not found in $LUA_SRC_DIR" >&2
      exit 1
    fi
    install -m 640 -o suricata -g suricata "$SRC" "$DEST_DIR/$lua_file"
  done

  echo "[SUCCESS] Lua scripts installed to $DEST_DIR."
}

# ------------------------------
# Suricataルールの有効・無効設定＆アップデート実行関数
update_suricata_rules() {
  echo "[INFO] Suricataルールのenable/disable.confとルール更新を実施"
  ENABLE_CONF="/etc/suricata/enable.conf"
  DISABLE_CONF="/etc/suricata/disable.conf"
  SURICATA_CONF="/etc/suricata/suricata.yaml"

  # enable.conf テンプレ生成
  cat > "$ENABLE_CONF" <<'EOL'
enable classification:attempted-admin
enable classification:attempted-user
enable classification:shellcode-detect
enable classification:trojan-activity
enable classification:protocol-command-decode
enable classification:web-application-attack
enable classification:bad-unknown

enable group:ja3-fingerprints
enable group:tls-events
enable group:ssh
enable group:postgres

enable sid:2027750   # SSH brute-force 5 in 60 s
enable sid:2030342   # PostgreSQL auth failed > n
EOL

  # disable.conf テンプレ生成
  cat > "$DISABLE_CONF" <<'EOL'
disable classification:policy-violation
disable classification:icmp-event
disable classification:non-standard-protocol

disable group:oracle
disable group:telnet
disable group:scada
disable group:voip
disable group:activex

disable sid:2100367  # TLS certificate expired
disable sid:2210051  # TCP timestamp option missing
EOL

  # suricata-updateで更新し、テスト＆再起動
  set +e
  suricata-update --no-test --enable-conf="$ENABLE_CONF" --disable-conf="$DISABLE_CONF" -f
  SURICATA_UPDATE_RC=$?
  suricata -T -c /etc/suricata/suricata.yaml
  SURICATA_T_RC=$?
  set -e
  if [[ $SURICATA_UPDATE_RC -ge 2 || $SURICATA_T_RC -ge 2 ]]; then
    echo "[ERROR] Suricataの設定テストに失敗しました（update: $SURICATA_UPDATE_RC, test: $SURICATA_T_RC）。ログを確認してください。"
    exit 1
  else
    echo "[SUCCESS] Suricataの設定テストは重大エラーなく完了しました。"
  fi

  systemctl restart suricata
  echo "[SUCCESS] Suricataルールの更新と再起動が完了"
}

set -e

# ---------- root check ----------
[[ $(id -u) -eq 0 ]] || { error "${M[${L}_REQUIRE_ROOT]}"; }

# ---------- language settings ----------
LANG_OPT=${1:-ja}; [[ $LANG_OPT =~ en ]] && L=en || L=ja

# Prepare directories
mkdir -p "$CONF_DIR" "$DATA_DIR" "$LOG_DIR"
: > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1


# ---------- installation steps ----------
STEPS=(
  "System update & package install"
  "Directory setup"
  "Copy config files"
  "Docker-compose up"
  "Mattermost install"
  "Suricata Lua script setup"
  "Suricata rules update"
  "Finish"
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

# Ensure current user is in docker group (after docker is installed)
if ! groups $(logname) | grep -q docker; then
  usermod -aG docker $(logname)
  log "${M[${L}_DOCKER_GROUP]}"
  cat > /usr/local/bin/azazel-resume-install.sh <<EOF
#!/bin/bash
sudo $(realpath "$0")
EOF
  chmod +x /usr/local/bin/azazel-resume-install.sh
  if [[ $L == "ja" ]]; then
    log "[INFO] この変更を反映するため、一度ログアウトし再ログインしてください。"
    log "[操作手順]"
    log "  1. 今のセッションを終了（exit等でログアウト）"
    log "  2. もう一度ターミナル等でログイン"
    log "  3. 以下のコマンドでインストールを再開"
    log "     \$ azazel-resume-install.sh"
  else
    log "[INFO] To apply this change, please log out and log in again."
    log "[Steps]"
    log "  1. Log out from the current session (exit)"
    log "  2. Log in again via terminal/SSH"
    log "  3. Resume the installer by running:"
    log "     \$ azazel-resume-install.sh"
  fi
  exit 0
fi


# Suricataユーザー・グループの有無をチェックし、なければ作成
if ! id suricata &>/dev/null; then
  useradd --system --user-group suricata
fi

# Suricataのログディレクトリ作成とパーミッション設定
mkdir -p /var/log/suricata
chown suricata:suricata /var/log/suricata
chmod 750 /var/log/suricata

# ----- Suricata初期設定: git管理のsuricata.yamlを/etcへコピー -----
SURICATA_SRC_YAML="$SCRIPT_BASE/config/suricata/suricata.yaml"
if [ -f "$SURICATA_SRC_YAML" ]; then
  cp "$SURICATA_SRC_YAML" /etc/suricata/suricata.yaml
  chown suricata:suricata /etc/suricata/suricata.yaml
  chmod 644 /etc/suricata/suricata.yaml
  log "[INFO] Suricata初期設定: config/suricata/suricata.yaml → /etc/suricata/suricata.yaml にコピー"
else
  log "[WARN] $SURICATA_SRC_YAML が見つかりません。Suricata設定コピーをスキップ"
fi

# -- 2 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
# (suricata.yaml copy logic moved to earlier step)

# -- 3 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
install -d "$AZ_DIR/bin" "$AZ_DIR/containers"
success "Directory structure prepared"

# -- 4 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
cp "$SCRIPT_BASE/config/vector.toml" "$CONF_DIR/"
cp "$SCRIPT_BASE/config/opencanary.conf" "$CONF_DIR/"
cp "$SCRIPT_BASE/config/docker-compose.yml" "$AZ_DIR/containers/"
success "Config files copied"
cp "$SCRIPT_BASE/config/nginx.conf" "$CONF_DIR/nginx.conf"
chown root:root "$CONF_DIR/nginx.conf"
chmod 644 "$CONF_DIR/nginx.conf"
success "nginx.conf copied and permission set"

# Suricata Lua スクリプトを /opt/azazel/config/suricata/lua にコピー
install -d "$CONF_DIR/suricata/lua"
for lua_file in delay.lua ja3.lua; do
  SRC_LUA="$SCRIPT_BASE/config/suricata/lua/$lua_file"
  if [[ ! -f "$SRC_LUA" ]]; then
    echo "[ERROR] $SRC_LUA not found. Check your project structure." >&2
    exit 1
  fi
  cp "$SRC_LUA" "$CONF_DIR/suricata/lua/"
done
success "Suricata Lua scripts copied to $CONF_DIR/suricata/lua/"

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
chmod +x /opt/mattermost/bin/mattermost
chmod 750 /opt/mattermost/config
chmod 640 /opt/mattermost/config/config.json

# 明示的に Mattermost 設定ディレクトリとファイルの権限・所有者を再設定（再発防止）
chown -R mattermost:mattermost /opt/mattermost/config
chmod 750 /opt/mattermost/config
chmod 660 /opt/mattermost/config/config.json
jq ".ServiceSettings.SiteURL=\"$SITEURL\" | .SqlSettings.DataSource=\"$DB_STR\" | .ServiceSettings.ListenAddress=\":8065\"" \
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
setup_suricata_lua_scripts

# -- 8 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"
update_suricata_rules

# -- 9 -----------------------------------------------------------------------
STEP=$((STEP+1))
log "[Step $STEP/$TOTAL] ${STEPS[STEP-1]}"


log "${M[${L}_DONE]}"

# --- Final completion message (JA/EN) ---
if [[ $L == "ja" ]]; then
  echo -e "\e[92m[COMPLETE]\e[0m すべてのインストール工程が正常に完了しました。\nシステムは完全にセットアップされています。ご利用を開始できます。"
else
  echo -e "\e[92m[COMPLETE]\e[0m All installation steps are complete. Your system is fully set up and ready to use."
fi
