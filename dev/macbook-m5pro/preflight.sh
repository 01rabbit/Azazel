#!/usr/bin/env bash
set -euo pipefail

fail() { echo "[FAIL] $*" >&2; exit 2; }
warn() { echo "[WARN] $*" >&2; }
ok() { echo "[ OK ] $*"; }

[[ "$(uname -s)" == "Darwin" ]] || fail "macOS is required"
[[ "$(uname -m)" == "arm64" ]] || fail "Apple Silicon arm64 is required (detected: $(uname -m))"

command -v git >/dev/null 2>&1 || fail "git is required"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"

python3 - <<'PY'
import sys
if sys.version_info < (3, 11):
    raise SystemExit(f"Python >=3.11 is required for the combined lab; found {sys.version.split()[0]}")
print(f"[ OK ] Python {sys.version.split()[0]}")
PY

if xcode-select -p >/dev/null 2>&1; then
  ok "Xcode Command Line Tools: $(xcode-select -p)"
else
  fail "Xcode Command Line Tools are required (run: xcode-select --install)"
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    docker compose version >/dev/null 2>&1 || fail "docker compose plugin is required"
    ok "Docker runtime reachable"
  else
    warn "Docker CLI exists but daemon is not reachable; start Docker Desktop/Colima before Deception tests"
  fi
else
  warn "Docker is not installed; M.I.O./Knowledge tests work, Deception compose tests will not"
fi

if command -v ollama >/dev/null 2>&1; then
  ok "Ollama CLI found: $(command -v ollama)"
  if curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    ok "Ollama API reachable on loopback"
  else
    warn "Ollama is installed but API is not reachable; run: ollama serve"
  fi
else
  warn "Ollama is not installed; deterministic/replay tests work, live 0.8B/2B inference will not"
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    ok "GitHub CLI authentication available"
  else
    warn "gh exists but is not authenticated; private Azazel-Knowledge clone/install may fail"
  fi
else
  warn "GitHub CLI is not installed; ensure git HTTPS/SSH credentials can access private Azazel-Knowledge"
fi

mem_bytes="$(sysctl -n hw.memsize 2>/dev/null || echo 0)"
if [[ "$mem_bytes" =~ ^[0-9]+$ ]] && (( mem_bytes > 0 )); then
  mem_gb=$(( mem_bytes / 1024 / 1024 / 1024 ))
  ok "System memory: ${mem_gb} GiB"
fi

free_kb="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
if [[ "$free_kb" =~ ^[0-9]+$ ]]; then
  free_gb=$(( free_kb / 1024 / 1024 ))
  (( free_gb >= 20 )) || warn "Less than 20 GiB free under HOME (${free_gb} GiB); model images and Docker layers may be tight"
  ok "Free space under HOME: ${free_gb} GiB"
fi

cat <<'EOF'

MacBook M5 Pro lab preflight complete.
Nothing was installed and no enforcement/network-control path was enabled.
EOF
