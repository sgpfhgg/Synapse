---
name: task-routing
description: Route tasks from team channel messages starting with 'task:' to the right Synapse member. DM them and log to tasks.md.
metadata: { "openclaw": { "emoji": "📬" } }
allowed-tools: ["memory", "message"]
---

# Task Routing

**Trigger:** a Discord **channel** message (NOT DM) whose text, trimmed, starts with `task:` (case-insensitive). Anything else: do nothing.

## Steps

1. Extract task text after `task:`, trimmed.
2. Read `members.json` from workspace. Pick the member whose `skills` array best matches the task. Ties → first listed.
3. DM the assignee with the `message` tool. Required exact shape:
   ```json
   {"action":"send","channel":"discord","to":"user:<assignee.discordId>","message":"Synapse — new task from @<requester>:\n\"<task>\""}
   ```
4. Read `tasks.md` (treat missing as empty). Compute next number `N` = (highest existing N) + 1, or 1 if empty.
5. Append this two-line block to `tasks.md`, separated from previous entry by a blank line:
   ```
   - [N] YYYY-MM-DD HH:MM UTC — @<assignee> (from @<requester>)
     <task>
   ```
6. Reply once in the original channel: `Routed task #N to @<assignee>.`

## Worked example

User `@alice` posts in `#general`: `task: build a redis cache for the API`

- Pick: `Alex` (members.json skills include `backend, redis`)
- DM Alex via tool call:
  ```json
  {"action":"send","channel":"discord","to":"user:793110932770652189","message":"Synapse — new task from @alice:\n\"build a redis cache for the API\""}
  ```
- Append to `tasks.md`:
  ```
  - [1] 2026-05-08 14:32 UTC — @Alex (from @alice)
    build a redis cache for the API
  ```
- Channel reply: `Routed task #1 to @Alex.`

## Format rules (do not deviate)

- `<assignee>` = the `name` field in members.json (e.g. `Alex`), NOT a Discord display name.
- `<requester>` = the Discord display name of the message author.
- Time is **UTC**, 24-hour, format `YYYY-MM-DD HH:MM UTC`.
- `N` is monotonic, never reused.
- DM tool parameter is `to` (NOT `target`). Value MUST start with `user:`.

## Edge cases

- Posted in a DM (not a channel) → reply `Task routing only runs in team channels.` Do not log.
- Empty task body → reply `Task description is empty — try again.` Do not log.
- `members.json` missing or empty → reply `members.json missing — populate it before posting tasks.`
- DM delivery fails → still write the `tasks.md` entry, but extend the channel reply: `Routed task #N to @<assignee>. (DM delivery failed.)`
