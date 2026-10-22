#!/usr/bin/env bash
# PreToolUse(Bash): stop commands that are unsafe or flood the context window.
# Exit 2 blocks the command and shows the hint to Claude.
set -uo pipefail

cmd=$(jq -r '.tool_input.command // empty')
[[ -z "$cmd" ]] && exit 0

block() {
  echo "Blocked by bash-guard: $1" >&2
  exit 2
}

# Start of a command: line start or after ; & | ( or whitespace
s='(^|[;&|(]|[[:space:]])'
tf="${s}terraform([[:space:]]+-chdir=[^[:space:]]+)?[[:space:]]+"

if [[ "$cmd" =~ ${tf}(apply|destroy)([[:space:]]|$) ]]; then
  block "terraform apply/destroy is run by the user only. Ask them to run it (they can use the ! prefix)."
fi

if [[ "$cmd" =~ ${tf}state[[:space:]]+(pull|show) ]]; then
  block "terraform state output can contain secrets and is large. Use 'terraform state list' instead."
fi

if [[ "$cmd" =~ ${tf}plan([[:space:]]|$) ]] && [[ "$cmd" != *"-out"* && "$cmd" != *"|"* && "$cmd" != *">"* ]]; then
  block "raw terraform plan output floods the context. Use ~/.claude/skills/tf-plan-summary/scripts/summarise-plan.sh <dir>, or delegate to tf-plan-reviewer."
fi

if [[ "$cmd" =~ ${s}gh[[:space:]]+run[[:space:]]+view ]] && [[ "$cmd" == *"--log"* && "$cmd" != *"--log-failed"* && "$cmd" != *"|"* ]]; then
  block "full CI logs are huge. Use 'gh run view <id> --log-failed | tail -150', or delegate to ci-failure-triage."
fi

if [[ "$cmd" =~ ${s}(cat|less|more|head|tail|bat|strings)[[:space:]] ]] &&
  [[ "$cmd" =~ \.tfstate|\.tfvars([[:space:]]|$|\")|(^|[/[:space:]])\.env([.[:space:]]|$) ]]; then
  block "state, tfvars and .env files may contain secrets. Do not read them."
fi

exit 0
