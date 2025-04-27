# RaspAP 設定手順書 / RaspAP Setup Guide (RaspAP_config.md)

> **注意 / Note**  
> - 《SSID》《PSK》は任意値に置き換えてください / Replace "SSID" and "PSK" as needed.  
> - 国コードは日本(JP)想定 / Country code is set to Japan (JP) by default.  
> - **raspap-setup.shを完了した後にこの手順書のWebGUI設定に移行してください / Complete raspap-setup.sh first, then proceed with WebGUI configuration.**

---

## 1 準備 / Preparation

```bash
sudo -s
raspi-config nonint do_wifi_country JP
```

---

## 2 wlan1 ― 外部 Wi-Fi クライアント設定 / External Wi-Fi Client Setup

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
systemctl restart wpa_supplicant@wlan1.service 2>/dev/null || wpa_cli -i wlan1 reconfigure
```

---

## 3 wlan0 ― AP用固定IP設定 (**WebGUIで実施**) / AP Static IP Setting (**via WebGUI**)

**注意 / Note:** wlan0の固定IP設定はWebGUI上で行います / Static IP for wlan0 must be configured via WebGUI.

- アクセス URL / Access URL: `http://172.16.0.254`
- **Networking > Static IP Settings**
  - Interface: wlan0
  - Static IP: `172.16.0.254/24`
  - Gateway: `172.16.0.254`

---

## 4 DHCP サーバ設定 (**WebGUIで実施**) / DHCP Server Setting (**via WebGUI**)

- **DHCP Server**
  - DHCP Range Start: `172.16.0.100`
  - DHCP Range End: `172.16.0.200`
  - Gateway: `172.16.0.254`
  - DNS Server: `172.16.0.254`

---

## 5 hostapd ― AP無線設定 / AP Wireless Setup

**自動設定済 / Auto-configured by raspap-setup.sh**

必要なら WebGUI または CLI で修正可能 / Editable via WebGUI or CLI if needed.

```bash
cat > /etc/hostapd/hostapd.conf <<'EOF'
( ... omitted ... )
EOF
systemctl unmask hostapd
systemctl enable --now hostapd
```

---

## 6 IP転送 & NAT / IP Forwarding & NAT

**自動設定済 / Auto-configured by raspap-setup.sh**

手動修正の必要はありません / No manual adjustment needed.

---

## 7 サービス自動起動 / Service Auto-start

**自動設定済 / Auto-configured by raspap-setup.sh**

---

## 8 再起動と確認 / Reboot and Verify

```bash
reboot
```

再起動後 : / After reboot:

| 確認項目 / Check Item | 期待値 / Expected Result |
|----------|--------|
| `ip -4 a show wlan0` | `172.16.0.254/24` |
| `ip -4 a show wlan1` | DHCP取得IP / DHCP assigned IP |
| SSID接続 / Connect to SSID | 172.16.0.100-200 DHCP IP |
| 外部通信 / External communication | OK |

---

# 概要 / Overview

- 【自動 / Automatic】: `raspap-setup.sh`が負担 (hostapd / NAT / サービス起動)
- 【WebGUI / Manual via WebGUI】: wlan0 IP 固定 / DHCP範囲設定

> WebGUI設定の作作が必要なことを必ず意識してください / Be sure to recognize that WebGUI configuration is required.

