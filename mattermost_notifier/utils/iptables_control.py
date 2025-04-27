import subprocess

# OpenCanaryサーバのIPアドレス
OPEN_CANARY_IP = "172.16.10.10"

# 転送対象ポートリスト（OpenCanaryでサービス公開しているポート）
REDIRECT_PORTS = [22, 80, 443]

# 遅延をかけるネットワークインタフェース名（適宜変更）
NET_INTERFACE = "wlan1"

def redirect_and_delay_attacker(attacker_ip):
    """攻撃者IPをOpenCanaryに転送し、レスポンス遅延をかける"""
    try:
        # --- iptables NATルール追加（PREROUTINGで転送） ---
        for port in REDIRECT_PORTS:
            cmd = [
                "iptables", "-t", "nat", "-A", "PREROUTING",
                "-s", attacker_ip,
                "-p", "tcp", "--dport", str(port),
                "-j", "DNAT", "--to-destination", f"{OPEN_CANARY_IP}:{port}"
            ]
            subprocess.run(cmd, check=True)
            print(f"[+] iptablesルール追加: {attacker_ip} → {OPEN_CANARY_IP}:{port}")

        # --- tcによる通信遅延設定（netem使用） ---
        subprocess.run(["tc", "qdisc", "add", "dev", NET_INTERFACE, "root", "handle", "1:", "prio"], check=False)

        subprocess.run([
            "tc", "filter", "add", "dev", NET_INTERFACE, "protocol", "ip", "parent", "1:",
            "prio", "1", "u32", "match", "ip", "dst", attacker_ip,
            "flowid", "1:1", "action", "netem", "delay", "500ms", "100ms", "distribution", "normal"
        ], check=True)

        print(f"[+] tc遅延設定追加: {attacker_ip}へのレスポンスを遅延")

    except subprocess.CalledProcessError as e:
        print(f"[-] ルール追加失敗: {e}")