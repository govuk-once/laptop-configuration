#!/usr/bin/env bash
# Symlink this repo's Claude Code config into ~/.claude so the repo is the source of truth.
# Existing files are moved to ~/.claude/backup-<timestamp>/ first.
# settings.json is never linked: it holds machine-specific secrets. Merge
# settings.template.json into it by hand.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$HOME/.claude"
backup="$dest/backup-$(date +%Y%m%d-%H%M%S)"

link() {
  local from="$src/$1" to="$dest/$1"
  if [[ -L "$to" && "$(readlink "$to")" == "$from" ]]; then
    echo "ok       $1"
    return
  fi
  if [[ -e "$to" || -L "$to" ]]; then
    mkdir -p "$backup/$(dirname "$1")"
    mv "$to" "$backup/$1"
    echo "backed up $1"
  fi
  mkdir -p "$(dirname "$to")"
  ln -s "$from" "$to"
  echo "linked   $1"
}

link CLAUDE.md
link statusline.sh
link rules
link agents
link hooks
for skill in "$src"/skills/*/; do
  link "skills/$(basename "$skill")"
done

chmod +x "$src"/hooks/*.sh "$src"/statusline.sh "$src"/skills/*/scripts/*.sh

echo
echo "Done. Merge settings.template.json into $dest/settings.json if it changed."
[[ -d "$backup" ]] && echo "Backups: $backup"
