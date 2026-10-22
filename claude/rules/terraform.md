---
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.hcl"
---

# Terraform

- Never read `*.tfstate*`, `*.tfvars` or `.terraform/`. Never run `terraform state pull` or `terraform show` on state.
- Never run `terraform apply` or `terraform destroy`. I run those myself.
- For plans, use the `tf-plan-summary` skill or delegate to `tf-plan-reviewer`. Never stream a raw plan into the conversation.
- Always pass `-no-color` and `-input=false` to terraform commands you run.
- After editing, run `terraform fmt` and `terraform validate` (or the repo's Nx targets: `pnpm nx run <project>:fmt`, `:validate`).
- Run `tflint` where the repo has a `.tflint.hcl`.
- Pin provider and module versions. Never use unpinned `source` refs.
- Prefer `for_each` over `count` for anything that has identity. Changing keys or indexes destroys resources.
- Flag any change that forces replacement, deletes a resource, or touches IAM, SCPs, KMS, Route53 or S3 bucket policies.
- Use `moved` blocks for refactors instead of letting resources be destroyed and recreated.
- Mark secrets `sensitive = true`. Never hardcode credentials. Keep account IDs in config YAML where the repo already does that.
- Follow existing variable naming and tagging patterns in the repo. Check neighbouring accounts or modules before inventing a new pattern.
