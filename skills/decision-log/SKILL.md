---
name: decision-log
description: "Log team decisions to decisions.md when a Discord message in a team channel starts with 'decision:'."
metadata: { "openclaw": { "emoji": "📝" } }
allowed-tools: ["memory", "message"]
---

# Decision Log

Persist team decisions made in Discord channels into a durable `decisions.md` file. One of the three core jobs Collab Mesh performs for the Synapse team.

## When to invoke (trigger)

A Discord message in a **team channel** (not a DM) where the text, after trimming whitespace, starts with `decision:` (case-insensitive). Examples that match:

- `decision: ship the auth migration on Friday`
- `Decision: hire two more frontend engineers`
- `   decision:  rename the project to Collab Mesh`

Anything else — DMs, messages without the prefix, "I think we should decide ..." without a literal `decision:` — does **not** trigger this skill.

## What to do

1. **Extract** the decision text — everything after `decision:`, trimmed of surrounding whitespace.
2. **Read** `decisions.md` from the workspace root via the memory tool. If it does not exist, treat its content as empty.
3. **Compute** the next entry number `N`: `1` if the file is empty, otherwise `(last entry's N) + 1`.
4. **Append** a new entry to `decisions.md` in the format below, then save the file.
5. **Confirm** in the same channel via the message tool, exactly one line.

## Entry format in decisions.md

Each entry is two lines, separated from the previous entry by a blank line:

```
- [N] YYYY-MM-DD HH:MM UTC — @author
  decision text here
```

Rules:

- `N` is monotonically increasing. Never reuse a number, even after deletion.
- Timestamp is **UTC**, 24-hour, format `YYYY-MM-DD HH:MM`.
- `@author` is the Discord display name of the message author. If unavailable, use `<@USER_ID>`.
- Decision text is preserved verbatim — no rewording, no summarization, no autocorrect.

## Confirmation reply

Post exactly one line in the same channel the user posted. Format:

```
Logged decision #N — <author>.
```

No emojis. No "Great call!" No follow-up sentences. The terseness is intentional and matches the project coordinator voice in `SOUL.md`.

## Edge cases

- **Empty decision** (literally `decision:` with nothing after) — reply `Decision text is empty — try again.` Do NOT write to decisions.md.
- **DM channel** — do NOT log. If the user clearly intended a decision, reply `Decision logging only runs in team channels — repost there.`
- **Multiple decisions in one message** (e.g. several `decision:` lines pasted together) — log only the first, reply `Logged 1 decision; please post additional decisions one per message.`
- **decisions.md write failure** — surface the error in one line: `Could not write decisions.md: <reason>.` Do not pretend it succeeded.

## Examples

### Normal flow

User in `#general`:
> `decision: ship the auth migration on Friday`

`decisions.md` after the write:
```
- [14] 2026-05-08 14:32 UTC — @alice
  ship the auth migration on Friday
```

Bot reply in `#general`:
> `Logged decision #14 — alice.`

### Empty body

User in `#general`:
> `decision:`

Bot reply:
> `Decision text is empty — try again.`

(No write to decisions.md.)
