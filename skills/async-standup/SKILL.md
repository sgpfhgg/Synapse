---
name: async-standup
description: Post a 4-line daily standup summary of last 24h decisions and tasks to the team's standup channel. Triggered by cron at 9am weekdays.
metadata: { "openclaw": { "emoji": "☀️" } }
allowed-tools: ["memory", "message"]
---

# Async Standup

Generate a daily standup summary for the Synapse team. Third of the three core jobs Collab Mesh performs.

**Trigger:** scheduled cron job invoking this skill (not user messages). The cron prompt typically asks for "the standup summary" or names this skill explicitly.

## Steps

1. Read `decisions.md` from workspace root. Treat missing as empty.
2. Read `tasks.md` from workspace root. Treat missing as empty.
3. Filter both to entries with UTC timestamps in the last 24 hours.
4. Compose **exactly 4 lines** in this shape:
   ```
   Standup — <YYYY-MM-DD local date>
   Decisions (<n> last 24h): <comma-separated short titles, or "none">
   Tasks (<n> last 24h): <comma-separated "@assignee: short title", or "none">
   Open: <one-line note on blockers, or "no blockers logged">
   ```
5. Post via the `message` tool to the standup channel:
   ```json
   {"action":"send","channel":"discord","to":"channel:1501973341605466194","message":"<four-line summary>"}
   ```

## Worked example

`decisions.md` last 24h has 2 entries: "rename project to Collab Mesh", "ship auth migration Friday".
`tasks.md` last 24h has 1 entry: "@Alex: build redis cache layer".

Output posted to the channel (and only this — no extra commentary):
```
Standup — 2026-05-09
Decisions (2 last 24h): rename project to Collab Mesh, ship auth migration Friday
Tasks (1 last 24h): @Alex: build redis cache layer
Open: no blockers logged
```

## Format rules (do not deviate)

- **Exactly 4 lines.** No greetings, no preamble, no follow-up sentences.
- "Short title" = first 8 words of the entry text, max.
- More than 5 entries in a section → list first 5, append `, +<remainder> more`.
- If BOTH decisions and tasks are empty in the last 24h, post these 2 lines instead:
  ```
  Standup — <date>
  Nothing logged in the last 24 hours.
  ```
- Date is the local calendar date the cron fires on (the timezone passed in the cron schedule).

## Edge cases

- `decisions.md` or `tasks.md` missing → treat that section as empty (count = 0, value = "none").
- Either file malformed → reply in the post `(format issue in <filename>; partial summary)` and best-effort summarize what you can parse.
- Channel post fails → log the failure to `data/logs/standup-errors.md` in the workspace; do not retry in the same run.
