#!/usr/bin/env bash
# Launches Scrapling's MCP server (local stdio only). Install it first with
# scripts/bootstrap-tools.sh, which pins scrapling[ai]==0.4.15.
export PATH="$HOME/.local/bin:$PATH"
if ! command -v scrapling >/dev/null 2>&1; then
  echo "scrapling not installed — run: bash scripts/bootstrap-tools.sh" >&2
  exit 1
fi
exec scrapling mcp "$@"
