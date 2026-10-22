#!/usr/bin/env bash
# SessionStart: print a one-line orientation. Stdout is added to Claude's context,
# so keep it short.
set -uo pipefail

dir="${CLAUDE_PROJECT_DIR:-$PWD}"

if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Session dir $dir is not a git repo. Repo-level .claude settings, hooks and CLAUDE.md files in subfolders will not load. Suggest opening a single repo."
  exit 0
fi

repo=$(basename "$(git -C "$dir" rev-parse --show-toplevel)")
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
dirty=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
echo "Repo: $repo | Branch: ${branch:-detached} | Uncommitted files: $dirty"
[[ "$branch" == "main" || "$branch" == "master" ]] && echo "On $branch: create a feature branch before committing."
exit 0
