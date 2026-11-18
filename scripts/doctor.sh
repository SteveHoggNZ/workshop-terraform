#!/usr/bin/env bash
# Read-only health check: toolchain, Azure login, git state and the current stage in docs/PLAN.md.
# Run by the sessionStart hook; also safe to run by hand.
set -u
cd "$(dirname "$0")/.." || exit 1

ok() { printf '  ok    %s\n' "$*"; }
warn() { printf '  WARN  %s\n' "$*"; }

echo "Toolchain"
required=$(sed -n 's/.*required_version *= *"\(.*\)".*/\1/p' terraform/versions.tf 2>/dev/null)
if command -v terraform >/dev/null 2>&1; then
  version=$(terraform version 2>/dev/null | head -1 | sed 's/^Terraform v//')
  if [[ $required =~ ^~\>\ *([0-9]+)\.([0-9]+)$ ]]; then
    major=${version%%.*}
    minor=${version#*.}
    minor=${minor%%.*}
    if [[ $major == "${BASH_REMATCH[1]}" && $minor -ge ${BASH_REMATCH[2]} ]]; then
      ok "terraform $version (requires $required)"
    else
      warn "terraform $version does not satisfy $required"
    fi
  else
    ok "terraform $version (requires ${required:-?})"
  fi
else
  warn "terraform not found on PATH"
fi
for tool in az jq node; do
  if command -v "$tool" >/dev/null 2>&1; then ok "$tool found"; else warn "$tool not found (az: Azure plans, jq: plan.sh, node: Copilot hooks)"; fi
done

echo "Azure"
if command -v az >/dev/null 2>&1 && current=$(az account show --query '[name, id]' -o tsv 2>/dev/null | paste -sd ' ' -); then
  ok "az CLI subscription: $current"
else
  warn "not logged in to Azure (az login). Not needed until plans call Azure (Stage 2)."
  current=""
fi
for vars in env/*/terraform.tfvars; do
  env=$(basename "$(dirname "$vars")")
  expected=$(sed -n 's/^[[:space:]]*subscription_id[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' "$vars" | head -1)
  if [[ -z $expected ]]; then
    warn "$env: no subscription_id in $vars, so scripts/plan.sh cannot guard the subscription"
  else
    ok "$env: expects subscription $expected"
  fi
done

echo "Repository"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  changes=$(git status --porcelain | wc -l | tr -d ' ')
  ok "branch $(git branch --show-current), last commit: $(git log -1 --format='%h %s' 2>/dev/null)"
  if [[ $changes == 0 ]]; then ok "working tree clean"; else warn "$changes uncommitted change(s)"; fi
else
  warn "not a git repository"
fi
if [[ -d terraform/.terraform ]]; then ok "terraform/ initialised"; else warn "terraform/ not initialised (scripts/plan.sh runs init)"; fi

echo "Plan status (docs/PLAN.md)"
awk '
  /^## Stage / { stage = substr($0, 4) }
  /^\*\*Status:\*\*/ && stage {
    status = $0; sub(/^\*\*Status:\*\* */, "", status)
    printf "  %-45s %s\n", stage, status
    if (!current && status !~ /^Done/) current = stage
    stage = ""
  }
  END { if (current) printf "  Current stage: %s\n", current }
' docs/PLAN.md 2>/dev/null
