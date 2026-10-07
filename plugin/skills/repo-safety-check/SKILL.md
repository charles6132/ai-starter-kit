---
name: repo-safety-check
user-invocable: true
allowed-tools: Read, Write, Glob, Bash, WebSearch, WebFetch
description: Scan a GitHub repository for malware, backdoors, or suspicious code BEFORE cloning or running it. Use whenever asked to download/clone a repo, or to evaluate whether a project is safe to use.
---

# Repo Safety Check

## Trigger
Any request to clone, download, or run a GitHub repository — including the phone flow message "Clone this GitHub repo: <url>". Also usable directly: `/repo-safety-check <url>`.

## Rule
**Never clone or run a repo without a safety check first.** If the check fails, do not proceed — report and ask.

## Workflow

### Step 1: Repo metadata (GitHub API, no clone needed)
Fetch `https://api.github.com/repos/{owner}/{repo}` and record:
- Stars, forks, watchers — popularity signal (low stars is not failure, just context)
- Created date + last push — age and activity
- Owner type (user vs org) and owner's other repos
- Archived status, license, description
- Default branch

### Step 2: Issue scan for red flags
Fetch `https://api.github.com/search/issues?q=repo:{owner}/{repo}+malware` and repeat for: `virus`, `backdoor`, `suspicious`, `hack`, `steal`, `miner`, `crypto`.
Record any open issues alleging malicious behavior.

### Step 3: Shallow clone to a temp directory
`git clone --depth 1 <url> <temp>` — never into the final destination yet.

### Step 4: Static scan for dangerous patterns
Search the cloned tree for:

**Obfuscation / hidden code**
- Long base64 blobs (e.g. `base64 -d`, `from base64 import`, `atob(`)
- `eval(` / `exec(` / `Function(` on string variables
- Packed or minified scripts with no source
- Files with unusual extensions in a source repo (.exe, .dll, .scr, .bat, .vbs, .ps1 in unexpected places)

**Credential theft**
- References to `.env`, `token`, `password`, `secret` being read AND sent somewhere
- Webhooks or HTTP POSTs to unknown domains
- Code that uploads local files

**Crypto miners**
- References to mining libraries (xmrig, cryptonight, etc.)
- High-CPU loops with network calls

**Suspicious network behavior**
- Hardcoded IP addresses
- `curl <url> | bash` / `iwr <url> | iex` install patterns
- Calls to newly-registered or unrelated domains

**Supply-chain red flags**
- Install scripts that download and execute remote content
- Dependencies pinned to forks or unusual registries

### Step 5: Verdict
- **PASS** — no red flags, or only benign ones (explain them)
- **REVIEW** — anything suspicious found; list each finding with file path and line
- **FAIL** — clear malicious indicators; do not clone/run

### Step 6: Report
One short block: verdict, stars/age/activity one-liner, findings list (or "no red flags"), and the recommendation. On PASS, proceed with the clone/run. On REVIEW or FAIL, stop and ask the user.

## Notes
- A low-star repo is not automatically unsafe — small but legit projects exist. Context matters.
- The check is a heuristic scan, not a guarantee. Say so when reporting.
- Keep the temp clone; delete it only after the final clone succeeds.