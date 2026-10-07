#!/usr/bin/env node
// UserPromptSubmit hook: before every answer, check for a better tool.
// Whatever this prints is added to Claude's context for that message.
process.stdout.write(`SKILL CHECK (standing rule, every message):
Before answering, look at the installed skills and agent types already listed in this session and ask: would one of them, or an agent given one of them, do this better than answering alone? Use it if so.
Start the reply with one short line: "Tool check: using <skill or agent>" or "Tool check: nothing better installed".
Keep it fast. Do not search the internet for skills on a quick question. Use the find-skills skill only when the task is big or specialised, nothing installed fits, or the same problem has gone round twice.
`);
