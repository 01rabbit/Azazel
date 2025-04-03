# 御調子門 -AZAZEL system- : The Cyber Scapegoat Gateway

## 概要 / Overview

**御調子門 -AZAZEL system-** は、攻撃をあえて受け止め、**遅滞**させることを目的とした、新たなアクティブサイバーディフェンスツールです。**持ち運び可能な小型ゲートウェイとして、社外でのネットワーク展開時や外出先での一時的な接続環境に**おいて活用されます。Raspberry Pi 5上で動作する本システムは、スケープゴート型デコイを活用し、攻撃者を欺き、行動を遅らせ、防御側に対応時間を確保します。

このツールは、**ホテルのフリーWi-Fiや検証されていない外部ネットワークへの接続時に、ユーザーを潜在的な脅威から守るための携行型セキュリティ境界装置**として機能します。

**AZAZEL system** is a portable active cyber defense tool designed to **delay and mislead attackers** during temporary and external network connections. Deployed on a compact Raspberry Pi 5, it is ideal for off-site system deployments, hotel Wi-Fi access, or other untrusted network environments. The system employs a **scapegoat-style decoy** to slow attackers down, giving defenders critical time to respond.

---

## 可搬型設計 / Portable Deployment

- **軽量・省電力な構成により、外出先や現場などの一時的なネットワーク接続環境でも容易に導入可能です。**
- **出張時、イベント会場、外部検証ネットワークなど、セキュリティが保証されない場所での利用に最適です。**

- **Lightweight and energy-efficient**, enabling quick deployment in temporary and mobile environments.
- **Perfect for use during business trips, field operations, or in untrusted networks outside your primary infrastructure.**
## 特徴 / Features

- **遅滞戦術の実装 / Tactical Delaying**  
  陸戦における「遅滞行動」の概念を、サイバー空間に適用。侵入を許容しつつ、その進行をコントロール。

- **リアルタイム侵入検知と制御 / Real-Time IDS-based Control**  
  Suricata による侵入検知をトリガーに、攻撃元IPの通信を `tc` や `iptables/nftables` により動的に遅延・制限。

- **スケープゴート型デコイ / Scapegoat Decoy**  
  OpenCanary等を利用し、攻撃者を観察ではなく誘導・拘束。正規ユーザーには影響を与えずに隔離。

- **可搬型設計 / Portable Deployment**  
  軽量構成でRaspberry Piに最適化。災害対応や一時的な現場展開にも対応。

---

## 使用技術 / Stack

- Raspberry Pi OS (64bit Lite)
- Suricata (IDS/IPS)
- OpenCanary (Decoy Services)
- Fluent Bit (Log Collection)
- iptables / nftables + tc (Traffic Control)
- Mattermost / Signal (Alerting)
- Python + Scapy (Custom Response Logic)
- rsync + SSH (Optional Log Export)

---

## インストール / Installation

```bash
git clone https://github.com/01rabbit/Azazel.git azazel
cd azazel
./install.sh
```

※ 詳細は `docs/setup.md` を参照してください。  
See `docs/setup.md` for full setup instructions.

---

## 開発の背景 / Background

現代のサイバー攻撃は高速化・自動化し、従来のハニーポットでは対応が困難です。本システムは、**単なる観察やブロックではなく、戦術的に遅らせる**ことを目的に設計されています。

As cyber attacks become faster and more automated, traditional honeypots fall short. This system embraces a **strategic delaying approach**, turning time into a defensive asset.

---

## メッセージ / Message

> 防御とは、時間を稼ぐことである。  
> Defense is the art of buying time.

---

## ライセンス / License

MIT License
