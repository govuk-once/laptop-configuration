---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript

- Follow the repo's ESLint and Prettier config. Do not add new lint disables.
- In Nx workspaces, run targets for the affected project only: `pnpm nx lint <project>`, `pnpm nx test <project>`. Avoid workspace-wide runs.
- Run a single spec while iterating: `pnpm nx test <project> --testFile=<path>`.
- Keep `strict` typing. Avoid `any`; use `unknown` and narrow.
- Co-locate tests with source as `*.spec.ts`, matching the existing pattern.
- Use `pnpm`, not `npm` or `yarn`, where the repo has `pnpm-lock.yaml`. Never edit the lock file by hand.
