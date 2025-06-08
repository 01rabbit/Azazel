# RaspAP 最小構成インストール・確認手順書 / RaspAP Minimal Install & Verification Guide

このドキュメントはRaspberry Piに最小構成でRaspAPを手動インストールし、WebGUI操作やCLIで動作確認を行う手順を日英対応でまとめたものです。

This document explains step-by-step how to manually install RaspAP with a minimal setup on Raspberry Pi and verify the configuration using both WebGUI and CLI tools, written in both Japanese and English.

---

## ✅ インストール手順 / Installation Steps

### 1. 必要パッケージのインストール  
Install required packages

```bash
sudo apt update && sudo apt install -y \
  lighttpd php8.2-cgi php8.2-cli \
  git hostapd dnsmasq iptables iptables-persistent
```

---

### 2. PHP FastCGIモジュールの有効化とWebサーバ起動  
Enable PHP FastCGI module and start web server

```bash
sudo lighty-enable-mod fastcgi-php
sudo systemctl enable lighttpd
sudo systemctl start lighttpd
```

---

### 3. RaspAPソースのクローンとインストール  
Clone and install RaspAP source

```bash
cd /opt/azazel
sudo git clone https://github.com/RaspAP/raspap-webgui.git
cd raspap-webgui
sudo bash installers/raspbian.sh --yes
```

---

### 4. RaspAP関連サービスの起動  
Start RaspAP related services

```bash
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl restart lighttpd
```

---

## ✅ WebGUIでの設定 / Configuration via Web GUI

- **アクセス URL / Access URL**: `http://10.3.141.1`
- **初期ログイン / Default Login**: `admin / secret`

WebGUIで次を設定します / Configure the following via WebGUI:

1. Networking → Static IP
2. Hotspot → SSID / Password settings
3. DHCP Server → DHCP range configuration

---

## ✅ 動作確認 / Operational Verification

### Pi上で確認 / On Raspberry Pi

```bash
ip a show wlan0          # IPアドレス確認 / Check IP address
ip route                 # ルーティング確認 / Check routing
sudo systemctl status dnsmasq   # DHCP状態確認 / Check DHCP status
```

### 外部端末から確認 / From external client

1. SSIDに接続 / Connect to SSID (e.g., Azazel-GW)
2. DHCPでIP取得 / Ensure DHCP IP assigned (e.g., 172.16.0.101)
3. `http://172.16.0.254`にアクセス / Access RaspAP via browser

---

## 🛠 トラブルシューティング / Troubleshooting

```bash
sudo journalctl -u dnsmasq -n 50     # DHCPログ / DHCP logs
sudo journalctl -u hostapd -n 50     # APログ / AP logs
```

---

## 🧐 備考 / Notes

- 設定を変更すると無線接続が一時切断される場合があります
- It's recommended to keep wired LAN (eth0) connected for fallback access during configuration changes.

