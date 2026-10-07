# AI Starter Kit

A working setup for people starting out with AI agents. It gives Claude Code a
memory, a set of habits, a shared notebook, and a library of safety-checked
skills, so each session picks up where the last one left off instead of
starting blind.

It ships the *process*, as empty templates. Fill them in with your own name,
folders and projects.

## What is in it

| Folder | What it becomes | Where it goes |
|---|---|---|
| `templates/claude/CLAUDE.md` | Rules Claude Code reads at the start of every session | `~/.claude/CLAUDE.md` |
| `templates/claude/settings.json` | What Claude may do without asking you | `~/.claude/settings.json` |
| `templates/AGENTS.md` | The same rules for other agents (OpenCode, Codex and so on) | `~/AGENTS.md` |
| `templates/memory/` | How a memory is written: one fact per file, with why | Claude Code creates the folder; copy the pattern |
| `templates/vault/` | Your Obsidian brain: tiers, session notes, handoffs, projects | Anywhere *not* synced, e.g. `~/Brain` |
| `templates/project/AGENTS.md` | Rules for one project | The top folder of each project |

Coming next: hooks (small scripts that run automatically), an installer for the
basic programs, and the skill library packaged as a Claude Code plugin.

## Setting it up by hand

1. Install Node.js, Git, Obsidian and Claude Code.
2. Copy `templates/vault/` to a folder that is **not** inside OneDrive,
   Dropbox, iCloud, Documents or Desktop. Those sync automatically and would
   upload your `private/` folder. Open that folder in Obsidian as a vault.
3. Copy `templates/claude/CLAUDE.md` and `settings.json` into your `.claude`
   folder (in your home folder). If you already have files there, merge rather
   than overwrite.
4. In every copied file, replace each `{{PLACEHOLDER}}`:
   - `{{YOUR_NAME}}`: what agents should call you.
   - `{{VAULT}}`: the full path to your vault, e.g. `C:/Users/you/Brain`.
5. Start Claude Code and say: "read my CLAUDE.md and tell me what you will do
   at the start of each session". If it describes reading the handoff folder
   and the vault rules, it worked.

## The ideas behind it

- **Write things down where the next session will look.** An agent forgets
  everything between sessions. Notes in fixed places are its memory.
- **Checked or not checked, said out loud.** An agent that states a guess in a
  confident voice sends you the wrong way at full speed.
- **The folder name is the privacy rule.** `open/`, `work/`, `private/`. You
  can see at a glance what is allowed to leave your computer.
- **Never install a skill without reading it.** Skills can carry scripts that
  run on your machine. The kit's skill finder audits each one first and asks you.
