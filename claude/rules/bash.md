---
paths:
  - "**/*.sh"
  - "**/*.bash"
---

# Bash

- Start scripts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Quote every variable expansion: `"$var"`, `"${arr[@]}"`.
- Use `[[ ... ]]` for tests and `$(...)` for command substitution.
- Use `local` for function variables. Send errors to stderr (`>&2`) and exit non-zero.
- Use `mktemp` for temp files and clean up with `trap ... EXIT`.
- Scripts must pass `shellcheck`. Fix warnings rather than disabling them; if a disable is needed, add a comment with the reason.
- Prefer `jq` for JSON and `yq` for YAML over `grep`/`sed` parsing.
