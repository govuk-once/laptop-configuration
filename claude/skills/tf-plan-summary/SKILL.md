---
name: tf-plan-summary
description: Run or read a Terraform plan and print a compact summary (counts, risky changes, changed addresses) instead of raw plan output. Use whenever you need to know what a plan will change.
---

# Terraform plan summary

Raw `terraform plan` output can be thousands of lines.
This script saves the plan to a temp dir and prints at most ~60 lines.

## Usage

Create a plan and summarise it:

```bash
~/.claude/skills/tf-plan-summary/scripts/summarise-plan.sh <terraform-dir>
```

Summarise an existing plan file (for example one written by an Nx `plan` target):

```bash
~/.claude/skills/tf-plan-summary/scripts/summarise-plan.sh <terraform-dir> <planfile>
```

Nx repos (`aws-account-bootstrapping`):

```bash
pnpm nx run accounts-<project>-<env>:plan --skip-nx-cache > /tmp/nx-plan.log 2>&1; tail -5 /tmp/nx-plan.log
~/.claude/skills/tf-plan-summary/scripts/summarise-plan.sh apps/accounts/<project>/<env> tfplan
```

## Output

- `Plan: N create, N update, N replace, N delete`.
- `RISK` lines for deletes, replaces and sensitive resource types (IAM, SCP, KMS, Route53, S3 policy, security groups, OIDC).
- Up to 50 changed addresses with their action.
- The path of the full log, if you need to inspect one resource.

The script needs `terraform` and `jq`, and valid AWS credentials for the target account.
It never applies.
