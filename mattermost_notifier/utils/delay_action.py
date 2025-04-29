import subprocess
import logging

# OpenCanary 側 IP
OPENCANARY_IP = "172.16.10.10"

# 転送対象ポート（必要に応じて増減）
PORT_MAP = {
    22:   22,     # SSH  -> SSH
    80:   80,     # HTTP -> HTTP
    5432: 5432    # PostgreSQL -> PostgreSQL
}

def _exists(src_ip, dst_port):
    """
    同一 DNAT ルールがすでに存在するか簡易チェック
    """
    ret = subprocess.run(
        ["iptables", "-t", "nat", "-C", "PREROUTING",
         "-s", src_ip, "-p", "tcp", "--dport", str(dst_port),
         "-j", "DNAT", "--to-destination",
         f"{OPENCANARY_IP}:{PORT_MAP[dst_port]}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    return ret.returncode == 0

def divert_to_opencanary(src_ip, dst_port):
    """
    攻撃元 src_ip が dst_port へアクセスした場合、
    OpenCanary(IP:port) へ転送する DNAT ルールを追加。
    """
    if dst_port not in PORT_MAP:
        logging.debug(f"[遅滞行動] port {dst_port} は転送対象外")
        return

    if _exists(src_ip, dst_port):
        logging.debug(f"[遅滞行動] 既存 DNAT ルールのためスキップ {src_ip}:{dst_port}")
        return

    try:
        subprocess.run([
            "iptables", "-t", "nat", "-A", "PREROUTING",
            "-s", src_ip, "-p", "tcp", "--dport", str(dst_port),
            "-j", "DNAT", "--to-destination", f"{OPENCANARY_IP}:{PORT_MAP[dst_port]}"
        ], check=True)
        logging.info(f"[遅滞行動] {src_ip}:{dst_port} -> {OPENCANARY_IP}:{PORT_MAP[dst_port]} DNAT 追加")
    except subprocess.CalledProcessError as e:
        logging.error(f"[遅滞行動エラー] iptables 失敗: {e}")
