#!/usr/bin/env bash
# AI Starter Kit installer for macOS and Linux.
#
# Run from the kit folder:
#   bash install.sh --name "Sam" [--vault ~/Brain] [--skip-programs] [--skip-plugin]
#
# It never overwrites a file you already have. Where one exists, the kit's
# version is written beside it with ".starter-kit" in the name, for you to merge.
set -euo pipefail

KIT="$(cd "$(dirname "$0")" && pwd)"
NAME=""; VAULT="$HOME/Brain"; HOME_DIR="$HOME"; SKIP_PROGRAMS=0; SKIP_PLUGIN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --vault) VAULT="$2"; shift 2 ;;
    --home) HOME_DIR="$2"; shift 2 ;;          # change only for testing
    --skip-programs) SKIP_PROGRAMS=1; shift ;;
    --skip-plugin) SKIP_PLUGIN=1; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done
[ -n "$NAME" ] || { echo 'Give your name: bash install.sh --name "Sam"'; exit 1; }

say() { echo "  $*"; }

# 1. Programs
if [ "$SKIP_PROGRAMS" = 0 ]; then
  echo; echo "Installing programs (skipped where already present)"
  if [ "$(uname)" = "Darwin" ]; then
    command -v brew >/dev/null || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
    command -v node >/dev/null && say "Node.js: already installed" || brew install node
    command -v git  >/dev/null && say "Git: already installed"     || brew install git
    [ -d "/Applications/Obsidian.app" ] && say "Obsidian: already installed" || brew install --cask obsidian
  else
    for c in node git; do command -v "$c" >/dev/null || { echo "Install $c with your package manager, then run this again."; exit 1; }; done
    say "Obsidian: download it from https://obsidian.md if you do not have it."
  fi
  command -v claude >/dev/null && say "Claude Code: already installed" || curl -fsSL https://claude.ai/install.sh | bash
fi

# 2. Vault
echo; echo "Setting up the vault"
for bad in OneDrive Dropbox iCloud "Mobile Documents" Documents Desktop "Creative Cloud"; do
  case "$VAULT" in *"$bad"*)
    echo "The vault must not live inside $bad - it syncs automatically and would upload private/. Choose another --vault."; exit 1 ;;
  esac
done
mkdir -p "$VAULT"; VAULT="$(cd "$VAULT" && pwd)"

place() {  # place <template> <destination>
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    local base="${dest%.*}" ext="${dest##*.}"
    dest="$base.starter-kit.$ext"; say "exists already, kit version saved beside it: $dest"
  else say "created $dest"; fi
  # perl ships with macOS and nearly every Linux; values are inserted literally.
  KIT_NAME="$NAME" KIT_VAULT="$VAULT" perl -pe 's/\{\{YOUR_NAME\}\}/$ENV{KIT_NAME}/g; s/\{\{VAULT\}\}/$ENV{KIT_VAULT}/g' "$src" > "$dest"
}

TPL="$KIT/templates"
(cd "$TPL/vault" && find . -type f) | while read -r rel; do
  rel="${rel#./}"; [ -e "$VAULT/$rel" ] || place "$TPL/vault/$rel" "$VAULT/$rel"
done

# 3. Rules and settings
echo; echo "Writing rules and settings"
place "$TPL/claude/CLAUDE.md"     "$HOME_DIR/.claude/CLAUDE.md"
place "$TPL/claude/settings.json" "$HOME_DIR/.claude/settings.json"
place "$TPL/AGENTS.md"            "$HOME_DIR/AGENTS.md"

# 4. Plugin
if [ "$SKIP_PLUGIN" = 0 ]; then
  echo; echo "Installing the Claude Code plugin"
  if command -v claude >/dev/null; then
    claude plugin marketplace add "$KIT"
    claude plugin install ai-starter-kit@ai-starter-kit
  else
    say "Claude Code is not on PATH yet. Open a new terminal and run:"
    say "  claude plugin marketplace add \"$KIT\""
    say "  claude plugin install ai-starter-kit@ai-starter-kit"
  fi
fi

echo; echo "Done. Next:"
say "1. Open Obsidian and choose 'Open folder as vault': $VAULT"
say "2. Start Claude Code and sign in."
say "3. Ask it: 'read my CLAUDE.md and tell me what you do at the start of each session'."
say "Any file named *.starter-kit.* is the kit's version of a file you already had. Merge it by hand."
