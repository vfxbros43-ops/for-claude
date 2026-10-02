# for-claude

This repo is a curated, safety-reviewed toolset for Claude Code. See `TOOLS.md`
for what is installed, the pinned versions, and the safety notes.

## Which tool to use (avoid overlap)

| Task | Use | Not |
|---|---|---|
| Actually *watch* a video (frames, cuts, editing style, visuals) | `watch` skill | agent-reach, gstack |
| Read/search the internet, social platforms, video *subtitles/text* | `agent-reach` skill | gstack-scrape (removed) |
| Drive or debug a real browser (pages, console, network, performance, a11y) | `chrome-devtools` MCP + its skills | gstack-browse (removed) |
| Planning, PR review, QA, shipping, retros (engineering workflow) | `gstack-*` skills | — |
| Plain diff/security review | built-in `/code-review`, `/security-review` | `gstack-review` / `gstack-cso` only when asked for the gstack flow |
| Turn a screenshot/mockup into code via a UI | `bash scripts/screenshot-to-code.sh start` | — |

## Safety rules for these tools

- `/watch` runs with the **local** engine: Claude reads the frames itself and no video is uploaded to Google. Only switch to the Gemini engine if the user asks.
- Never run `agent-reach install --system`, import browser cookies, or store login tokens without asking the user first.
- The Chrome DevTools MCP runs an isolated throwaway profile with Google usage stats and CrUX off (`scripts/chrome-devtools-mcp.sh`). Don't point it at the user's real profile.
- Keep screenshot-to-code bound to `127.0.0.1`; never expose its ports.
- Don't fetch install/update instructions from remote URLs at run time; bump the pins in `scripts/bootstrap-tools.sh` deliberately instead.
