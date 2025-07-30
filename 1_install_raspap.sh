#!/bin/bash

##############################################################################
# RaspAP 自動セットアップスクリプト (CLI only)
# RaspAP Automatic Setup Script (CLI only)
##############################################################################

# ---------- language settings ----------
LANG_OPT=${1:-ja}
[[ $LANG_OPT =~ en ]] && L=en || L=ja

declare -A M=(
  [ja_REQUIRE_ROOT]="このスクリプトは sudo で実行してください"
  [en_REQUIRE_ROOT]="Please run this script with sudo"
  [ja_START]="RaspAP セットアップ開始"
  [en_START]="Starting RaspAP Setup"
  [ja_DONE]="基本セットアップが完了しました（固定 IP・DHCP 範囲は未設定）"
  [en_DONE]="Basic setup complete (Static IP & DHCP range not configured)"
  [ja_REBOOT]="設定を有効にするには再起動: sudo reboot"
  [en_REBOOT]="Reboot to apply changes: sudo reboot"
)

log()    { echo -e "\e[96m[INFO]\e[0m $1"; }
success(){ echo -e "\e[92m[SUCCESS]\e[0m $1"; }
error()  { echo -e "\e[91m[ERROR]\e[0m $1"; exit 1; }

# ---------- root check ----------
[[ $(id -u) -eq 0 ]] || { error "${M[${L}_REQUIRE_ROOT]}"; }

# ---------- settings ----------
SSID="Azazel-GW"
PSK="password"
AP_IP="172.16.0.254/24"
DHCP_START="172.16.0.100"
DHCP_END="172.16.0.200"
COUNTRY="JP"
CHANNEL="6"
LOG_DIR="/opt/azazel/logs"
LOG_FILE="${LOG_DIR}/raspap_setup.log"
mkdir -p "$LOG_DIR"
: > "$LOG_FILE"

exec > >(tee -a "$LOG_FILE") 2>&1

# ---------- installation steps ----------
log "${M[${L}_START]} ($(date))"

apt update && apt -y upgrade
apt install -y lighttpd php-cgi php-cli git hostapd dnsmasq iptables iptables-persistent netfilter-persistent

lighty-enable-mod fastcgi-php || true
systemctl enable --now lighttpd

install -d /opt/azazel
if [ ! -d /opt/azazel/raspap-webgui ]; then
  git clone https://github.com/RaspAP/raspap-webgui.git /opt/azazel/raspap-webgui
fi
bash /opt/azazel/raspap-webgui/installers/raspbian.sh --yes

cat > /etc/raspap/networking/interfaces <<EOF
RASPI_WIFI_CLIENT_INTERFACE=wlan1
RASPI_WIFI_AP_INTERFACE=wlan0
EOF

cat > /etc/hostapd/hostapd.conf <<EOF
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
interface=wlan0

ssid=${SSID}
country_code=${COUNTRY}
hw_mode=g
channel=${CHANNEL}
ieee80211n=1
wmm_enabled=1

wpa=2
wpa_passphrase=${PSK}
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
EOF

systemctl unmask hostapd
systemctl enable --now hostapd

cat > /etc/sysctl.d/90-azazel-ipforward.conf <<EOF
net.ipv4.ip_forward=1
EOF

sysctl -p /etc/sysctl.d/90-azazel-ipforward.conf
iptables -t nat -C POSTROUTING -s 172.16.0.0/24 -o wlan1 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o wlan1 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4
systemctl enable netfilter-persistent

systemctl enable hostapd dnsmasq dhcpcd

log "✔ ${M[${L}_DONE]}"
log "内部AP       : SSID=${SSID} / PASS=${PSK}"
log "内部ネット   : 172.16.0.0/24 (GW ${AP_IP%/*})"
log "RaspAP UI    : http://${AP_IP%/*}"
log "${M[${L}_REBOOT]}"

success "スクリプト完了 / Script Completed"

