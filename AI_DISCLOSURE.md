# AI Disclosure

Collab Mesh is an AI project, and AI tools were used in its development. This document discloses both how AI powers the product at runtime and how AI assisted during development.

## Runtime AI (the product itself)

Collab Mesh is, by design, an AI agent. At runtime it relies on:

- **Model:** Google Gemini 2.5 Flash, accessed via the Google AI Studio API.
- **Agent runtime:** OpenClaw's bundled "Pi" agent. Pi reads `SOUL.md` and the `SKILL.md` files at session start and decides, on each Discord message, which OpenClaw tools to invoke.
- **What the AI does at runtime:** parses messages prefixed with `decision:` and `task:`, picks task assignees from `members.json` based on a skills match, writes entries to `decisions.md` and `tasks.md` via OpenClaw's `memory` tool, sends DMs and channel replies via OpenClaw's `message` tool, and generates 4-line standup summaries when the cron job fires.
- **What the AI does NOT do at runtime:** it does not access user accounts beyond the configured Discord bot, does not call any external services other than the Gemini API and Discord, and does not retain conversation history beyond what is explicitly stored in the workspace markdown files.

## Development-time AI assistance

Development used **Anthropic's Claude** (via the Claude Code interface) as a pair programmer. Claude was used to:

- **Co-author the three `SKILL.md` files** — the trigger logic, format specs, edge cases, and worked examples were drafted by Claude based on the original three-feature brief, then iterated on with the developer.
- **Co-author `SOUL.md`** — voice and identity drafted in collaboration; the developer made the final voice choice and edited the team name.
- **Co-author `scripts/install.ps1`** — initial PowerShell draft by Claude; run and debugged by the developer on a Windows 11 machine.
- **Co-author `README.md` and this `AI_DISCLOSURE.md`** — drafted by Claude, reviewed by the developer.
- **Debug runtime issues** — including a multi-hour spiral involving Discord token auto-revocation, Gemini free-tier quota limits, OpenClaw config schema quirks, Windows PowerShell native-arg quoting bugs, and OpenClaw cron registration. Claude analyzed logs and proposed fixes; the developer executed every command and verified every outcome.

## What was human-authored

- **All architectural decisions** — choosing the skills-only approach over building a custom runtime, deciding to reuse 100% of OpenClaw's primitives, scope-guarding against features outside the original three (e.g. task deadlines were proposed and explicitly deferred to a future version).
- **All testing and verification** — every Discord message sent during development, every config change applied, every gateway restart, every cron registration. Claude has no access to the developer's machine, Discord account, Google account, or GitHub credentials.
- **Project framing and scope** — the three-feature brief, the team name, the "skills-only contribution to OpenClaw" framing, and the deliverable shape (5 markdown/JSON files plus a deploy script) all originated with the developer.
- **All commits and pushes** — every git operation was executed manually by the developer.

## AI tools used

| Tool | Role | Where it appears in the repo |
| --- | --- | --- |
| Google Gemini 2.5 Flash | Runtime LLM that powers the agent | Configured in OpenClaw; invoked on every Discord interaction and every cron-triggered standup |
| Anthropic Claude (via Claude Code) | Pair-programming assistance | All file authoring and debugging; not present at runtime |
| OpenClaw 2026.5.6 | Agent framework (Pi runtime, tools, channel adapters) | The entire runtime substrate; this project adds only the SKILL.md/SOUL.md/members.json layer on top |

## Honest summary

This is a project an individual developer (Sai) built **with** AI, not **by** AI. The product is an AI agent. Development was assisted by Claude as a pair programmer. Every architectural decision, every behavior that ships, and every test was reviewed or executed by the developer. The final responsibility for everything in this repository — design, scope, correctness, and the demo — rests with the human author.

## Submitted for

Samsung PRISM × OpenClaw Hackathon, May 2026.
