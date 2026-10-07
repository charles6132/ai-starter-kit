# AI Starter Kit installer for Windows.
#
# Run from the kit folder in PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -YourName "Sam"
#
# It never overwrites a file you already have. Where one exists, the kit's
# version is written beside it with ".starter-kit" in the name, for you to merge.
param(
  [Parameter(Mandatory = $true)][string]$YourName,
  [string]$VaultPath = (Join-Path $HOME 'Brain'),
  [string]$HomeDir = $HOME,          # change only for testing
  [switch]$SkipPrograms,
  [switch]$SkipPlugin
)
$ErrorActionPreference = 'Stop'
$Kit = $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)   # UTF-8 without a byte-order mark

function Say($msg) { Write-Host "  $msg" }

# 1. Programs ---------------------------------------------------------------
if (-not $SkipPrograms) {
  Write-Host "`nInstalling programs (skipped where already present)"
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is missing. Install 'App Installer' from the Microsoft Store, then run this again."
  }
  $programs = @(
    @{ Id = 'OpenJS.NodeJS.LTS';    Cmd = 'node';   Name = 'Node.js' },
    @{ Id = 'Git.Git';              Cmd = 'git';    Name = 'Git' },
    @{ Id = 'Obsidian.Obsidian';    Cmd = $null;    Name = 'Obsidian' },
    @{ Id = 'Anthropic.ClaudeCode'; Cmd = 'claude'; Name = 'Claude Code' }
  )
  foreach ($p in $programs) {
    $have = if ($p.Cmd) { [bool](Get-Command $p.Cmd -ErrorAction SilentlyContinue) }
            else { (winget list --id $p.Id --exact 2>$null | Select-String $p.Id) -ne $null }
    if ($have) { Say "$($p.Name): already installed"; continue }
    Say "$($p.Name): installing"
    winget install --id $p.Id --exact --silent
    if ($LASTEXITCODE -ne 0) { throw "$($p.Name) did not install (winget exit $LASTEXITCODE)." }
  }
  # Pick up PATH changes from the installs in this same window.
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# 2. Vault ------------------------------------------------------------------
Write-Host "`nSetting up the vault"
$VaultPath = [IO.Path]::GetFullPath($VaultPath)
foreach ($bad in 'OneDrive', 'Dropbox', 'iCloud', 'Documents', 'Desktop', 'Creative Cloud') {
  if ($VaultPath -match [regex]::Escape($bad)) {
    throw "The vault must not live inside $bad - it syncs automatically and would upload private/. Choose another -VaultPath."
  }
}
$VaultFwd = $VaultPath -replace '\\', '/'

function Fill([string]$text) { $text.Replace('{{YOUR_NAME}}', $YourName).Replace('{{VAULT}}', $VaultFwd) }

function Place([string]$src, [string]$dest) {
  $text = Fill ([IO.File]::ReadAllText($src, $Utf8))
  New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
  if (Test-Path $dest) {
    $ext = [IO.Path]::GetExtension($dest)
    $dest = [IO.Path]::ChangeExtension($dest, ".starter-kit$ext")
    Say "exists already, kit version saved beside it: $dest"
  } else { Say "created $dest" }
  [IO.File]::WriteAllText($dest, $text, $Utf8)
}

$tpl = Join-Path $Kit 'templates'
Get-ChildItem (Join-Path $tpl 'vault') -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring((Join-Path $tpl 'vault').Length + 1)
  $dest = Join-Path $VaultPath $rel
  if (-not (Test-Path $dest)) { Place $_.FullName $dest }
}

# 3. Rules and settings ------------------------------------------------------
Write-Host "`nWriting rules and settings"
$claudeDir = Join-Path $HomeDir '.claude'
Place (Join-Path $tpl 'claude\CLAUDE.md')     (Join-Path $claudeDir 'CLAUDE.md')
Place (Join-Path $tpl 'claude\settings.json') (Join-Path $claudeDir 'settings.json')
Place (Join-Path $tpl 'AGENTS.md')            (Join-Path $HomeDir 'AGENTS.md')

# 4. Plugin ------------------------------------------------------------------
if (-not $SkipPlugin) {
  Write-Host "`nInstalling the Claude Code plugin"
  if (Get-Command claude -ErrorAction SilentlyContinue) {
    claude plugin marketplace add $Kit
    claude plugin install ai-starter-kit@ai-starter-kit
  } else {
    Say "Claude Code is not on PATH yet. Open a new window and run:"
    Say "  claude plugin marketplace add `"$Kit`""
    Say "  claude plugin install ai-starter-kit@ai-starter-kit"
  }
}

Write-Host "`nDone. Next:"
Say "1. Open Obsidian and choose 'Open folder as vault': $VaultPath"
Say "2. Start Claude Code and sign in."
Say "3. Ask it: 'read my CLAUDE.md and tell me what you do at the start of each session'."
Say "Any file named *.starter-kit.* is the kit's version of a file you already had. Merge it by hand."
