#!/bin/bash

# ===== 管理者権限の確認 =====
if [ "$(id -u)" -ne 0 ]; then
  echo "このスクリプトは管理者権限で実行してください。"
  echo "例: sudo ./raspap-setup.sh"
  exit 1
fi

set -e

echo "[1/9] システム更新と依存パッケージのインストール..."
apt update && apt upgrade -y
apt install -y lighttpd php8.2-cgi php8.2-cli git hostapd dnsmasq iptables iptables-persistent

echo "[2/9] lighttpd に PHP FastCGI を有効化＋起動..."
{
  lighty-enable-mod fastcgi-php || true
  systemctl enable lighttpd || true
  systemctl start lighttpd || true
  systemctl reload lighttpd || true
} || true
echo "  → lighttpd が正常に起動していない場合は: sudo systemctl status lighttpd.service を確認してください"

echo "[3/9] /opt/azazel に RaspAP をインストール..."
mkdir -p /opt/azazel
cd /opt/azazel
git clone https://github.com/RaspAP/raspap-webgui.git
cd raspap-webgui
sudo bash installers/raspbian.sh --yes
cd ~

echo "[4/9] RaspAP にインターフェース設定を明示..."
tee /etc/raspap/networking/interfaces > /dev/null <<EOF
RASPI_WIFI_CLIENT_INTERFACE=wlan0
RASPI_WIFI_AP_INTERFACE=wlan1
EOF

echo "[5/9] wlan1のIPを172.16.0.254に固定..."
tee -a /etc/dhcpcd.conf > /dev/null <<EOF

interface wlan1
    static ip_address=172.16.0.254/24
    nohook wpa_supplicant
EOF

echo "[6/9] DHCP範囲を172.16.0.100-200に変更..."
tee /etc/dnsmasq.d/090_raspap.conf > /dev/null <<EOF
interface=wlan1
dhcp-range=172.16.0.100,172.16.0.200,255.255.255.0,12h
dhcp-option=3,172.16.0.254
EOF

echo "[7/9] SSIDとパスワードを Azazel-GW に固定..."
tee /etc/hostapd/hostapd.conf > /dev/null <<EOF
interface=wlan1
driver=nl80211
ssid=Azazel-GW
hw_mode=g
channel=6
ieee80211n=1
wmm_enabled=1
ht_capab=[HT40][SHORT-GI-20][SHORT-GI-40]
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=password
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF

echo "[8/9] IP転送とNATルーティングの設定..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -A FORWARD -i wlan1 -o wlan0 -j ACCEPT
iptables -A FORWARD -i wlan0 -o wlan1 -m state --state ESTABLISHED,RELATED -j ACCEPT

# 開発中のためアクセス制限ルールはコメントアウト
# iptables -A INPUT -i wlan0 -p tcp --dport 8065 -j DROP
# iptables -A INPUT -i wlan0 -p tcp --dport 22 -j DROP

echo "[9/9] iptablesルールの永続化..."
iptables-save > /etc/iptables/rules.v4

echo ""
echo "✅ RaspAPセットアップ完了！"
echo "インストール先: /opt/azazel/raspap-webgui"
echo "SSID: Azazel-GW / パスワード: password"
echo "接続後、http://172.16.0.254 にアクセスして Wi-Fi を選択してください。"
echo "デフォルトログイン：ユーザー admin / パスワード secret"
echo ""
echo "⚠️ 注意：lighttpd が起動していない場合は以下で確認してください："
echo "  → sudo systemctl status lighttpd.service"
echo "  → sudo journalctl -xeu lighttpd.service"
