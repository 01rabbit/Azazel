from datetime import timezone, timedelta

# 日本時間（UTC+9）
TZ = timezone(timedelta(hours=9))

# Mattermost Webhook通知用
MATTERMOST_WEBHOOK_URL = "http://192.168.40.186:8065/hooks/4skkamks8pfx9xka7sd1st1uno"

# Suricataのeve.jsonログファイルパス
SURICATA_EVE_JSON_PATH = "/var/log/suricata/eve.json"

# config/notice.py に追加
OPENCANARY_LOG_PATH = "/opt/azazel/logs/opencanary.log"

# suppress key のモード指定
# 選択肢: "signature", "signature_ip", "signature_ip_user", "signature_ip_user_session"
SUPPRESS_KEY_MODE = "signature_ip_user"  # 推奨

# OpenCanaryサーバのIPアドレス
OPENCANARY_IP = "172.16.10.10"

# 遅延をかけるネットワークインタフェース名
NET_INTERFACE = "wlan1"

# 無活動許容時間（分）
INACTIVITY_MINUTES = 2
