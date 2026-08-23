#!/usr/bin/env bash
set -euo pipefail

LAB_ROOT="${AZAZEL_LAB_ROOT:-$HOME/azazel-m5pro-lab}"
REPOS="$LAB_ROOT/repos"
STATE="$LAB_ROOT/state"
LOGS="$LAB_ROOT/logs"
RUNTIME_ENV="$LAB_ROOT/runtime.env"
GIT_BASE="${AZAZEL_GIT_BASE:-https://github.com/01rabbit}"
EDGE_BRANCH="${AZAZEL_EDGE_BRANCH:-feat/mio-cognitive-shadow-core}"

mkdir -p "$REPOS" "$STATE" "$LOGS"
chmod 700 "$LAB_ROOT" "$STATE" "$LOGS" 2>/dev/null || true

"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"

clone_or_update() {
  local name="$1" branch="$2" url="$3" dest="$REPOS/$name"
  if [[ -d "$dest/.git" ]]; then
    echo "[repo] updating $name ($branch)"
    git -C "$dest" fetch --prune origin "$branch"
    git -C "$dest" checkout "$branch"
    git -C "$dest" merge --ff-only "origin/$branch"
  else
    echo "[repo] cloning $name ($branch)"
    git clone --branch "$branch" --single-branch "$url" "$dest"
  fi
}

clone_or_update "Azazel-Edge" "$EDGE_BRANCH" "$GIT_BASE/Azazel-Edge.git"
clone_or_update "Azazel-Knowledge" "main" "$GIT_BASE/Azazel-Knowledge.git"
clone_or_update "Azazel-Deception" "main" "$GIT_BASE/Azazel-Deception.git"

EDGE="$REPOS/Azazel-Edge"
KNOW="$REPOS/Azazel-Knowledge"
DECEPTION="$REPOS/Azazel-Deception"

make_venv() {
  local repo="$1"
  if [[ ! -d "$repo/.venv" ]]; then
    python3 -m venv "$repo/.venv"
  fi
  "$repo/.venv/bin/python" -m pip install --upgrade pip setuptools wheel
}

make_venv "$EDGE"
"$EDGE/.venv/bin/pip" install -r "$EDGE/requirements/dev.txt"

make_venv "$KNOW"
(
  cd "$KNOW"
  .venv/bin/pip install -e '.[api,dev]'
)

make_venv "$DECEPTION"
(
  cd "$DECEPTION"
  .venv/bin/pip install -e '.[dev]'
)

KNOW_STATE="$STATE/knowledge"
mkdir -p "$KNOW_STATE"
if [[ ! -f "$KNOW_STATE/data/db/local.db" ]]; then
  echo "[knowledge] provisioning isolated development state"
  provision_log="$LOGS/knowledge-provision.log"
  (
    cd "$KNOW"
    AZAZEL_ROOT="$KNOW_STATE" AZAZEL_CONFIG_DIR="$KNOW/config" .venv/bin/python ./azctl provision
  ) | tee "$provision_log"
  chmod 600 "$provision_log"
fi

# Reuse secrets across reruns. They live outside all Git repositories.
if [[ -f "$RUNTIME_ENV" ]]; then
  # shellcheck disable=SC1090
  source "$RUNTIME_ENV"
fi

if [[ -z "${AZAZEL_KNOWLEDGE_TOKEN:-}" ]]; then
  echo "[knowledge] minting a scoped Edge development token (ingest,query,read)"
  client_out="$(cd "$KNOW" && AZAZEL_ROOT="$KNOW_STATE" AZAZEL_CONFIG_DIR="$KNOW/config" .venv/bin/python ./azctl client add --scopes ingest,query,read)"
  AZAZEL_KNOWLEDGE_TOKEN="$(printf '%s\n' "$client_out" | sed -n 's/^token (shown once): //p' | tail -n 1)"
  [[ -n "$AZAZEL_KNOWLEDGE_TOKEN" ]] || { echo "failed to extract Knowledge dev token" >&2; exit 2; }
fi

AZAZEL_EDGE_ID="${AZAZEL_EDGE_ID:-edge-m5pro-dev}"
AZAZEL_DECEPTION_NODE_ID="${AZAZEL_DECEPTION_NODE_ID:-az06-m5pro-shadow}"
if [[ -z "${AZAZEL_DECEPTION_HMAC_KEY:-}" ]]; then
  AZAZEL_DECEPTION_HMAC_KEY="$(python3 - <<'PY'
import secrets
print(secrets.token_hex(32))
PY
)"
fi
AZAZEL_KNOWLEDGE_PORT="${AZAZEL_KNOWLEDGE_PORT:-8070}"
AZAZEL_DECEPTION_PORT="${AZAZEL_DECEPTION_PORT:-8071}"
AZAZEL_OLLAMA_ENDPOINT="${AZAZEL_OLLAMA_ENDPOINT:-http://127.0.0.1:11434}"

{
  printf 'AZAZEL_LAB_ROOT=%q\n' "$LAB_ROOT"
  printf 'AZAZEL_EDGE_ID=%q\n' "$AZAZEL_EDGE_ID"
  printf 'AZAZEL_DECEPTION_NODE_ID=%q\n' "$AZAZEL_DECEPTION_NODE_ID"
  printf 'AZAZEL_DECEPTION_HMAC_KEY=%q\n' "$AZAZEL_DECEPTION_HMAC_KEY"
  printf 'AZAZEL_KNOWLEDGE_TOKEN=%q\n' "$AZAZEL_KNOWLEDGE_TOKEN"
  printf 'AZAZEL_KNOWLEDGE_PORT=%q\n' "$AZAZEL_KNOWLEDGE_PORT"
  printf 'AZAZEL_DECEPTION_PORT=%q\n' "$AZAZEL_DECEPTION_PORT"
  printf 'AZAZEL_OLLAMA_ENDPOINT=%q\n' "$AZAZEL_OLLAMA_ENDPOINT"
} > "$RUNTIME_ENV"
chmod 600 "$RUNTIME_ENV"

echo "[test] Azazel-Edge M.I.O. shadow suite"
(
  cd "$EDGE"
  PYTHONPATH="$EDGE/py" .venv/bin/python -m pytest -q \
    tests/test_mio_cognitive_shadow_core.py \
    tests/test_mio_shadow_runtime_integration.py \
    tests/test_mio_frame_builder_with_evaluators.py \
    tests/test_mio_adversarial_schema.py
)

if [[ "${AZAZEL_FULL_TESTS:-0}" == "1" ]]; then
  echo "[test] Azazel-Knowledge full suite"
  (cd "$KNOW" && .venv/bin/python -m pytest -q)
  echo "[test] Azazel-Deception full suite"
  (cd "$DECEPTION" && .venv/bin/python -m pytest -q)
else
  echo "[test] full Knowledge/Deception suites skipped (set AZAZEL_FULL_TESTS=1 to run them)"
fi

if [[ "${AZAZEL_PULL_MODELS:-0}" == "1" ]]; then
  command -v ollama >/dev/null 2>&1 || { echo "AZAZEL_PULL_MODELS=1 but ollama is not installed" >&2; exit 2; }
  echo "[model] pulling qwen3.5:2b and qwen3.5:0.8b"
  ollama pull qwen3.5:2b
  ollama pull qwen3.5:0.8b
fi

cat <<EOF

Bootstrap complete.
Lab root:     $LAB_ROOT
Repos:        $REPOS
State:        $STATE
Runtime env:  $RUNTIME_ENV (mode 600)

No Azazel-Edge installer, systemd unit, nftables/iptables/tc handler, or live Deception activation was enabled.
Next: run dev/macbook-m5pro/start-shadow-lab.sh
EOF
