#!/usr/bin/env node
// SessionEnd hook: record that a session happened.
//
// Deliberately dumb. It appends one line to a daily ledger in the vault and
// exits. No model call, nothing that can block the session closing. The ledger
// catches sessions that ended before anyone wrote them up in the session note.

const fs = require('fs');
const path = require('path');
const vault = require('./vault');

const MIN_TRANSCRIPT_BYTES = 20000; // below this it was a quick question, not a session

let d;
try { d = JSON.parse(fs.readFileSync(0, 'utf8')); } catch { process.exit(0); }

const root = vault();
if (!root) process.exit(0);

let size = 0;
try { size = fs.statSync(d.transcript_path || '').size; } catch { process.exit(0); }
if (size < MIN_TRANSCRIPT_BYTES) process.exit(0);

const now = new Date();
const pad = (n) => String(n).padStart(2, '0');
const date = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
const time = `${pad(now.getHours())}:${pad(now.getMinutes())}`;
const folder = path.basename(d.cwd || '') || '?';
const ledger = path.join(root, 'work', 'sessions', `${date}-ledger.md`);

try {
  fs.mkdirSync(path.dirname(ledger), { recursive: true });
  if (!fs.existsSync(ledger)) {
    fs.writeFileSync(ledger, `# Sessions - ${date}\n\nOne line per session, written automatically when a session ends.\n\n`, 'utf8');
  }
  fs.appendFileSync(ledger, `- ${time} - ${folder} - ${(size / 1048576).toFixed(1)} MB - ${d.transcript_path}\n`, 'utf8');
} catch {
  // A failed log must never hold up a session closing.
}
process.exit(0);
