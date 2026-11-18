#!/usr/bin/env bash
# Usage: scripts/plan.sh [--outputs] <env> [extra terraform plan args]
#
# Runs init, fmt -check, validate and plan for one environment, then prints a compact
# summary. Plan only: never applies. The full plan log is kept in .plans/<env>.plan.log.
#
# Subscription guard: if env/<env>/terraform.tfvars sets subscription_id, the plan runs
# against exactly that subscription and fails if the current Azure login can't see it.
set -euo pipefail
cd "$(dirname "$0")/.."

show_outputs=false
if [[ ${1:-} == --outputs ]]; then
  show_outputs=true
  shift
fi
env="${1:?usage: scripts/plan.sh [--outputs] <env> [extra terraform plan args]}"
shift
vars="env/$env/terraform.tfvars"
[[ -f $vars ]] || { echo "No such environment: $vars" >&2; exit 2; }
mkdir -p .plans
log=".plans/$env.plan.log"
planfile="../.plans/$env.tfplan"

expected=$(sed -n 's/^[[:space:]]*subscription_id[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' "$vars" | head -1)
if [[ -n $expected ]]; then
  if [[ -n ${ARM_SUBSCRIPTION_ID:-} && $ARM_SUBSCRIPTION_ID != "$expected" ]]; then
    echo "Subscription guard: ARM_SUBSCRIPTION_ID is $ARM_SUBSCRIPTION_ID but $env expects $expected." >&2
    exit 3
  fi
  if ! az account show --subscription "$expected" --query id -o tsv >/dev/null 2>&1; then
    echo "Subscription guard: $env expects $expected, which the current az login can't access. Run az login." >&2
    exit 3
  fi
  export ARM_SUBSCRIPTION_ID=$expected
  echo "subscription: $expected (from $vars)"
elif [[ -n ${ARM_SUBSCRIPTION_ID:-} ]]; then
  echo "WARN: no subscription_id in $vars; using ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID unguarded." >&2
elif current=$(az account show --query id -o tsv 2>/dev/null); then
  export ARM_SUBSCRIPTION_ID=$current
  echo "WARN: no subscription_id in $vars; using the az CLI subscription $current unguarded." >&2
else
  echo "WARN: not logged in to Azure and no subscription_id in $vars. Plans that call Azure will fail." >&2
fi

step() { printf '%-10s' "$1"; }

step init
terraform -chdir=terraform init -input=false -no-color >"$log" 2>&1 || { echo FAILED; cat "$log"; exit 1; }
echo ok

step fmt
if ! out=$(terraform fmt -check -recursive -no-color terraform 2>&1); then
  echo "FAILED, files need formatting:"
  echo "$out"
  exit 1
fi
echo ok

step validate
terraform -chdir=terraform validate -no-color >"$log" 2>&1 || { echo FAILED; cat "$log"; exit 1; }
echo ok

step plan
terraform -chdir=terraform plan -input=false -no-color -out="$planfile" -var-file="../$vars" "$@" >"$log" 2>&1 \
  || { echo FAILED; tail -40 "$log"; echo "(full log: $log)"; exit 1; }
echo "ok (full log: $log)"
echo

terraform -chdir=terraform show -json "$planfile" | jq -r '
  def sym: if . == ["create"] then "+ create "
    elif . == ["update"] then "~ update "
    elif . == ["delete"] then "- destroy"
    elif (. == ["delete","create"] or . == ["create","delete"]) then "-/+ replace"
    else join("/") end;
  [.resource_changes[]? | select(.change.actions != ["no-op"] and .change.actions != ["read"])] as $rc
  | [.output_changes // {} | to_entries[] | select(.value.actions != ["no-op"])] as $oc
  | (if ($rc | length) == 0 then "No resource changes." else ($rc[] | "  \(.change.actions | sym)  \(.address)") end),
    "",
    "Plan: \([$rc[] | select(.change.actions | index("create"))] | length) to add, \([$rc[] | select(.change.actions == ["update"])] | length) to change, \([$rc[] | select(.change.actions | index("delete"))] | length) to destroy.",
    (if ($oc | length) > 0 then "Outputs changing: \($oc | map(.key) | join(", "))" else empty end)'

if $show_outputs; then
  echo
  terraform -chdir=terraform show -json "$planfile" \
    | jq '.planned_values.outputs // {} | map_values(if .sensitive then "(sensitive)" else .value end)'
fi
