## General Guidelines
- Never manually modify CHANGELOG.md files or any files marked as auto-generated.
- Prefer quality, simplicity, robustness, scalability and long-term maintainability over development cost.
- When something clearly looks off, even if unrelated to the current task, fix it along the way.
- Prefer short sentences. One idea per sentence. Active voice.
- Explain jargon in plain language the first time it appears. Once.
- Back claims with a number, an example, or a link. Never assert without evidence.
- Never use em dashes (—) in any output. Use a comma, parentheses, a colon or a semicolon instead.
- Avoid AI-tell phrasing: "delve", "let's dive in", "it's not just X, it's Y", "in today's fast-paced world", empty closers like "in conclusion".

## Context Hygiene
- Delegate broad searches, plan reviews, CI log triage and Jira/Confluence lookups to subagents (`iac-explorer`, `tf-plan-reviewer`, `ci-failure-triage`, `atlassian-scribe`).
- Prefer `gh ... --json <fields> --jq <expr>` and `acli ... --fields ... --limit` over MCP tools for routine reads.
- Use the `tf-plan-summary` skill instead of raw `terraform plan` output.

## Git
- Conventional commits only. Local commits for logical units are fine.
- Never add AI attribution ("Generated with Claude Code", Co-Authored-By, etc.) to commits, PRs or any git metadata.
- Never push, force-push, create PRs, `reset --hard`, `clean -f` or delete branches unless I explicitly ask in the current message. Never force-push under any circumstances.
- Never push to main. Work on a feature/fix branch or worktree.
- Ask before any irreversible or publishing action.
- After commits: summarize what changed and stop.
