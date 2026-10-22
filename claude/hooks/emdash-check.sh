#!/usr/bin/env bash
# PostToolUse(Edit|Write|MultiEdit): block em dashes in prose and config files.
# Only fires when the new content contains an em dash, then lists every
# offending line in the file so Claude can fix them in one pass.
set -uo pipefail

input=$(cat)
file=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' <<<"$input")
[[ -z "$file" || ! -f "$file" ]] && exit 0

case "$file" in
  */CHANGELOG*) exit 0 ;;
  *.md | *.mdx | *.txt | *.rst | *.adoc | *.yml | *.yaml | *.tf | *.hcl | *.sh) ;;
  *) exit 0 ;;
esac

new=$(jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits[]?.new_string)] | map(select(. != null)) | join("\n")' <<<"$input")
# A literal "(—)" names the character (as in style guides) and is allowed
new=${new//"(—)"/}
[[ "$new" == *"—"* ]] || exit 0

hits=$(grep -n '—' "$file" | grep -v '(—)' | head -15)
[[ -z "$hits" ]] && exit 0
{
  echo "Em dash found in $file. Replace each with a comma, parentheses, a colon or a semicolon:"
  sed "s|^|$file:|" <<<"$hits"
} >&2
exit 2
