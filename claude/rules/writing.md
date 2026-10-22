---
paths:
  - "**/*.md"
  - "**/*.mdx"
  - "**/*.txt"
---

# Writing Markdown and prose

- When writing or substantially editing long Markdown files, put each full sentence on its own line. Keep normal Markdown structure.
- Never use em dashes (—). The `emdash-check` hook blocks them. Replace by context:
  - Parenthetical or aside: use `,` or `()`. "Once Platform team, across both GitHub and AWS".
  - Sharp emphasis or break: use `;` or restructure. "We need a solution; act now".
  - Introducing a list: use `:`. "Three options: A, B, or C".
  - Keep hyphens in compound words (`aws-account-bootstrapping`) and CLI flags (`--flag`).
- Short sentences. One idea per sentence. Active voice.
- Explain jargon the first time it appears.
- Back claims with a number, an example or a link.
- Save generated documents and the scripts that build them in `~/Desktop/GDS/GitHub/z-Misc`.
