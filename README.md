# 御調子門 -AZAZEL system- : The Cyber Scapegoat Gateway

## 概要 / Overview

**Delaying Action（遅滞行動）** という言葉をご存知でしょうか？
これは軍事戦略において、防御部隊が決定的な戦闘を避けつつ、敵の進撃を可能な限り遅らせるために戦い続け、時間を稼ぐための防衛行動を意味します。今日のサイバー戦では、攻撃が高速かつ自動化され、わずか数秒で資産が侵害されるリスクがあります。この古典的な戦術思想を、現代のサイバーセキュリティに再解釈して応用すべきだと私たちは考えました。

この考え方をもとに開発されたのが **御調子門 -Azazel System-** です。本ツールは、**スケープゴート型デコイ**を実装しており、攻撃を吸収し、攻撃者を誤誘導しながら、その進行を戦術的に遅延させます。従来のハニーポットのように単に観察するのではなく、攻撃者を能動的に拘束し、**サイバー空間における遅滞行動**を実現します。

本ツールは、出張先のホテルやイベント会場などの**信頼できない外部ネットワーク**に接続する際や、**一時的なラボ環境**を守る必要がある場面において、ユーザーを能動的に保護する**可搬型のセキュリティゲートウェイ**として設計されています。

現代の戦場はサイバー空間へと移りましたが、「時間を稼ぐために敵を拘束する」という発想は今も通用します。**御調子門**は、サイバー戦における「戦術的足止め」を具現化するための、一つの答えです。

**Azazel System** is a portable active cyber defense tool inspired by the classical military concept of **Delaying Action**—a defensive operation aimed at slowing the enemy's advance while avoiding decisive engagement. In the age of automated and lightning-fast cyber attacks, where assets can be compromised within seconds, we believe this timeless strategy deserves modern re-implementation.

The system uses a **scapegoat-style decoy** to absorb, mislead, and delay adversaries. Unlike traditional honeypots that passively observe, Azazel actively restrains attacker behavior to buy time—a tactical "delaying action" in cyberspace.

This tool is designed for use in **untrusted external environments**—such as hotel Wi-Fi, public venues, or temporary lab setups—where users need portable, proactive protection.

Though the battlefield has shifted into cyberspace, the principle of "binding the enemy to buy time" remains effective. **Azazel System** provides a modern response to that strategic need.

---

## 設計思想 / Design Philosophy

御調子門 -AZAZEL system- の防御思想は、日本における二つの戦術的概念に着想を得ています。

ひとつは、日本陸軍における防御戦術の原則である「**敵を戦場に拘束する**」という考え方です。これは、敵の攻撃をただ防ぐのではなく、あえて戦場に引き留め、敵の行動を制限しながら、味方の後続準備や反撃の時間を稼ぐことを目的としています。御調子門もこれと同様に、侵入者をシステム上に誘導し、デコイや通信遅延の中に拘束することで、攻撃の自由度を奪い、防御側に主導権を渡す構造をとっています。

もうひとつは、日本古来の武術における「**後の先（ごのせん）**」という戦い方です。これは、相手の動きを見てから反応することで、逆に主導権を握るという高度な戦術です。見かけ上は後手に見えても、実際には相手の攻撃を利用して、制御し、反撃の機を得るというものです。御調子門では、Suricataによる侵入検知後に遅滞制御を発動することで、この「後の先」の構えを実装しています。攻撃をあえて引き受け、観察し、制御するという戦術的な対応が、この思想に通じます。

このように、御調子門は「防御とは単に守ることではなく、敵の行動を制御し、時間を稼ぐこと」というコンセプトを体現しており、日本的な戦術思想に根ざしたサイバーデセプションツールです。

**Azazel System** is rooted in two key Japanese strategic doctrines:

- The **Imperial Japanese Army’s principle of battlefield containment**—not simply blocking the enemy, but intentionally binding them to a location to limit their actions and buy time for reinforcements or counteroffensives.

- The **martial arts concept of "Go no Sen"**, or taking initiative in response. Rather than preemptive strikes, this principle capitalizes on the opponent's move, using their momentum against them. Azazel embodies this by activating its response only after intrusion is detected, deliberately reacting to the attacker’s behavior to assert control.

These principles converge in Azazel’s design: **defense is not about passive protection, but about active control and strategic delay.**

---

## 可搬型設計 / Portable Deployment

- **軽量・省電力な構成により、外出先や現場などの一時的なネットワーク接続環境でも容易に導入可能です。**  
*Lightweight and energy-efficient, enabling quick deployment in temporary and mobile environments.*

- **出張時、イベント会場、外部検証ネットワークなど、セキュリティが保証されない場所での利用に最適です。**  
*Perfect for use during business trips, field operations, or in untrusted networks outside your primary infrastructure.*

## 特徴 / Features

- **遅滞戦術の実装 / Tactical Delaying**  
  陸戦における「遅滞行動」の概念を、サイバー空間に適用。侵入を許容しつつ、その進行をコントロール。  
  *Applies the military concept of delaying action to cyberspace—permitting intrusion while strategically controlling its progression.*

- **リアルタイム侵入検知と制御 / Real-Time IDS-based Control**  
  Suricata による侵入検知をトリガーに、攻撃元IPの通信を `tc` や `iptables/nftables` により動的に遅延・制限。  
  *Triggered by Suricata IDS alerts, dynamically throttles or restricts traffic from attacker IPs using `tc` and `iptables/nftables`.*

- **スケープゴート型デコイ / Scapegoat Decoy**  
  OpenCanary等を利用し、攻撃者を観察ではなく誘導・拘束。正規ユーザーには影響を与えずに隔離。  
  *Leverages tools like OpenCanary to mislead and isolate attackers—not merely observe them—without affecting legitimate users.*

- **可搬型設計 / Portable Deployment**  
  軽量構成でRaspberry Piに最適化。災害対応や一時的な現場展開にも対応。  
  *Lightweight and optimized for Raspberry Pi, enabling easy deployment in disaster recovery or temporary field operations.*

---

## 使用技術 / Stack

- Raspberry Pi OS (64bit Lite)
- Suricata (IDS/IPS)
- OpenCanary (Decoy Services)
- Vector (Log Collection)
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
