# 御調子門 -AZAZEL system- : The Cyber Scapegoat Gateway

## 概要 / Overview

**御調子門 -AZAZEL system-** は、攻撃をあえて受け止め、**遅滞**させることを目的とした新たなアクティブサイバーディフェンスツールです。Raspberry Pi 5上で動作する本システムは、スケープゴート型デコイを活用し、攻撃者を欺き、行動を遅らせ、防御側に対応時間を確保します。

また本ツールは、**外出先のホテルやフリーWi-Fiなど、安全が確認できないネットワーク環境においても、潜在的な脅威からユーザーを守る防壁**として機能します。安全でないネットワークに接続せざるを得ない場面でも、攻撃を直接受けずにリスクを緩和できます。

**AZAZEL system** is an active cyber defense tool designed to **delay and disrupt adversaries** rather than simply block them. Operating as a portable gateway on Raspberry Pi 5, it uses a cyber **scapegoat-style decoy** to mislead and slow down attackers, providing defenders with critical time to respond.

Additionally, the system acts as a **protective barrier when connecting to untrusted networks**, such as free Wi-Fi in hotels or public spaces—helping shield users from direct threats lurking within insecure environments.

---

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
