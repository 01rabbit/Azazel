-- /etc/suricata/lua/delay.lua
-- ★遅延発動ロジックの雛形
-- Suricata Lua “state” スクリプト形式

function init(args)
  local needs = {}
  -- アラートイベントを受け取るだけ
  needs["type"] = "alert"
  return needs
end

-- flow 単位で呼ばれる
function match(args)
  -- TODO: ここで tc / nftables などを実行して遅延させる
  return 0     -- 0 を返せば Suricata の処理を継続
end