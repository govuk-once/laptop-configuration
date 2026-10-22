#!/usr/bin/env bash
# Lint and scan only the files changed on this branch. Prints a pass/fail table.
# Usage: pr-ready.sh [base-branch]
# Written for macOS bash 3.2: no mapfile, no set -u (empty arrays).
set -o pipefail

base="${1:-origin/main}"
root=$(git rev-parse --show-toplevel) || exit 1
cd "$root" || exit 1

mb=$(git merge-base HEAD "$base" 2>/dev/null) || { echo "Cannot find merge base with $base" >&2; exit 1; }
# readarr <name> <cmd...>: read command output lines into array <name>
readarr() {
  local _n="$1" _l
  shift
  eval "$_n=()"
  while IFS= read -r _l; do [[ -n "$_l" ]] && eval "$_n+=(\"\$_l\")"; done < <("$@")
}

changed() {
  { git diff --name-only "$mb"...HEAD; git diff --name-only; git diff --name-only --cached; } |
    sort -u | while IFS= read -r f; do [[ -f "$f" ]] && echo "$f"; done
}
readarr files changed

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No changed files against $base."
  exit 0
fi

have() { command -v "$1" >/dev/null 2>&1; }
pick() { local re="$1"; printf '%s\n' "${files[@]}" | grep -E "$re" || true; }

results=()
failed=0

run() {
  local name="$1"
  shift
  local out
  if out=$("$@" 2>&1); then
    results+=("pass     $name")
  else
    results+=("FAIL     $name")
    failed=1
    echo "---- $name ----"
    printf '%s\n' "$out" | sed '/^[[:space:]]*$/d' | head -15
  fi
}

skip() { results+=("skipped  $1 ($2)"); }

echo "Changed files: ${#files[@]} (against $base)"

if [[ -f .pre-commit-config.yaml ]]; then
  if have pre-commit; then run "pre-commit" pre-commit run --color never --files "${files[@]}"; else skip "pre-commit" "not installed"; fi
fi

tf_dirs() { pick '\.tf$' | while IFS= read -r f; do dirname "$f"; done | sort -u; }
readarr tfdirs tf_dirs
if [[ ${#tfdirs[@]} -gt 0 ]]; then
  for d in "${tfdirs[@]}"; do
    if have terraform; then run "terraform fmt $d" terraform -chdir="$d" fmt -check -no-color; fi
    if have tflint; then run "tflint $d" tflint --chdir="$d" --no-color; else skip "tflint" "not installed"; fi
    if have trivy; then run "trivy $d" trivy config --severity HIGH,CRITICAL --exit-code 1 --quiet "$d"; else skip "trivy" "not installed"; fi
  done
fi

readarr wf pick '^\.github/workflows/.*\.ya?ml$'
if [[ ${#wf[@]} -gt 0 ]]; then
  if have actionlint; then run "actionlint" actionlint -no-color "${wf[@]}"; else skip "actionlint" "not installed"; fi
fi

readarr yml pick '\.ya?ml$'
if [[ ${#yml[@]} -gt 0 ]]; then
  if have yamllint; then run "yamllint" yamllint -f parsable "${yml[@]}"; else skip "yamllint" "not installed"; fi
fi

readarr sh pick '\.(sh|bash)$'
if [[ ${#sh[@]} -gt 0 ]]; then
  if have shellcheck; then run "shellcheck" shellcheck -f gcc "${sh[@]}"; else skip "shellcheck" "not installed"; fi
fi

echo
echo "Result   Check"
printf '%s\n' "${results[@]}"
exit "$failed"
