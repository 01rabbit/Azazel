import threading
import signal
import sys
import time
import logging
import subprocess
from datetime import datetime, timedelta

from config import notice
from utils.mattermost import send_alert_to_mattermost
import main_suricata
import main_opencanary

# ログ設定（Suricata/OpenCanaryと揃える）
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)

# グローバル変数
last_attack_time = datetime.now(notice.TZ)
is_normal_mode = False

# notice.pyから設定読み込み
INACTIVITY_LIMIT = timedelta(minutes=notice.INACTIVITY_MINUTES)
threads = []

# ─────────────────────────────────────
def run_suricata():
    main_suricata.main()

def run_opencanary():
    main_opencanary.main()

def notify_attack_detected():
    """攻撃検知時に呼び出す関数"""
    global last_attack_time, is_normal_mode
    last_attack_time = datetime.now(notice.TZ)
    is_normal_mode = False

def reset_network_config():
    logging.info("Flushing NAT rules and resetting basic network config...")

    # ① NATテーブルの全ルールを一旦削除
    subprocess.run(["iptables", "-t", "nat", "-F"], check=False)

    # ② 内部LAN(172.16.0.0/24)からWAN出口(wlan1)へのMASQUERADEを再設定
    subprocess.run(["iptables", "-t", "nat", "-A", "POSTROUTING",
                    "-s", "172.16.0.0/24", "-o", "wlan1", "-j", "MASQUERADE"], check=True)

    logging.info("Internal LAN to WAN routing re-established.")

    # ③ tc設定削除 (遅滞制御は個別にリセット)
    result = subprocess.run(["tc", "qdisc", "show", "dev", "wlan1"], capture_output=True, text=True)
    if "prio" in result.stdout or "netem" in result.stdout:
        subprocess.run(["tc", "qdisc", "del", "dev", "wlan1", "root"], check=False)
        logging.info("tc qdisc deleted.")
    else:
        logging.info("No tc qdisc to delete.")

    logging.info("Network reset completed.")
    
    now_str = datetime.now(notice.TZ).strftime("%Y-%m-%d %H:%M:%S")
    send_alert_to_mattermost("Suricata", {
        "timestamp": now_str,
        "signature": "🟢 通常態勢復帰",
        "severity": 3,
        "src_ip": "-",
        "dest_ip": "-",
        "proto": "-",
        "details": f"{notice.INACTIVITY_MINUTES}分間攻撃が観測されなかったため、通常態勢に復帰しました。",
        "confidence": "Low"
    })
    logging.info("通常態勢復帰メッセージ送信済み。")

def inactivity_watcher():
    global last_attack_time, is_normal_mode
    while True:
        now = datetime.now(notice.TZ)
        if now - last_attack_time > INACTIVITY_LIMIT:
            if not is_normal_mode:
                logging.info(f"No attacks detected for {notice.INACTIVITY_MINUTES} minutes. Resetting network settings...")
                reset_network_config()
                is_normal_mode = True
        time.sleep(30)

def signal_handler(sig, frame):
    logging.info("✋ Ctrl+C detected. Shutting down gracefully...")
    sys.exit(0)

# ─────────────────────────────────────
if __name__ == "__main__":
    logging.info("🚀 Starting unified monitor...")

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    main_suricata.NOTIFY_CALLBACK = notify_attack_detected
    
    t1 = threading.Thread(target=run_suricata, daemon=True)
    t2 = threading.Thread(target=run_opencanary, daemon=True)
    t3 = threading.Thread(target=inactivity_watcher, daemon=True)

    threads.extend([t1, t2, t3])

    for t in threads:
        t.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logging.info("✋ KeyboardInterrupt caught. Exiting...")
        sys.exit(0)
