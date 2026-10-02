#!/usr/bin/env bash
# Installs the heavy, non-vendored parts of this repo's toolset. Idempotent.
#
#   Cloud sessions: runs automatically (in the background) from the SessionStart
#                   hook in .claude/settings.json.
#   Your own machine: run it once yourself:  bash scripts/bootstrap-tools.sh
#
# Everything is pinned to the commits/versions that were safety-reviewed
# (see TOOLS.md). Bump the pins deliberately, after re-reviewing.
set -uo pipefail

AGENT_REACH_REF="a19a171fa980a0785849596492e0af4db800c82f"   # Panniantong/Agent-Reach v1.5.0
GSTACK_REF="7fca42ad8b6c707b8a38f579f72bf3c4f7de6d85"        # garrytan/gstack v1.91.12
MCPORTER_VERSION="0.14.2"
SCRAPLING_VERSION="0.4.15"                                     # D4Vinci/Scrapling tag v0.4.15 = 333fa22

# gstack skills that duplicate Chrome DevTools MCP (browser control) or
# Agent-Reach (scraping), or that import real browser cookies. Removed after setup.
GSTACK_PRUNE=(gstack-browse gstack-open-gstack-browser gstack-connect-chrome
              gstack-scrape gstack-skillify gstack-setup-browser-cookies gstack-pair-agent)

export PATH="$HOME/.local/bin:$PATH"
log() { printf '[bootstrap-tools] %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- prerequisites -----------------------------------------------------------
for bin in git node npm python3; do
  have "$bin" || { log "missing required tool: $bin — install it and re-run"; exit 1; }
done
if ! have uv; then
  log "installing uv (Python tool installer)"
  python3 -m pip install --user -q uv || { log "could not install uv"; exit 1; }
fi
have ffmpeg || log "WARNING: ffmpeg missing — /watch needs it (macOS: brew install ffmpeg, Ubuntu: sudo apt install ffmpeg)"

# --- yt-dlp (used by /watch and Agent-Reach) ---------------------------------
have yt-dlp || { log "installing yt-dlp"; uv tool install -q "yt-dlp[default,curl-cffi]"; }
mkdir -p "$HOME/.config/yt-dlp"
grep -qxF -- '--js-runtimes node' "$HOME/.config/yt-dlp/config" 2>/dev/null \
  || echo '--js-runtimes node' >> "$HOME/.config/yt-dlp/config"

# --- /watch: local engine (Claude sees the frames; nothing uploaded to Google) -
mkdir -p "$HOME/.config/watch"
grep -q '^WATCH_ENGINE=' "$HOME/.config/watch/.env" 2>/dev/null \
  || echo 'WATCH_ENGINE=local' >> "$HOME/.config/watch/.env"
chmod 600 "$HOME/.config/watch/.env"

# --- Agent-Reach CLI (no --system, no cookies) ----------------------------------
if ! have agent-reach; then
  log "installing agent-reach @ ${AGENT_REACH_REF:0:7}"
  uv tool install -q "agent-reach @ git+https://github.com/Panniantong/Agent-Reach@${AGENT_REACH_REF}"
fi
# Exa web search (free, no key) via mcporter, as Agent-Reach documents.
if ! have mcporter; then
  log "installing mcporter@${MCPORTER_VERSION}"
  npm install -g -s "mcporter@${MCPORTER_VERSION}" || log "mcporter install failed (web search channel stays off)"
fi
if have mcporter && ! mcporter config list 2>/dev/null | grep -q exa; then
  mcporter config add exa https://mcp.exa.ai/mcp --scope home >/dev/null 2>&1 || true
fi

# --- Scrapling (scraper + MCP server; no telemetry) ---------------------------
if ! have scrapling; then
  log "installing scrapling==${SCRAPLING_VERSION}"
  uv tool install -q "scrapling[ai]==${SCRAPLING_VERSION}"
  # Downloads the browsers used by its stealth/dynamic fetchers. Blocked in
  # restricted cloud networks; the plain HTTP fetcher still works without it.
  scrapling install >/dev/null 2>&1 || log "scrapling browser download failed (HTTP fetcher still works)"
fi

# --- gstack (prefixed skill names, no hooks, telemetry off) -------------------
GSTACK_DIR="$HOME/.claude/skills/gstack"
if [ ! -x "$GSTACK_DIR/setup" ] || [ "$(git -C "$GSTACK_DIR" rev-parse HEAD 2>/dev/null)" != "$GSTACK_REF" ]; then
  log "installing gstack @ ${GSTACK_REF:0:7}"
  rm -rf "$GSTACK_DIR"
  git clone -q --depth 50 https://github.com/garrytan/gstack.git "$GSTACK_DIR" \
    && git -C "$GSTACK_DIR" checkout -q "$GSTACK_REF" \
    && (cd "$GSTACK_DIR" && ./setup --host claude --prefix --no-team \
          --no-plan-tune-hooks --no-timeline-stop-hook </dev/null >/dev/null 2>&1) \
    || log "gstack setup failed — see: cd $GSTACK_DIR && ./setup --host claude --prefix"
fi
if [ -x "$GSTACK_DIR/bin/gstack-config" ]; then
  "$GSTACK_DIR/bin/gstack-config" set telemetry off >/dev/null 2>&1 || true
  for s in "${GSTACK_PRUNE[@]}"; do rm -rf "$HOME/.claude/skills/$s"; done
fi

log "done. yt-dlp=$(yt-dlp --version 2>/dev/null) agent-reach=$(have agent-reach && echo ok) gstack=$(cat "$GSTACK_DIR/VERSION" 2>/dev/null)"
