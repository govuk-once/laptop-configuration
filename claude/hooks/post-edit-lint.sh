#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): format and lint the edited file.
# Silent on success. On failure prints the first 20 lines to stderr and exits 2,
# which feeds the errors back to Claude.
set -uo pipefail

file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[[ -z "$file" || ! -f "$file" ]] && exit 0

have() { command -v "$1" >/dev/null 2>&1; }

out=""
rc=0
case "$file" in
  *.tf | *.tfvars | *.tftest.hcl)
    if have terraform; then
      # Run from the file's dir so tfenv picks up the nearest .terraform-version.
      # fmt rewrites in place; stdout lists changed files, stderr carries syntax errors.
      out=$(cd "$(dirname "$file")" && terraform fmt -no-color "$(basename "$file")" 2>&1 >/dev/null) || rc=$?
      # tfenv without a resolvable version is a setup gap, not a lint failure
      [[ "$out" == *"tfenv"* ]] && { out=""; rc=0; }
    fi
    ;;
  */.github/workflows/*.yml | */.github/workflows/*.yaml)
    if have actionlint; then
      out=$(actionlint -no-color "$file" 2>&1) || rc=$?
    fi
    if have yamllint; then
      y=$(yamllint -f parsable "$file" 2>&1) || { rc=$?; out+=$'\n'"$y"; }
    fi
    ;;
  *.yml | *.yaml)
    if have yamllint; then
      out=$(yamllint -f parsable "$file" 2>&1) || rc=$?
    fi
    ;;
  *.sh | *.bash)
    if have shellcheck; then
      out=$(shellcheck -f gcc "$file" 2>&1) || rc=$?
    fi
    ;;
  *.ts | *.tsx)
    root="${CLAUDE_PROJECT_DIR:-$PWD}"
    if [[ -x "$root/node_modules/.bin/prettier" ]]; then
      out=$("$root/node_modules/.bin/prettier" --write --log-level warn "$file" 2>&1) || rc=$?
    fi
    ;;
esac

if [[ $rc -ne 0 && -n "${out//[[:space:]]/}" ]]; then
  {
    echo "Lint/format issues in $file:"
    printf '%s\n' "$out" | sed '/^[[:space:]]*$/d' | head -20
  } >&2
  exit 2
fi
exit 0
