---
paths:
  - "**/*.yml"
  - "**/*.yaml"
---

# YAML and GitHub Actions

- Keep YAML anchors and aliases intact. Many config files rely on them for DRY config.
- Validate with `yamllint <file>` after editing. Respect the repo's `.yamllint` config.
- For files under `.github/workflows/`, also run `actionlint <file>`.
- Pin third-party actions to a full commit SHA with the version as a trailing comment, e.g. `uses: actions/checkout@<sha> # v4.2.2`.
- Set least-privilege `permissions:` at workflow or job level. Default to `contents: read`.
- Use GitHub OIDC (`id-token: write`) for cloud auth. Never add long-lived cloud keys as secrets.
- Never interpolate untrusted input (`github.event.*.title`, `body`, branch names) directly into `run:`. Pass it through `env:`.
- Keep `concurrency:` groups for deployments. Do not add `cancel-in-progress: true` to deploy workflows.
- For CI failures, delegate to `ci-failure-triage` instead of fetching full logs.
