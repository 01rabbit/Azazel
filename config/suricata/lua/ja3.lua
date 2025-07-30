-- /etc/suricata/lua/ja3.lua
-- ★JA3/JA4 指紋チェックの雛形
-- “state” スクリプト形式

-- 例として怪しい JA3 ハッシュを 1 個だけ持つ
local blacklist = {
  ["e7d705a3286e19ea42f587b344ee6865"] = true  -- nmap/sslscan 既知ハッシュ
}

function init(args)
  local needs = {}
  needs["type"] = "tls"     -- TLS レコードイベントを受信
  return needs
end

function match(args)
  local eve = args["eve"]
  local ja3 = eve["tls"]["ja3_hash"]     -- Suricata 7 系 なら ja4_hash も取得可
  if ja3 and blacklist[ja3] then
    -- JA3 がブラックなら Suricata 内部で “alert” を生成
    SCLogInfo("JA3 match: "..ja3)
    return 1   -- 1 を返すと signature_sid=1 の LuaAlert が立つ
  end
  return 0
end