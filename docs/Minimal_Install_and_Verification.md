# RaspAP 最小構成インストール・確認手順 / RaspAP Minimal Setup Guide

このドキュメントでは、RaspAPをRaspberry Piに最小構成でインストールし、GUI操作および動作確認までの手順を日本語と英語でまとめています。

This document outlines how to manually install RaspAP with a minimal setup on Raspberry Pi and verify the configuration through GUI and CLI tools.

---

## ✅ インストール手順 / Installation Steps

### 1. 必要なパッケージのインストール  
Install required packages

```bash
sudo apt update && sudo apt install -y \
  lighttpd php8.2-cgi php8.2-cli \
  git hostapd dnsmasq iptables iptables-persistent
```

---

### 2. PHP FastCGI モジュールの有効化とWebサーバ起動  
Enable PHP FastCGI and start the web server

```bash
sudo lighty-enable-mod fastcgi-php
sudo systemctl enable lighttpd
sudo systemctl start lighttpd
```

---

### 3. RaspAP ソースの取得とインストール  
Clone and install RaspAP source code

```bash
cd /opt/azazel
sudo git clone https://github.com/RaspAP/raspap-webgui.git
cd raspap-webgui
sudo bash installers/raspbian.sh --yes
```

---

### 4. RaspAP 関連サービスの起動  
Start RaspAP related services

```bash
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl restart lighttpd
```

---

## ✅ Web GUI による構成 / Configuration via Web GUI

- **アクセスURL / Access URL**： `http://10.3.141.1`
- **初期ログイン / Default Login**： `admin / secret`

GUIメニューから以下を設定します：

1. Networking → Static IP  
2. Hotspot → SSID / パスワード設定  
3. DHCP Server → IP配布レンジ

---

## ✅ 動作確認 / Operational Verification

### Pi上での確認コマンド / On Raspberry Pi

```bash
ip a show wlan0          # IPアドレス確認 / Check IP address
ip route                 # ルーティング確認 / Check routing
sudo systemctl status dnsmasq   # DHCP状態確認 / DHCP status
```

### 外部端末からの確認 / From external client

1. SSIDに接続 / Connect to SSID (e.g., Azazel-GW)
2. 自動IP取得 / Ensure DHCP IP assigned (e.g., 172.16.0.101)
3. `http://172.16.0.254` にアクセスしWeb UIが開くか確認 / Access RaspAP via browser

---

## 🛠 トラブルシューティング / Troubleshooting

```bash
sudo journalctl -u dnsmasq -n 50     # DHCPログ
sudo journalctl -u hostapd -n 50     # APログ
```

---

## 🧠 備考 / Notes

- 設定反映でインターフェースが再起動され、接続が一時的に切れることがあります  
- 有線LAN (eth0) の使用を推奨（設定変更時のバックドア経路として）
