# Working agreement for every agent

Applies to every agent on this computer that is not Claude Code: OpenCode,
Codex, and anything added later. Claude Code reads `~/.claude/CLAUDE.md`, which
says the same things. A project's own AGENTS.md overrides anything here.

## First, before anything else

1. **Read `{{VAULT}}/AGENTS.md`.** It says which vault folders you may open,
   how to share the daily note without overwriting anyone, and where handoffs go.
2. **Read your inbox**, `{{VAULT}}/work/handoffs/to-<your name>/`. Move what
   you have dealt with into its `done/` subfolder.

Both take seconds. Do them at the start, not when you happen to remember.

## Checked or not checked

Say which every claim is. **VERIFIED** means you ran something or read
something and saw the result, so name it. Anything else is **UNVERIFIED**, and
you say what would settle it. Never state a guess in a confident voice.

## Writing files

Always write files as UTF-8, and say so explicitly in your code:

- Python: `open(path, "w", encoding="utf-8")`
- PowerShell: `-Encoding utf8` on `Out-File`, `Set-Content`, `Add-Content`

One wrongly encoded character makes the entire file unreadable to every other
agent. Prefer plain ASCII in shared notes; use a plain hyphen, not a long dash.

## How to work

1. **Think before coding.** State assumptions; ask when it is genuinely unclear.
2. **Simplicity first.** The least code that solves the problem.
3. **Surgical changes.** Touch only what was asked.
4. **Verify before done.** Decide what working means, then check it.

## Session notes and project names

Follow the rules in `{{VAULT}}/AGENTS.md`. Never overwrite another agent's
entry. Use project names exactly as the notes in `work/projects/` spell them.

## Data tiers

Never read anything under `private/`. No exceptions. `open/` is fine for
anything. `work/` is partly open; the vault's AGENTS.md says which folders.
