---
name: debug-loop
user-invocable: true
allowed-tools: Read, Write, Glob, Bash, Task
description: Run a bug fix to completion — a debug agent fixes, an analysis agent independently checks, and they alternate until the fix passes or the iteration cap is hit. Use when a fix must be proven, not just attempted.
---

# Debug Loop

Runs a bug to a proven fix: fixer → analyst → fixer → analyst, until the analyst
passes the fix or the loop hits its cap. Each agent starts fresh and reads only
files — the loop never inherits one agent's context into another's.

## Trigger

`/debug-loop <what is broken>` — for anything that must work, not just be
attempted.

## Layout

```
debug/{slug}/
  ├── bug.md              # exact error, command, environment, working dir (checkpoint)
  ├── iter-1-fix.md       # fixer's report (debug-agent)
  ├── iter-1-analysis.md  # analyst's verdict (analysis-agent)
  ├── iter-2-fix.md       # only if REVISE
  ├── iter-2-analysis.md
  └── outcome.md          # final verdict + evidence
```

## Procedure

### Step 1: Write bug.md
The exact error text, the command that produced it, the environment (OS,
versions, config, recent changes), and the working directory. Never a
paraphrase. This is the checkpoint — a crash resumes from here. Spawn every
agent from that same working directory so verdicts cannot drift apart.

No `bug.md`, no fixer. If you cannot write the exact error and the command
that produced it, you do not have a reproduction yet — get one first. A loop
started without the checkpoint cannot be resumed after a crash.

### Step 2: Loop (max 3 iterations)

Each iteration, in order:

1. **Fixer.** Spawn the `debug-agent` subagent (fresh context). Give it:
   - `bug.md`
   - on iteration 2+, the previous analysis's "What the fixer must do next"
     section — the delta, not the whole file. Its findings are the
     requirements.
   - the output contract: write `iter-{n}-fix.md`
   It edits the code and writes its report. It does NOT get the analyst's
   conversation — only the file.
2. **Analyst.** Spawn the `analysis-agent` subagent (fresh context). Give it:
   - `bug.md`
   - `iter-{n}-fix.md`
   - the code under test
   - the output contract: write `iter-{n}-analysis.md`
   It runs the code and writes its verdict. It does NOT edit code.
   On iteration 2+, tell it to check whether the previous REVISE finding is
   fixed first, then do a lighter pass — not a full re-review.
3. **Read the verdict.** Only the verdict line, the top-finding line, and the
   "what the fixer must do" section enter your context — not the analyst's
   whole session.

Exit conditions:
- **PASS** → stop. Write `outcome.md`: the verdict, the final diff, the
  verification evidence, the iteration count, and — under its own
  `## Residual findings` heading — every finding the analyst still listed.
  PASS answers "is the bug fixed", not "is the code fine". In all five runs to
  date the analyst passed the fix and still reported real problems; they
  survived only because a human read the file. Carry them or lose them.
- **REVISE** → next iteration. The fixer's requirements are the analyst's
  findings, nothing more.
- **FAIL** → stop. Write `outcome.md` with the blocker and what is missing.
- **Circuit breaker:** if the analyst's top-finding line is the same as the
  previous iteration's, stop — the loop is going in circles. Write `outcome.md`
  saying so, with both analyses attached.

### Step 3: Report
One short block: verdict, iterations used, what changed, the evidence. If it
failed, say exactly what is missing. If the analyst passed the fix but left
residual findings, say so in that block and name them — a green verdict that
quietly carries known bugs is the failure this loop exists to prevent.

## Rules

- **Fresh context per agent.** Never spawn the fixer with the analyst's
  conversation, or vice versa. The files are the handoff.
- **Hard cap: 3 iterations.** A fix that is not passing by then needs a human,
  not a fourth loop.
- **The analyst is read-only on code.** If it reports a fix is needed, the
  fixer fixes it — never the analyst.
- **Pin the analyst's model when you can.** If the platform allows per-agent
  models, give the analyst a different family than the fixer — same-family
  reviewers share blind spots and are most generous with their own writing.
- **Cost discipline.** This loop is cheap only if the handoffs are compact.
  Keep bug.md, fix reports, and verdicts tight. Do not paste code into the
  conversation that the next agent can read from disk. Pass the delta, not the
  whole file.
