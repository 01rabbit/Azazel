# Mattermost Webhook通知用
MATTERMOST_WEBHOOK_URL = "http://172.16.0.254:8065/hooks/ij7twkik37ykmnjqfhtrwfy3bo"

# Suricataのeve.jsonログファイルパス
SURICATA_EVE_JSON_PATH = "/var/log/suricata/eve.json"

# config/notice.py に追加
OPENCANARY_LOG_PATH = "/opt/azazel/logs/opencanary.log"

# suppress key のモード指定
# 選択肢: "signature", "signature_ip", "signature_ip_user", "signature_ip_user_session"
SUPPRESS_KEY_MODE = "signature_ip_user"  # 推奨

