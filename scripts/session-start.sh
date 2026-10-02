#!/usr/bin/env bash
# SessionStart hook. Only auto-installs in Claude Code cloud sessions; on your
# own machine it never installs anything — run scripts/bootstrap-tools.sh yourself.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi
DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.cache"
nohup bash "$DIR/bootstrap-tools.sh" > "$HOME/.cache/bootstrap-tools.log" 2>&1 &
echo "Installing gstack, Agent-Reach and /watch dependencies in the background (log: ~/.cache/bootstrap-tools.log)."
exit 0
