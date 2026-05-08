# Collab Mesh

A shared AI teammate that lives in a Discord server and helps a small project team coordinate. Built as a skills-only contribution on top of [OpenClaw](https://github.com/openclaw/openclaw) for the Samsung PRISM Hackathon.

The Synapse team's working coordinator: it logs decisions, routes tasks, and posts a daily standup. without any new app to install.

## What it does

Three jobs, all triggered from your existing Discord channels:

- **Decision logging** — type `decision: <text>` in a team channel; the agent appends it to `decisions.md` with timestamp + author and confirms in one line.
- **Task routing** — type `task: <text>`; the agent reads `members.json`, picks the best-matching assignee by their listed skills, DMs them the task, and logs it to `tasks.md`.
- **Async standup** — every weekday at 09:00, the agent posts a 4-line summary of the previous 24 hours' decisions and tasks to the standup channel.

## Architecture

Collab Mesh is a **skills-only** build. The whole repo is markdown and JSON —> no custom runtime, no Discord client code, no provider SDK calls:

```
Discord ↔ OpenClaw extensions/discord ↔ Gateway ↔ Pi agent ↔ Collab Mesh skills
                                                         └── memory / message / cron tools
```

OpenClaw's gateway provides the Discord adapter, the Pi agent runtime, the `message` tool (channel posts + DMs), the `memory` tool (markdown reads/writes), and the `cron` primitive that fires the standup. Collab Mesh reuses all of it and adds:

| Path | Purpose |
| --- | --- |
| `SOUL.md` | Agent identity & voice (terse project-coordinator) |
| `skills/decision-log/SKILL.md` | Trigger + steps for the `decision:` flow |
| `skills/task-routing/SKILL.md` | Trigger + steps for the `task:` flow + assignee pick |
| `skills/async-standup/SKILL.md` | Steps for the cron-driven 4-line summary |
| `members.json` | Team roster: `name`, `discordId`, `skills[]` |
| `scripts/install.ps1` | Deploys SOUL + skills + members.json into `~/.openclaw/workspace/` |

## Install (~10 minutes)

Prerequisites:
- Node.js 24 LTS (or 22.16+)
- A Discord application with a bot, **Message Content Intent** enabled, and the bot invited to your server with `bot` + `applications.commands` scopes
- A Gemini API key from [Google AI Studio](https://aistudio.google.com/apikey)

Windows PowerShell:

```powershell
# 1. Install OpenClaw globally
npm install -g openclaw@latest

# 2. Provide secrets via OpenClaw's canonical .env file (NOT in repo)
@'
GEMINI_API_KEY=your-gemini-key
DISCORD_BOT_TOKEN=your-discord-bot-token
'@ | Set-Content -Path "$HOME\.openclaw\.env" -Encoding UTF8

# 3. Onboard with Gemini
openclaw onboard --auth-choice gemini-api-key

# 4. Clone and deploy
git clone https://github.com/sgpfhgg/Synapse.git collab-mesh
cd collab-mesh
.\scripts\install.ps1

# 5. Schedule the daily standup (replace channel ID)
openclaw cron add --name "synapse-standup" `
  --cron "0 9 * * 1-5" --tz "Asia/Kolkata" --session isolated `
  --message "Run the async-standup skill for channel <YOUR_STANDUP_CHANNEL_ID>."

# 6. Restart the gateway so everything loads
openclaw gateway restart
```

## Configure

- **Discord allowlist** — in `~/.openclaw/openclaw.json` set `channels.discord.guilds.<guildId>.users` to your Discord user ID, and `channels.discord.guilds.<guildId>.requireMention: false` so `decision:` / `task:` fire without `@mention`.
- **Team members** — edit `members.json`. Each entry needs `name`, `discordId`, and a `skills` array. Agent picks the assignee by reading these.
- **Standup channel** — currently the channel ID is referenced in `skills/async-standup/SKILL.md`. Edit there if you want a dedicated `#standup` channel.

## Demo flow

Video Demo link:
https://www.youtube.com/watch?v=ZD-X9JaGYrc

In a team channel:

1. `decision: ship the auth migration on Friday` → bot replies `Logged decision #1 — alice.`
2. `task: build a redis cache layer for the API` → bot DMs the matching assignee and replies `Routed task #1 to @Alex.`
3. Tomorrow at 09:00 IST, the standup channel gets a 4-line auto-posted summary.

## Status

**v1, hackathon timeframe.** Tested end-to-end on `gemini-2.5-flash` with `agents.defaults.thinkingDefault: off`. The free-tier daily limit on `2.5-flash` is 20 requests which is fine for a demo, tight for development iteration. Recommended: enable billing on your Google Cloud project for headroom.

Known limitations:
- The sample `members.json` uses a single Discord ID for all three members so a solo developer can demo routing reliably. Replace with real teammate IDs to actually fan out DMs.
- `decisions.md` and `tasks.md` live in the local OpenClaw workspace, not synced anywhere. For multi-machine teams, point the workspace at shared storage.
- Smaller models (`gemini-2.5-flash-lite`, etc.) struggle to follow the strict `[N] YYYY-MM-DD UTC` format in the entry templates. Use `gemini-2.5-flash` or stronger.

## Built for

Samsung PRISM × OpenClaw Hackathon, May 2026.

