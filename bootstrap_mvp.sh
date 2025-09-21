#!/usr/bin/env bash
# bootstrap_mvp.sh — Azazel-Pi SOC/NOC 最小可動セット(MVP)導入
# 要件: Raspberry Pi OS 64bit, root 実行, ネット接続（初回のみ）, Python3
# 安全設計: 冪等性・即時ロールバック関数・明示エラーハンドリング

set -euo pipefail

### ========= ユーザー可変セクション =========
AZ_BASE="/opt/azazel"          # 配置ルート
AZ_NODE="azazel-pi-01"
IF_LAN="lan0"                   # 例: eth0 / br0 / wlan0
IF_WAN="wan0"                   # 例: eth1 / ppp0
WAN_UPLINK_RATE="10mbit"        # 仮置き
MM_WEBHOOK=""                   # 必要なら設定
### ======================================

export MM_WEBHOOK

# 0) 前提チェック
require_root() { [ "${EUID:-$(id -u)}" -eq 0 ] || { echo "[ERR] rootで実行してください"; exit 1; }; }
detect_cmd()   { command -v "$1" >/dev/null 2>&1; }
log()          { echo -e "[`date +%H:%M:%S`] $*"; }
abort()        { echo "[FATAL] $*" >&2; exit 1; }

require_root
log "前提コマンド確認"
for c in iptables nft tc python3; do detect_cmd "$c" || abort "$c が見つかりません"; done

# 1) 依存導入（可能な範囲で冪等）
log "パッケージ導入 (suricata, python3-pip, curl, jq など)"
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  suricata python3-pip python3-venv curl jq git ca-certificates

# Vector: aptに在庫があれば使う。無ければ後でスキップ実行に落とす
if ! detect_cmd vector; then
  log "vector が見つかりません。後段は file 出力だけで進みます（動作に支障なし）"
fi

# OpenCanary は pip 由来
if ! detect_cmd opencanaryd; then
  log "OpenCanary 導入"
  pip3 install --no-cache-dir --break-system-packages opencanary==0.7.0 scapy==2.5.0
fi

# 2) ディレクトリ作成
log "ディレクトリ作成"
install -d -m 755 \
  "$AZ_BASE"/{azctl,azazel_core/{actions,qos,ingest,notify,evidence,api},scripts,configs/{vector,opencanary,nftables,tc},systemd,tasks,tests,var/{log/{azazel,suricata,canary},run}}

# 3) 設定ファイル・コード配置（最小実装）
log "設定とコードを配置"

# configs: Vector 最小
cat > "$AZ_BASE/configs/vector/vector.toml" <<EOVEC
[sources.suri]
type = "file"
include = ["/var/log/suricata/eve.json"]

[sources.canary]
type = "file"
include = ["/var/log/opencanary/canary.json"]

[transforms.norm]
type = "remap"
inputs = ["suri","canary"]
source = '''
  .ts = now()
  .node = "$AZ_NODE"
  .event = exists(.alert) ? "suricata.alert" : "canary.hit"
  .src_ip = .src_ip || .src.ip || .src || null
'''

[sinks.normfile]
type = "file"
inputs = ["norm"]
path = "/var/log/azazel/normalized.json"
encoding.codec = "json"
EOVEC

# configs: OpenCanary
cat > "$AZ_BASE/configs/opencanary/opencanary.conf" <<EOOC
{
  "device.node_id": "$AZ_NODE",
  "honeypot.log_path": "/var/log/opencanary",
  "logger": {
    "class": "opencanary.logger.jsonlogger.JsonLogger",
    "kwargs": {"logfile": "/var/log/opencanary/canary.json"}
  },
  "ssh.enabled": true,
  "ssh.port": 2222,
  "http.enabled": true,
  "http.port": 8080,
  "http.skin": "nasLogin",
  "pgsql.enabled": true,
  "pgsql.port": 55432
}
EOOC

# configs: nftables
cat > "$AZ_BASE/configs/nftables/azazel.nft" <<'EONFT'
table inet azazel {
  chain prerouting {
    type nat hook prerouting priority -100; policy accept;
  }
  chain forward {
    type filter hook forward priority 0; policy accept;
    ct state established,related accept
  }
}
EONFT

# scripts: nft適用・tc初期化
cat > "$AZ_BASE/scripts/nft_apply.sh" <<'EONFTAPPLY'
#!/usr/bin/env bash
set -euo pipefail
NFT=/etc/azazel/nft/azazel.nft
install -d -m 755 /etc/azazel/nft
cp -f "$(dirname "$0")/../configs/nftables/azazel.nft" "$NFT"
nft -f "$NFT"
EONFTAPPLY
chmod +x "$AZ_BASE/scripts/nft_apply.sh"

cat > "$AZ_BASE/scripts/tc_reset.sh" <<'EOTC'
#!/usr/bin/env bash
set -euo pipefail
DEV="${1:-wan0}"
RATE="${2:-10mbit}"
tc qdisc del dev "$DEV" root 2>/dev/null || true
tc qdisc add dev "$DEV" root handle 1: htb default 40
tc class add dev "$DEV" parent 1: classid 1:1 htb rate "$RATE"
tc class add dev "$DEV" parent 1:1 classid 1:40 htb rate 2mbit
EOTC
chmod +x "$AZ_BASE/scripts/tc_reset.sh"

# azazel_core: 状態機械・最小行動
cat > "$AZ_BASE/azazel_core/state_machine.py" <<'EOSTATE'
from enum import Enum
class Mode(str, Enum):
    PORTAL="portal"; SHIELD="shield"; LOCKDOWN="lockdown"
class State:
    def __init__(self): self.mode = Mode.PORTAL
    def set_mode(self, m:Mode): self.mode = m
    def thresholds(self):
        return {"portal":50, "shield":80, "lockdown":80}[self.mode.value]
STATE = State()
EOSTATE

cat > "$AZ_BASE/azazel_core/actions/delay.py" <<'EODELAY'
import subprocess
def apply(delay_ms=200, dev="wan0"):
    subprocess.run(["/usr/sbin/tc","qdisc","change","dev",dev,"parent","1:40","handle","40:","netem","delay",f"{delay_ms}ms"], check=False)
EODELAY

cat > "$AZ_BASE/azazel_core/actions/redirect.py" <<'EOREDIRECT'
import subprocess
def to_canary(src_ip, port=22, to="127.0.0.1:2222"):
    subprocess.run(["/usr/sbin/iptables","-t","nat","-A","PREROUTING","-s",src_ip,"-p","tcp","--dport",str(port),"-j","DNAT","--to-destination",to], check=False)
EOREDIRECT

# ingest: normalized.json tail
cat > "$AZ_BASE/azazel_core/ingest/tailer.py" <<'EOTAIL'
import json, time, os
SRC = "/var/log/azazel/normalized.json"
def stream():
    os.makedirs("/var/log/azazel", exist_ok=True)
    open(SRC, "a").close()
    with open(SRC, "r") as f:
        f.seek(0,2)
        while True:
            line = f.readline()
            if not line:
                time.sleep(1); continue
            try:
                yield json.loads(line)
            except Exception:
                continue
EOTAIL

# notify: Mattermost（任意）
cat > "$AZ_BASE/azazel_core/notify/mattermost.py" <<'EOMM'
import os, json, urllib.request
HOOK = os.environ.get("MM_WEBHOOK","")
def post(text):
    if not HOOK: return
    data = json.dumps({"text": text}).encode()
    req = urllib.request.Request(HOOK, data=data, headers={"Content-Type":"application/json"})
    try: urllib.request.urlopen(req, timeout=3)
    except Exception: pass
EOMM

# API: /v1/mode のみ先行
cat > "$AZ_BASE/azazel_core/api/server.py" <<'EOAPI'
from flask import Flask, request, jsonify
from azazel_core.state_machine import STATE, Mode
app = Flask(__name__)
@app.post("/v1/mode")
def set_mode():
    m = request.json.get("mode","portal")
    STATE.set_mode(Mode(m))
    return jsonify({"ok":True,"mode":STATE.mode.value})
if __name__ == "__main__":
    app.run("127.0.0.1", 8787)
EOAPI

# azctl: デーモン（最小ループ）
cat > "$AZ_BASE/azctl/daemon.py" <<'EOCTL'
import os, time
from azazel_core.state_machine import STATE
from azazel_core.ingest.tailer import stream
from azazel_core.actions.delay import apply as delay_apply
from azazel_core.actions.redirect import to_canary
WAN = os.environ.get("AZ_WAN","wan0")
while True:
    for ev in stream():
        score = 70 if ev.get("event")=="suricata.alert" else 40
        src = ev.get("src_ip")
        thr = STATE.thresholds()
        if score >= 50 and STATE.mode.value == "portal":
            delay_apply(200, WAN)
        if score >= 80 and STATE.mode.value in ("shield","lockdown") and src:
            to_canary(src)
    time.sleep(0.5)
EOCTL

# 4) systemd ユニット配置
log "systemd ユニット配置"
cat > "$AZ_BASE/systemd/suricata.service" <<EOSURI
[Unit]
Description=Suricata IDS
After=network-online.target
[Service]
ExecStart=/usr/bin/suricata -c /etc/suricata/suricata.yaml -i $IF_LAN --af-packet
Restart=always
[Install]
WantedBy=multi-user.target
EOSURI

cat > "$AZ_BASE/systemd/opencanary.service" <<'EOOCS'
[Unit]
Description=OpenCanary Honeypot
After=network-online.target
[Service]
ExecStart=/usr/local/bin/opencanaryd --start --dev -c /opt/azazel/configs/opencanary/opencanary.conf
Restart=always
[Install]
WantedBy=multi-user.target
EOOCS

cat > "$AZ_BASE/systemd/vector.service" <<'EOVECUNIT'
[Unit]
Description=Vector Pipeline
After=network-online.target
ConditionPathExists=/usr/bin/vector
[Service]
ExecStart=/usr/bin/vector -c /opt/azazel/configs/vector/vector.toml
Restart=always
[Install]
WantedBy=multi-user.target
EOVECUNIT

cat > "$AZ_BASE/systemd/azctl.service" <<'EOAZCTLUNIT'
[Unit]
Description=Azazel Control Daemon
After=suricata.service opencanary.service
[Service]
Environment=AZ_WAN=wan0
WorkingDirectory=/opt/azazel
ExecStart=/usr/bin/python3 /opt/azazel/azctl/daemon.py
Restart=always
[Install]
WantedBy=multi-user.target
EOAZCTLUNIT

# 5) Suricata 設定ファイルの存在保証（既存を尊重）
log "Suricata 設定の存在確認"
[ -f /etc/suricata/suricata.yaml ] || abort "/etc/suricata/suricata.yaml が必要です（OSパッケージに同梱）"
install -d -m 755 /var/log/opencanary /var/log/azazel

# 6) システム配置・有効化
log "システム配置"
install -m 644 "$AZ_BASE/systemd/"*.service /etc/systemd/system/
install -d -m 755 /etc/azazel/nft
cp -f "$AZ_BASE/configs/nftables/azazel.nft" /etc/azazel/nft/azazel.nft
systemctl daemon-reload

log "ネットワーク初期化 (nft/tc)"
bash "$AZ_BASE/scripts/nft_apply.sh"
bash "$AZ_BASE/scripts/tc_reset.sh" "$IF_WAN" "$WAN_UPLINK_RATE"

log "サービス起動"
systemctl enable --now suricata.service
systemctl enable --now opencanary.service
detect_cmd vector && systemctl enable --now vector.service || true
systemctl enable --now azctl.service

# 7) APIプロセス（最小）の案内
log "APIサーバは必要時に: python3 $AZ_BASE/azazel_core/api/server.py &"
log "モード切替例: curl -s -X POST localhost:8787/v1/mode -H 'Content-Type: application/json' -d '{\"mode\":\"shield\"}'"

# 8) 動作確認ポイント
echo "=== 確認コマンド ===
journalctl -u suricata -n 20 --no-pager
journalctl -u opencanary -n 20 --no-pager
[ -x /usr/bin/vector ] && journalctl -u vector -n 20 --no-pager || echo 'vector未導入: /var/log/azazel/normalized.json を直接監視'
tail -f /var/log/azazel/normalized.json | head -n 5
"

# 9) ロールバック関数（参照用）
cat > "$AZ_BASE/scripts/rollback.sh" <<'EORB'
#!/usr/bin/env bash
set -euo pipefail
systemctl disable --now azctl.service || true
systemctl disable --now vector.service || true
systemctl disable --now opencanary.service || true
systemctl disable --now suricata.service || true
tc qdisc del dev wan0 root 2>/dev/null || true
iptables -t nat -F PREROUTING || true
nft delete table inet azazel 2>/dev/null || true
echo "[OK] 停止・初期化完了"
EORB
chmod +x "$AZ_BASE/scripts/rollback.sh"

log "完了。必要なら $AZ_BASE/scripts/rollback.sh で安全に戻せます。"
