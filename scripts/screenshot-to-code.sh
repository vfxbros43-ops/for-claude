#!/usr/bin/env bash
# screenshot-to-code is a standalone web app (not a Claude skill). This script
# fetches the reviewed commit and runs it bound to localhost only.
#
#   bash scripts/screenshot-to-code.sh setup   # clone + install deps (once)
#   bash scripts/screenshot-to-code.sh start   # backend :7001 + frontend :5173
#
# API keys go in tools/screenshot-to-code/backend/.env (never committed), e.g.
#   ANTHROPIC_API_KEY=...   GEMINI_API_KEY=...   OPENAI_API_KEY=...   REPLICATE_API_KEY=...
# At least one of Anthropic / Gemini / OpenAI is required.
set -euo pipefail

REF="d026163f586dfa8c5c10d28c36edd59a9d3b0e88"   # abi/screenshot-to-code, reviewed 2026-10-02
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/tools/screenshot-to-code"

setup() {
  if [ ! -d "$APP/.git" ]; then
    git clone -q https://github.com/abi/screenshot-to-code.git "$APP"
  fi
  git -C "$APP" fetch -q origin "$REF" 2>/dev/null || true
  git -C "$APP" checkout -q "$REF"
  command -v poetry >/dev/null || python3 -m pip install --user -q poetry
  command -v pnpm   >/dev/null || npm install -g -s pnpm@10
  (cd "$APP/backend" && poetry install --no-interaction)
  (cd "$APP/frontend" && pnpm install)
  touch "$APP/backend/.env"; chmod 600 "$APP/backend/.env"
  echo "Setup done. Add your API key(s) to $APP/backend/.env, then run: bash scripts/screenshot-to-code.sh start"
}

start() {
  [ -d "$APP/backend" ] || { echo "Run setup first."; exit 1; }
  (cd "$APP/backend" && poetry run uvicorn main:app --host 127.0.0.1 --port 7001) &
  BACK=$!
  trap 'kill $BACK 2>/dev/null' EXIT
  cd "$APP/frontend" && pnpm dev --host 127.0.0.1
}

case "${1:-}" in
  setup) setup ;;
  start) start ;;
  *) sed -n 2,10p "$0"; exit 1 ;;
esac
