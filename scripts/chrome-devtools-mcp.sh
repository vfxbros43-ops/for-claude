#!/usr/bin/env bash
# Launches the Chrome DevTools MCP server with privacy-safe defaults:
#   --no-usage-statistics   : don't send usage stats to Google
#   --no-performance-crux   : don't send traced URLs to the CrUX API
#   --isolated              : throwaway profile, never your real Chrome profile
# In the cloud container (no Chrome installed) it headlessly uses Playwright's Chromium.
set -euo pipefail

ARGS=(--no-usage-statistics --no-performance-crux --isolated)

if [ "${CLAUDE_CODE_REMOTE:-}" = "true" ]; then
  ARGS+=(--headless)
  if [ -x /opt/pw-browsers/chromium ]; then
    ARGS+=(--executablePath /opt/pw-browsers/chromium --chromeArg=--no-sandbox)
  fi
fi

exec npx -y chrome-devtools-mcp@1.10.1 "${ARGS[@]}" "$@"
