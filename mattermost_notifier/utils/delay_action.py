import subprocess
import logging
from config import notice

# OpenCanary 側 IP
OPENCANARY_IP = notice.OPENCANARY_IP

# ネットワークインタフェース
NET_INTERFACE = notice.NET_INTERFACE

# 転送対象ポート
PORT_MAP = {
    22:   22,     # SSH
    80:   80,     # HTTP
    5432: 5432    # PostgreSQL
}

def _exists(src_ip, dst_port):
    """同一 DNAT ルールがすでに存在するか簡易チェック"""
    ret = subprocess.run(
        ["iptables", "-t", "nat", "-C", "PREROUTING",
         "-s", src_ip, "-p", "tcp", "--dport", str(dst_port),
         "-j", "DNAT", "--to-destination",
         f"{OPENCANARY_IP}:{PORT_MAP[dst_port]}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    return ret.returncode == 0

def _setup_masquerade():
    """OpenCanaryへのMASQUERADEルールを確認・追加する"""
    try:
        ret = subprocess.run(
            ["iptables", "-t", "nat", "-C", "POSTROUTING",
             "-d", OPENCANARY_IP, "-j", "MASQUERADE"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        if ret.returncode == 0:
            logging.debug("[MASQUERADE] 既存ルールあり、追加不要")
            return

        subprocess.run(
            ["iptables", "-t", "nat", "-A", "POSTROUTING",
             "-d", OPENCANARY_IP, "-j", "MASQUERADE"],
            check=True
        )
        logging.info("[MASQUERADE] OpenCanary向けPOSTROUTINGルール追加完了")

    except subprocess.CalledProcessError as e:
        logging.error(f"[MASQUERADEエラー] {e}")

def _setup_tc_delay(src_ip):
    """攻撃者IPに対して通信遅延 (tc netem) をかける"""
    try:
        subprocess.run(["tc", "qdisc", "add", "dev", NET_INTERFACE, "root", "handle", "1:", "prio"], check=False)
        subprocess.run(["tc", "qdisc", "add", "dev", NET_INTERFACE, "parent", "1:1", "handle", "10:",
                        "netem", "delay", "500ms", "100ms", "distribution", "normal"], check=False)

        subprocess.run([
            "tc", "filter", "add", "dev", NET_INTERFACE, "protocol", "ip", "parent", "1:",
            "prio", "1", "u32", "match", "ip", "dst", src_ip, "flowid", "1:1"
        ], check=True)

        logging.info(f"[遅滞行動] tc遅延設定追加 {src_ip}")

    except subprocess.CalledProcessError as e:
        logging.error(f"[遅滞行動エラー] tc設定失敗: {e}")

def divert_to_opencanary(src_ip, dst_port):
    """攻撃元 src_ip が dst_port へアクセスした場合、OpenCanaryへ転送＆遅延付与＆MASQUERADE"""
    if dst_port not in PORT_MAP:
        logging.debug(f"[遅滞行動] port {dst_port} は転送対象外")
        return

    _setup_masquerade()  # ★ 最初に必ずMASQUERADEを確認・追加する

    if _exists(src_ip, dst_port):
        logging.debug(f"[遅滞行動] 既存 DNAT ルールのためスキップ {src_ip}:{dst_port}")
        return

    try:
        subprocess.run([
            "iptables", "-t", "nat", "-A", "PREROUTING",
            "-s", src_ip, "-p", "tcp", "--dport", str(dst_port),
            "-j", "DNAT", "--to-destination", f"{OPENCANARY_IP}:{PORT_MAP[dst_port]}"
        ], check=True)
        logging.info(f"[遅滞行動] {src_ip}:{dst_port} -> {OPENCANARY_IP}:{PORT_MAP[dst_port]} DNAT追加")

        _setup_tc_delay(src_ip)

    except subprocess.CalledProcessError as e:
        logging.error(f"[遅滞行動エラー] iptables失敗: {e}")
