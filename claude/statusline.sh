#!/usr/bin/env bash
# Status line: model | repo:branch | context used %.
# Uses context_window fields when Claude Code provides them, otherwise reads the
# token usage of the last assistant message from the transcript.
set -uo pipefail

input=$(cat)
model=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
size=$(jq -r '.context_window.context_window_size // 200000' <<<"$input")
pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input")

if [[ -z "$pct" && -n "$transcript" && -f "$transcript" ]]; then
  used=$(tail -n 400 "$transcript" |
    jq -rs '[.[] | select(.type == "assistant" and .message.usage != null and (.isSidechain | not))] | last
      | .message.usage // empty
      | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)' 2>/dev/null)
  [[ -n "$used" && "$used" != "null" ]] && pct=$((used * 100 / size))
fi

loc=""
if [[ -n "$dir" ]]; then
  loc=$(basename "$dir")
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  [[ -n "$branch" ]] && loc+=":$branch"
fi

ctx="ctx ?"
if [[ -n "$pct" ]]; then
  pct=${pct%.*}
  if ((pct >= 70)); then ctx="ctx ${pct}% (compact soon)"; else ctx="ctx ${pct}%"; fi
fi

echo "$model | ${loc:-no-dir} | $ctx"
