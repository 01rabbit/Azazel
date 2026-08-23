#!/usr/bin/env bash
set -euo pipefail

LAB_ROOT="${AZAZEL_LAB_ROOT:-$HOME/azazel-m5pro-lab}"
RUNTIME_ENV="$LAB_ROOT/runtime.env"
[[ -f "$RUNTIME_ENV" ]] || { echo "missing $RUNTIME_ENV; run bootstrap.sh first" >&2; exit 2; }
# shellcheck disable=SC1090
source "$RUNTIME_ENV"

REPOS="$LAB_ROOT/repos"
STATE="$LAB_ROOT/state"
LOGS="$LAB_ROOT/logs"
PIDS="$LAB_ROOT/pids"
mkdir -p "$LOGS" "$PIDS" "$STATE/deception"
chmod 700 "$LOGS" "$PIDS" "$STATE" 2>/dev/null || true

EDGE="$REPOS/Azazel-Edge"
KNOW="$REPOS/Azazel-Knowledge"
DECEPTION="$REPOS/Azazel-Deception"

for path in "$EDGE" "$KNOW" "$DECEPTION"; do
  [[ -d "$path" ]] || { echo "missing repo: $path" >&2; exit 2; }
done

is_alive() {
  local pidfile="$1"
  [[ -f "$pidfile" ]] || return 1
  local pid
  pid="$(cat "$pidfile" 2>/dev/null || true)"
  [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null
}

wait_port() {
  local host="$1" port="$2" name="$3"
  python3 - "$host" "$port" "$name" <<'PY'
import socket, sys, time
host, port, name = sys.argv[1], int(sys.argv[2]), sys.argv[3]
for _ in range(50):
    try:
        with socket.create_connection((host, port), timeout=0.3):
            print(f"[ OK ] {name}: {host}:{port}")
            raise SystemExit(0)
    except OSError:
        time.sleep(0.1)
raise SystemExit(f"{name} did not open {host}:{port}")
PY
}

KNOW_PID="$PIDS/knowledge.pid"
if is_alive "$KNOW_PID"; then
  echo "[skip] Knowledge already running pid=$(cat "$KNOW_PID")"
else
  echo "[start] Azazel-Knowledge API on 127.0.0.1:$AZAZEL_KNOWLEDGE_PORT"
  (
    cd "$KNOW"
    AZAZEL_ROOT="$STATE/knowledge" \
    AZAZEL_CONFIG_DIR="$KNOW/config" \
    nohup .venv/bin/uvicorn azazel_knowledge.api.app:app \
      --host 127.0.0.1 --port "$AZAZEL_KNOWLEDGE_PORT" \
      >"$LOGS/knowledge-api.log" 2>&1 &
    echo $! > "$KNOW_PID"
  )
fi
wait_port 127.0.0.1 "$AZAZEL_KNOWLEDGE_PORT" "Azazel-Knowledge"

DECEPTION_PID="$PIDS/deception.pid"
if is_alive "$DECEPTION_PID"; then
  echo "[skip] Deception shadow already running pid=$(cat "$DECEPTION_PID")"
else
  echo "[start] Azazel-Deception SHADOW server on 127.0.0.1:$AZAZEL_DECEPTION_PORT"
  (
    cd "$DECEPTION"
    nohup .venv/bin/python scripts/dev/serve_shadow.py \
      --host 127.0.0.1 \
      --port "$AZAZEL_DECEPTION_PORT" \
      --key "$AZAZEL_DECEPTION_HMAC_KEY" \
      --edge-id "$AZAZEL_EDGE_ID" \
      --node-id "$AZAZEL_DECEPTION_NODE_ID" \
      --state-root "$STATE/deception" \
      >"$LOGS/deception-shadow.log" 2>&1 &
    echo $! > "$DECEPTION_PID"
  )
fi
wait_port 127.0.0.1 "$AZAZEL_DECEPTION_PORT" "Azazel-Deception shadow"

if curl -fsS --max-time 2 "$AZAZEL_OLLAMA_ENDPOINT/api/tags" >/dev/null 2>&1; then
  echo "[ OK ] Ollama: $AZAZEL_OLLAMA_ENDPOINT"
else
  echo "[WARN] Ollama is not reachable at $AZAZEL_OLLAMA_ENDPOINT; deterministic services are ready, live M.I.O. inference is not" >&2
fi

cat <<EOF

Shadow lab is running.

  Knowledge:  http://127.0.0.1:$AZAZEL_KNOWLEDGE_PORT
  Deception:  http://127.0.0.1:$AZAZEL_DECEPTION_PORT  (shadow/replay only; live_execution=disabled)
  Ollama:     $AZAZEL_OLLAMA_ENDPOINT
  Logs:       $LOGS

M.I.O. local-model replay (no Arbiter/enforcement):

  cd "$EDGE"
  PYTHONPATH=py .venv/bin/python bin/azazel-mio-shadow-replay \\
    --fixture tests/fixtures/mio/auth_ambiguity_shadow.json \\
    --playbook auth-ambiguity-v1 \\
    --endpoint "$AZAZEL_OLLAMA_ENDPOINT"

Use stop-shadow-lab.sh to stop only the two processes started by this lab.
EOF
