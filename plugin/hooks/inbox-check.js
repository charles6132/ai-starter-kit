#!/usr/bin/env node
// SessionStart hook: show the notes earlier sessions left for this one.
//
// A session can be told in CLAUDE.md to read work/handoffs/to-claude/ first,
// and it will usually remember. This is the part that runs whether it
// remembers or not. A handoff that is written but never read is worse than
// none, because everyone believes the job was done.

const fs = require('fs');
const path = require('path');
const vault = require('./vault');

const MAX_FILES = 8;
const SNIPPET = 240;

try { fs.readFileSync(0, 'utf8'); } catch { /* no payload is fine */ }

try {
  const root = vault();
  if (!root) process.exit(0);
  const dir = path.join(root, 'work', 'handoffs', 'to-claude');
  if (!fs.existsSync(dir)) process.exit(0);

  const files = fs.readdirSync(dir)
    .filter((n) => n.toLowerCase().endsWith('.md') && n.toLowerCase() !== 'readme.md')
    .map((n) => {
      const full = path.join(dir, n);
      const st = fs.statSync(full);
      return st.isFile() ? { name: n, full, mtime: st.mtimeMs } : null;
    })
    .filter(Boolean)
    .sort((a, b) => b.mtime - a.mtime)
    .slice(0, MAX_FILES);

  if (!files.length) process.exit(0);

  const lines = files.map((f) => {
    let head = '';
    try {
      head = fs.readFileSync(f.full, 'utf8').replace(/^#+\s*/gm, '').replace(/\s+/g, ' ').trim().slice(0, SNIPPET);
    } catch { head = '(unreadable)'; }
    return `  - ${f.name}  [${new Date(f.mtime).toISOString().slice(0, 10)}]\n      ${head}`;
  });

  const context = [
    'PENDING HANDOFFS in work/handoffs/to-claude/ (left by earlier sessions, newest first):',
    '',
    lines.join('\n'),
    '',
    'Before the first real piece of work: read the ones that touch what you are asked',
    'about, say in one line what they contain, and check that is what should be picked up.',
    'Move anything dealt with into to-claude/done/ so this list stays short.',
  ].join('\n');

  process.stdout.write(JSON.stringify({
    systemMessage: `${files.length} handoff${files.length === 1 ? '' : 's'} waiting in to-claude/`,
    hookSpecificOutput: { hookEventName: 'SessionStart', additionalContext: context },
  }));
} catch {
  // Never hold up a session starting.
}
process.exit(0);
