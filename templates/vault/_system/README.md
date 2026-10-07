# How this vault works

## The one idea that matters

AI models do not browse your disk. A tool reads specific files and sends that
text to a provider. So this vault does not protect anything by existing. It
protects data by making it obvious, at a glance, what is allowed to leave the
machine.

Storage is local. Sending is the risk. The tier names are the control.

## The three tiers

| Folder | Who may read it | What goes in it |
|---|---|---|
| `open/` | any model, cloud fine | nothing that would hurt in a training set |
| `work/` | named providers only | real work and client information |
| `private/` | a model running on your own computer only | never sent anywhere |

The tier is in the path. A file at `private/legal/lease.md` announces its own
rule. There is no lookup table to remember.

## Backups

Local-only means one disk failure loses everything.

- `open/` and `work/`: any normal backup is fine.
- `private/`: an encrypted backup or an external drive. Not a sync service.

**Never keep this vault in OneDrive, Dropbox, iCloud, Documents, Desktop or
Creative Cloud Files.** Those sync automatically and would upload `private/`
without asking.
