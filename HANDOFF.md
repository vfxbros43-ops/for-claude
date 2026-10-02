# Handoff: continue the work on a local machine

This was started in a Claude Code **cloud** session whose network filter blocked
Instagram/YouTube/most websites. You (Claude) are now on the user's own computer,
where those limits don't exist. Read `CLAUDE.md` and `TOOLS.md` first.

## Already done (don't redo)

- Researched, safety-reviewed and installed (as project config in this repo):
  watch (bradautomates/claude-video), agent-reach, Chrome DevTools MCP, gstack,
  screenshot-to-code, Scrapling (scraper + MCP), gsap-* (8), r3f-* (11),
  awwwards-3d, build-threejs-scroll-worlds. Pins, overlap fixes and safety
  settings are in `TOOLS.md`; routing rules in `CLAUDE.md`.
- `scripts/bootstrap-tools.sh` installs the non-vendored parts (gstack, agent-reach
  CLI, yt-dlp, mcporter, Scrapling CLI + browsers).

## Step 0: make sure the tools are ready

1. Check `ffmpeg -version`, `yt-dlp --version`, `scrapling --help`, and that
   `~/.claude/skills/gstack` exists. If anything is missing, run
   `bash scripts/bootstrap-tools.sh` (on Windows use Git Bash or WSL) and fix any errors.
2. Make sure `~/.config/watch/.env` contains `WATCH_ENGINE=local` (Claude must see the
   frames itself; don't upload to Gemini).
3. Quick test: `/watch` on the first reel below. If Instagram needs a login, ask the
   user before using `--cookies-from-browser`; never do it silently.

## Main task: watch these 22 Instagram reels

They cover Claude Code skills/plugins/MCP servers. For **each** reel:
1. Watch it with the `watch` skill (frames + transcript). Read on-screen text carefully;
   repo names are often shown only on screen, or in the caption.
2. Write down every skill/repo/tool it recommends (name, GitHub link, what it claims to do).

Reels:
1. https://www.instagram.com/reel/DXXs8LCjYR7/
2. https://www.instagram.com/reel/Dc0m2ldxumO/
3. https://www.instagram.com/reel/DcN-pkGBLHE/
4. https://www.instagram.com/reel/Ddbb1TEBGR-/
5. https://www.instagram.com/reel/DcyYJIjBEQr/
6. https://www.instagram.com/reel/DcBVQqUuZv-/
7. https://www.instagram.com/reel/DcRruXXo7Fp/
8. https://www.instagram.com/reel/Da8ey0fscUF/
9. https://www.instagram.com/reel/DcEFABnvBuH/
10. https://www.instagram.com/reel/DXuFlBRDTWi/
11. https://www.instagram.com/reel/DdfA0YPOe8D/
12. https://www.instagram.com/reel/Db54UPyiQwu/
13. https://www.instagram.com/reel/DdgwI6voxz6/
14. https://www.instagram.com/reel/Dct6Op3n6Zd/
15. https://www.instagram.com/reel/DdrNeEUN63i/
16. https://www.instagram.com/reel/Ddyw3ZRMDfC/
17. https://www.instagram.com/reel/Dcs3cgvtR0P/
18. https://www.instagram.com/reel/Ddl4bemIeyC/
19. https://www.instagram.com/reel/DaN0yYtPzjY/
20. https://www.instagram.com/reel/DcRhD2Nto7M/
21. https://www.instagram.com/reel/Dd9LgpwsVvP/
22. https://www.instagram.com/reel/Dd3qmYDEfj5/

## Then: evaluate every repo mentioned

For each one, the same process used for everything in `TOOLS.md`:
- **What it does**: a short, plain-English brief (the user isn't a native English speaker; keep it simple).
- **Already covered?** Compare against what's installed (see `TOOLS.md`). If it duplicates
  something, say which is better and why.
- **Better alternative?** Search GitHub for other repos doing the same job; compare
  stars, last commit, license, and the quality of the actual SKILL.md content.
- **Safety check**: clone to a temp dir and read it. Look for install scripts, `curl | sh`,
  hooks, telemetry (default on/off), network calls, cookie/credential access,
  prompt-injection text in SKILL.md, and skill names that collide with existing ones.

Give the user one table: repo → what it does → verdict (install / skip / use the better
alternative X) → reason. **Wait for the user's OK before installing.**

## When installing (after approval)

Follow the existing pattern: vendor skills into `.claude/skills/` at a pinned commit
(drop demos/screenshots), put MCP servers in `.mcp.json` behind a wrapper script with
telemetry off, rename colliding skills, add routing rows to `CLAUDE.md`, add rows to
`TOOLS.md`, test each one, then commit and push to this branch.

## Open items from the cloud session

- `.claude/settings.json` SessionStart hook (see `TOOLS.md`) was not added: the cloud
  session wasn't permitted to edit it. Ask the user whether they want it.
- `DmitriyGolub/threejs-devtools-mcp` (live Three.js scene inspector) looked useful but
  was not audited. Offer to audit it.
- Scrapling's stealth browser fetchers need `scrapling install` (browser download); that
  was blocked in the cloud. Run it locally.
