#!/usr/bin/env node
// Fast syntax gate for Claude Code PostToolUse (Edit|Write).
// Parses the file that was just written. Exit 2 reports breakage back to Claude.
// Deliberately cheap: no full test suite, no type check, no network.
//
// Source is read here and copied to a short temp path before any interpreter
// sees it: Node handles >260-char Windows paths, python and bash do not, and a
// file the interpreter cannot open must never be reported as a syntax error.

// The skill auditor flags this import. It is used only to run a fixed checker
// (node, python or bash) on a temp copy of the file, with the arguments passed
// as a list and no shell, so a file name cannot smuggle in a command.
const { execFileSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

let raw = '';
try {
  raw = fs.readFileSync(0, 'utf8');
} catch {
  process.exit(0);
}

let file;
try {
  const d = JSON.parse(raw);
  file = (d.tool_response && d.tool_response.filePath) || (d.tool_input && d.tool_input.file_path);
} catch {
  process.exit(0);
}

if (!file) process.exit(0);

const base = path.basename(file).toLowerCase();
const ext = path.extname(file).toLowerCase();

const CHECKS = {
  '.py':   (t) => ['python', ['-c', 'import ast,sys; ast.parse(open(sys.argv[1],encoding="utf-8").read(), sys.argv[1])', t]],
  '.js':   (t) => [process.execPath, ['--check', t]],
  '.cjs':  (t) => [process.execPath, ['--check', t]],
  '.mjs':  (t) => [process.execPath, ['--check', t]],
  '.sh':   (t) => ['bash', ['-n', t]],
  '.bash': (t) => ['bash', ['-n', t]],
};

if (ext !== '.json' && !CHECKS[ext]) process.exit(0);

// Anything we cannot read, or that is large enough to stall the turn, is not our business.
let src;
try {
  if (fs.statSync(file).size > 2 * 1024 * 1024) process.exit(0);
  src = fs.readFileSync(file, 'utf8');
} catch {
  process.exit(0);
}

function fail(label, detail) {
  console.error(`${label} in ${file}\n${detail}`.trim());
  process.exit(2);
}

if (ext === '.json') {
  // tsconfig and friends allow comments, so JSON.parse would false-positive.
  if (base.endsWith('.jsonc') || base.startsWith('tsconfig')) process.exit(0);
  try {
    JSON.parse(src);
  } catch (e) {
    fail('Invalid JSON', e.message);
  }
  process.exit(0);
}

const tmp = path.join(os.tmpdir(), `cc-fastcheck-${process.pid}${ext}`);
try {
  fs.writeFileSync(tmp, src);
} catch {
  process.exit(0);
}

try {
  const [cmd, args] = CHECKS[ext](tmp);
  execFileSync(cmd, args, { stdio: ['ignore', 'pipe', 'pipe'], timeout: 10000 });
} catch (e) {
  // A missing interpreter or a timeout is not a syntax error - stay silent.
  if (e.code === 'ENOENT' || e.code === 'ETIMEDOUT') process.exit(0);
  const out = ((e.stderr || '') + (e.stdout || '')).toString().split(tmp).join(file).trim();
  fail('Syntax error', out);
} finally {
  try { fs.unlinkSync(tmp); } catch {}
}

process.exit(0);
