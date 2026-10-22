---
name: pr-ready
description: Run pre-commit, tflint, trivy, actionlint and shellcheck on files changed in the current branch and print a pass/fail table. Use before committing or before asking for a PR.
---

# PR readiness check

```bash
~/.claude/skills/pr-ready/scripts/pr-ready.sh [base-branch]
```

`base-branch` defaults to `origin/main`.
The script checks only files changed against the merge base plus uncommitted changes.
Missing tools are reported as `skipped`, not failures.
Each failing tool prints at most 15 lines.

After it passes, delegate a deeper review to the `iac-reviewer` agent if the change touches IAM, SCPs, DNS or deploy workflows.
