---
name: check-before-claiming-done
description: run the check and name the evidence before saying anything is finished
metadata:
  type: feedback
---

Before saying a task is done, fixed or working, run the command that proves it
and say what it showed.

**Why:** an example of the kind of reason that belongs here. "Three times in one
week a fix was reported as working when it had only been written, not run. Each
time, I found out by trying it myself."

**How to apply:** name the proof in the same sentence as the claim: "the tests
pass (34 of 34)". If it cannot be checked from here, say so and say what would
check it.

---

How memory works, so you can read this file as a template:

- `MEMORY.md` is the index. One line per memory: a link and a short hook. It is
  loaded into every session, so keep it short and never put the memory itself
  there.
- Each memory is its own file holding one fact. `type` is one of `user` (who
  you are and how you like to work), `feedback` (corrections and approaches
  that worked), `project` (goals and deadlines the code does not show), or
  `reference` (where to find things).
- The **Why** line is the important part. A rule without its reason gets
  followed blindly, or dropped the first time it is inconvenient.
- Claude Code keeps these in `~/.claude/projects/<project>/memory/`. Tell it
  "remember that ..." and it writes one.
