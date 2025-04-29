import json
import time

# 生成するダミーアラートデータ
fake_alert = {
    "timestamp": "2025-04-27T12:34:56.789Z",
    "event_type": "alert",
    "src_ip": "192.168.1.123",  # 擬似攻撃元IP
    "dest_ip": "172.16.0.254",  # Gateway
    "proto": "TCP",
    "alert": {
        "action": "allowed",
        "gid": 1,
        "signature_id": 2100498,
        "rev": 5,
        "signature": "ET SCAN Potential SSH Scan",
        "category": "Attempted Information Leak",
        "severity": 2
    }
}

# 書き込む対象eve.jsonファイル（通常Suricataが出力する）
eve_json_path = "/var/log/suricata/eve.json"

def inject_fake_alert():
    with open(eve_json_path, "a") as f:
        json.dump(fake_alert, f)
        f.write("\n")  # 1行ごとに改行する
    print(f"[+] ダミーアラートを {eve_json_path} に書き込みました。")

if __name__ == "__main__":
    inject_fake_alert()
