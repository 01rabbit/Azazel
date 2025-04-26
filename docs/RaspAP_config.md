> **注意**  
> - 《SSID》《PSK》は任意値に置き換えてください。  
> - 国コードは日本(JP)想定。必要なら変更。  
> - 既に設定済み項目は読み替えてください。

---

## 1 準備

```bash
sudo -s                     # 以降 root で作業
raspi-config nonint do_wifi_country JP
```

---

## 2 wlan1 ― 外部 Wi-Fi クライアント設定

```bash
cat > /etc/wpa_supplicant/wpa_supplicant.conf <<'EOF'
country=JP
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="《SSID》"
    psk="《PSK》"
    key_mgmt=WPA-PSK
}
EOF
chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
systemctl restart wpa_supplicant@wlan1.service 2>/dev/null || \
wpa_cli -i wlan1 reconfigure
```

---

## 3 wlan0 ― AP 用固定 IP

```bash
sed -i '/^interface wlan0/,+4d' /etc/dhcpcd.conf   # 旧定義を削除
cat >> /etc/dhcpcd.conf <<'EOF'

# --- Azazel wlan0 static ---
interface wlan0
  static ip_address=172.16.0.254/24
  nohook wpa_supplicant
# ---------------------------
EOF
systemctl restart dhcpcd
```

> *Web UI 表示を再現したい場合* は `static routers=172.16.0.254` と  
> `nogateway` を上記ブロックに追加しても構いません（機能差なし）。

---

## 4 hostapd ― AP の無線設定

```bash
cat > /etc/hostapd/hostapd.conf <<'EOF'
driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
interface=wlan0

ssid=Azazel-GW           # 《SSID》
country_code=JP
hw_mode=g
channel=6                # 1 / 6 / 11 など
ieee80211n=1
wmm_enabled=1

wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_passphrase=《PSK》

beacon_int=100
ignore_broadcast_ssid=0
EOF

systemctl unmask hostapd
systemctl enable --now hostapd
```

---

## 5 dnsmasq ― DHCP / DNS

```bash
cat > /etc/dnsmasq.d/090_wlan0.conf <<'EOF'
# RaspAP wlan0 configuration
interface=wlan0
domain-needed
bogus-priv
dhcp-range=172.16.0.100,172.16.0.200,255.255.255.0,12h
dhcp-option=3,172.16.0.254      # ゲートウェイ
dhcp-option=6,172.16.0.254      # DNS
EOF
systemctl restart dnsmasq
```

---

## 6 IP 転送 & NAT

```bash
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/90-azazel-ipforward.conf
sysctl -p /etc/sysctl.d/90-azazel-ipforward.conf

iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o wlan1 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4
systemctl enable netfilter-persistent 2>/dev/null
```

---

## 7 サービス自動起動

```bash
systemctl enable hostapd dnsmasq dhcpcd
# UI を使わないなら ↓ を無効化
# systemctl disable raspapd
```

---

## 8 再起動 & 動作確認

```bash
reboot
```

再起動後 :

| 確認項目 | 期待値 |
|----------|--------|
| `ip -4 a show wlan0` | `172.16.0.254/24` |
| `ip -4 a show wlan1` | 外部 DHCP で取得した IP |
| 別端末で SSID《Azazel-GW》接続 | IP: 172.16.0.100-200 / GW&DNS 172.16.0.254 |
| インターネット疎通 | 成功 |

