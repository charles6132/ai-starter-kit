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

It also contains a Claude Code **plugin** (`plugin/`) with:

- **Four hooks**, small scripts that run automatically:
  - on starting, show the notes the last session left;
  - on every message, check for a better skill;
  - after every edit, check the file still parses;
  - on closing, log the session.
- **Skills**: the skill finder, two safety audits (one for skills, one for
  whole GitHub projects), a debug loop where a fixer and an independent
  reviewer take turns until a fix is proven, and `/teach`, a guided learning
  workspace for any new topic (from Matt Pocock's skills, MIT licence).

## Installing

**Windows**, in PowerShell from this folder:

    powershell -ExecutionPolicy Bypass -File .\install.ps1 -YourName "Sam"

**macOS or Linux**, from this folder:

    bash install.sh --name "Sam"

Both install Node.js, Git, Obsidian and Claude Code if they are missing, create
your vault (default `Brain` in your home folder; choose another with
`-VaultPath` or `--vault`), write the rules and settings, and install the
plugin. They never overwrite a file you already have: the kit's version is
saved beside yours as `*.starter-kit.*` for you to merge.

To install only the plugin, inside Claude Code:

    /plugin marketplace add <this folder, or owner/repo once on GitHub>
    /plugin install ai-starter-kit@ai-starter-kit

The hooks find your vault through one setting in `~/.claude/settings.json`:
`"env": { "AI_KIT_VAULT": "<path to your vault>" }`. The installer writes it.
Without it, the vault hooks stay silent.

## Setting it up by hand

1. Install Node.js, Git, Obsidian and Claude Code.
2. Copy `templates/vault/` to a folder that is **not** inside OneDrive,
   Dropbox, iCloud, Documents or Desktop, and open it in Obsidian as a vault.
3. Copy `templates/claude/CLAUDE.md` and `settings.json` into the `.claude`
   folder in your home folder, and `templates/AGENTS.md` into your home folder.
   Merge with anything already there rather than overwriting it.
4. In every copied file, replace `{{YOUR_NAME}}` with what agents should call
   you and `{{VAULT}}` with the full path to your vault.
5. Install the plugin as above.

## The ideas behind it

- **Write things down where the next session will look.** An agent forgets
  everything between sessions. Notes in fixed places are its memory.
- **Checked or not checked, said out loud.** An agent that states a guess in a
  confident voice sends you the wrong way at full speed.
- **The folder name is the privacy rule.** `open/`, `work/`, `private/`. You
  can see at a glance what is allowed to leave your computer.
- **Never install a skill without reading it.** Skills can carry scripts that
  run on your machine. The kit's skill finder audits each one first and asks you.

## Licence

MIT, by Finding Faves. Bundled skills from other authors keep their own MIT licences, credited beside each one.
