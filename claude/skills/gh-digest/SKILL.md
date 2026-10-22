---
name: gh-digest
description: Compact GitHub CLI recipes for PRs, checks, workflow runs and issues using --json and --jq. Use instead of GitHub MCP tools for routine reads to keep output small.
---

# GitHub CLI digest recipes

Always select fields with `--json` and shape them with `--jq`.
Add `-R owner/repo` when not inside the repo.

## Pull requests

```bash
# One-line status
gh pr view <n> --json number,title,state,isDraft,reviewDecision,mergeable \
  --jq '"#\(.number) \(.title) | \(.state) draft=\(.isDraft) review=\(.reviewDecision) mergeable=\(.mergeable)"'

# Changed files only (no diff body)
gh pr diff <n> --name-only

# Diff for one file
gh pr diff <n> | awk '/^diff --git/{p=/<path>/} p' | head -200

# Checks, failures only
gh pr checks <n> --json name,state,link --jq '.[] | select(.state != "SUCCESS") | "\(.state) \(.name) \(.link)"'

# Open PRs, mine or for review
gh pr list --author @me --json number,title,headRefName --jq '.[] | "#\(.number) \(.headRefName) \(.title)"'
gh pr list --search "review-requested:@me" --json number,title,author --jq '.[] | "#\(.number) \(.author.login) \(.title)"'

# Review comments, bodies trimmed
gh api repos/{owner}/{repo}/pulls/<n>/comments --jq '.[] | "\(.path):\(.line // .original_line) \(.user.login): \(.body[:200])"'
```

## Workflow runs

```bash
gh run list --limit 5 --json databaseId,workflowName,conclusion,headBranch \
  --jq '.[] | "\(.databaseId) \(.conclusion // "running") \(.workflowName) \(.headBranch)"'
gh run view <id> --json jobs --jq '.jobs[] | select(.conclusion=="failure") | .name'
gh run view <id> --log-failed | tail -150
```

For anything deeper, delegate to the `ci-failure-triage` agent.

## Issues

```bash
gh issue view <n> --json title,state,labels,body --jq '"\(.title) [\(.state)] \([.labels[].name]|join(","))\n\(.body[:1500])"'
gh issue list --label <label> --limit 10 --json number,title --jq '.[] | "#\(.number) \(.title)"'
```

## Writes

Creating or editing PRs, issues or comments publishes work.
Ask the user first, every time.
