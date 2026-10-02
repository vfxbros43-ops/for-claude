# Installed tools

All reviewed on 2026-10-02 and pinned to that commit.

| Tool | Upstream (pinned) | How it's installed here | What it does |
|---|---|---|---|
| **watch** | [bradautomates/claude-video](https://github.com/bradautomates/claude-video) `03ceb42` (v0.3.2, MIT) | Vendored in `.claude/skills/watch/` | `/watch <url or file>`: downloads with yt-dlp, scene-aware frames with ffmpeg, captions/transcript, so Claude can look at a video frame by frame |
| **agent-reach** | [Panniantong/Agent-Reach](https://github.com/Panniantong/Agent-Reach) `a19a171` (v1.5.0, MIT) | Skill vendored in `.claude/skills/agent-reach/` (English, patched); CLI via `scripts/bootstrap-tools.sh` | Read/search web pages, YouTube subtitles, RSS, GitHub, Twitter/Reddit/etc. (some need cookies) |
| **chrome-devtools** | [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) `b2f522c` (v1.10.1, Apache-2.0) | MCP server in `.mcp.json` → `scripts/chrome-devtools-mcp.sh`; 7 skills vendored in `.claude/skills/` | Control and debug a real Chrome: navigate, click, screenshots, console, network, performance, memory, a11y |
| **gstack** | [garrytan/gstack](https://github.com/garrytan/gstack) `7fca42a` (v1.91.12, MIT) | `scripts/bootstrap-tools.sh` → `~/.claude/skills/gstack` | 50 `gstack-*` workflow skills (office hours, plan reviews, QA, ship, retro, investigate, design review, …) |
| **screenshot-to-code** | [abi/screenshot-to-code](https://github.com/abi/screenshot-to-code) `d026163` (MIT) | `scripts/screenshot-to-code.sh setup` / `start` → `tools/` (gitignored) | Web app at http://127.0.0.1:5173: screenshot/mockup/recording → HTML/React/Vue code |

## Overlap fixes applied

- gstack installed with `--prefix`, so every skill is `gstack-*` and none collides with built-ins (`/review` → `/gstack-review`).
- Removed gstack skills that duplicate other tools or touch real browser cookies: `gstack-browse`, `gstack-open-gstack-browser`, `gstack-connect-chrome`, `gstack-scrape`, `gstack-skillify`, `gstack-setup-browser-cookies`, `gstack-pair-agent`. (gstack's own `/qa` etc. still use its internal browser binary.)
- Chrome DevTools' generic `troubleshooting` skill renamed to `chrome-devtools-troubleshooting`.
- agent-reach skill: told to hand video *watching* to `watch` and browser work to chrome-devtools; removed its instruction to fetch install/update docs from a remote URL at run time.
- yt-dlp is shared by watch and agent-reach (one install).
- Routing table in `CLAUDE.md`.

## Safety settings applied

- watch: `WATCH_ENGINE=local` in `~/.config/watch/.env` (no upload to Google).
- chrome-devtools-mcp: `--no-usage-statistics --no-performance-crux --isolated` (+ `--headless` in the cloud).
- gstack: telemetry `off`, `--no-team` (no auto-update hook), no plan-tune or timeline hooks; nothing written to `~/.claude/settings.json`.
- agent-reach: no `--system` install, no cookies configured.
- screenshot-to-code: backend and frontend bound to `127.0.0.1`; keys in a `chmod 600` `.env` that is gitignored.

## Setup

**Cloud sessions:** add the SessionStart hook below to `.claude/settings.json` so new containers install everything in the background (about 1 minute). Alternatively, put `bash scripts/bootstrap-tools.sh` in the cloud environment's setup script.

```json
{
  "hooks": {
    "SessionStart": [
      { "matcher": "startup",
        "hooks": [ { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/session-start.sh\"", "timeout": 10 } ] }
    ]
  }
}
```

**Your own computer:** clone this repo, then run once: `bash scripts/bootstrap-tools.sh` (needs git, node, python3, ffmpeg). The hook never installs anything on a local machine by itself.

**Network:** the cloud environment must allow `youtube.com` / `googlevideo.com` (and Instagram, TikTok, etc.) for `/watch`, and `mcp.exa.ai` for agent-reach web search.
