---
name: jira
description: Atlassian CLI (acli) recipes for Jira work items with small output (view, search, comment, transition). Use instead of Atlassian MCP tools for routine Jira reads.
---

# Jira via acli

Install once: `brew tap atlassian/homebrew-acli && brew install acli`, then authenticate (`acli jira auth login --help` lists the options, including browser login).
If `acli` is missing, fall back to the Atlassian MCP tools with `view: "compact"`, or delegate to `atlassian-scribe`.

## Read

```bash
# One work item, chosen fields only
acli jira workitem view PLAT-123 --fields key,summary,status,assignee,description

# Comments only
acli jira workitem view PLAT-123 --fields comment

# Search, small CSV
acli jira workitem search --jql "project = PLAT AND assignee = currentUser() AND statusCategory != Done" \
  --fields key,status,summary --limit 10 --csv

# Count only
acli jira workitem search --jql "project = PLAT AND sprint in openSprints()" --count
```

## Write (ask the user first)

```bash
acli jira workitem comment create --key PLAT-123 --body "Plan reviewed: 2 create, 0 delete."
acli jira workitem transition --key PLAT-123 --status "In Review"
```

Tips:
- `--fields` accepts `*all` and `-field` to exclude, but avoid `*all`: it is the large-output case.
- PR titles in GDS repos start with the Jira key (`PLAT-123: ...`), so `git log --oneline | grep -o 'PLAT-[0-9]*'` finds related tickets.
