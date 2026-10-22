#!/usr/bin/env bash
# Summarise a Terraform plan in a few lines.
# Usage: summarise-plan.sh <terraform-dir> [existing-planfile]
set -euo pipefail

dir="${1:?usage: summarise-plan.sh <terraform-dir> [planfile]}"
planfile="${2:-}"
[[ -d "$dir" ]] || { echo "Not a directory: $dir" >&2; exit 1; }

work=$(mktemp -d "${TMPDIR:-/tmp}/tfplan.XXXXXX")
log="$work/plan.log"

if [[ -z "$planfile" ]]; then
  planfile="$work/tfplan"
  set +e
  terraform -chdir="$dir" plan -no-color -input=false -detailed-exitcode -out="$planfile" >"$log" 2>&1
  rc=$?
  set -e
  if [[ $rc -eq 1 ]]; then
    echo "terraform plan failed. Last 40 lines of $log:"
    grep -v '^[[:space:]]*$' "$log" | tail -40
    exit 1
  fi
  if [[ $rc -eq 0 ]]; then
    echo "Plan: no changes."
    exit 0
  fi
else
  # Relative plan files are resolved against the terraform dir, as terraform does
  [[ "$planfile" = /* || -f "$planfile" ]] || planfile="$dir/$planfile"
  [[ -f "$planfile" ]] || { echo "Plan file not found: $planfile" >&2; exit 1; }
  planfile=$(cd "$(dirname "$planfile")" && pwd)/$(basename "$planfile")
fi

terraform -chdir="$dir" show -no-color -json "$planfile" >"$work/plan.json"

jq -r '
  def act:
    .change.actions as $a
    | if $a == ["create"] then "create"
      elif $a == ["update"] then "update"
      elif $a == ["delete"] then "delete"
      elif ($a | index("delete")) and ($a | index("create")) then "replace"
      else ($a | join(",")) end;
  def risky:
    test("^aws_(iam_|organizations_|kms_|route53_|s3_bucket_policy|s3_bucket_public_access_block|security_group|vpc_security_group|iam_openid_connect_provider)");

  [.resource_changes[]? | select(.change.actions != ["no-op"] and .change.actions != ["read"]) | {addr: .address, type: .type, act: act}] as $c
  | ($c | map(select(.act == "create")) | length) as $cr
  | ($c | map(select(.act == "update")) | length) as $up
  | ($c | map(select(.act == "replace")) | length) as $rp
  | ($c | map(select(.act == "delete")) | length) as $de
  | "Plan: \($cr) create, \($up) update, \($rp) replace, \($de) delete",
    ([.resource_drift[]?] | length | if . > 0 then "Drift: \(.) resources changed outside Terraform" else empty end),
    ($c[] | select(.act == "delete" or .act == "replace" or (.type | risky)) | "RISK  \(.act)  \(.addr)"),
    "Changes:",
    ($c[:50][] | "  \(.act)  \(.addr)"),
    (if ($c | length) > 50 then "  ... and \(($c | length) - 50) more" else empty end)
' "$work/plan.json"

echo "Full plan JSON: $work/plan.json"
