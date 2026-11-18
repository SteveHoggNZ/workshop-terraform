#!/usr/bin/env bash
# Look up an Azure Verified Module in the public Terraform registry.
#
#   avm-info.sh search <term>                  list matching AVM resource modules
#   avm-info.sh <module> [version] [--all]     version, providers, inputs and outputs
#
# <module> is the short name, e.g. avm-res-network-virtualnetwork. Without --all only
# required inputs are shown in full; optional inputs are listed by name.
set -euo pipefail
api=https://registry.terraform.io/v1/modules

if [[ ${1:-} == search ]]; then
  term="${2:?usage: avm-info.sh search <term>}"
  curl -fsS -m 20 "$api/search?q=$term&namespace=Azure&provider=azurerm&limit=100" \
    | jq -r '.modules[] | select(.name | startswith("avm-res-")) | "\(.name)\t\(.version)\t\(.description // "" | .[0:80])"' \
    | column -t -s $'\t'
  exit 0
fi

module="${1:?usage: avm-info.sh <module> [version] [--all] | avm-info.sh search <term>}"
shift
version=""
all=false
for arg in "$@"; do
  if [[ $arg == --all ]]; then all=true; else version=$arg; fi
done

json=$(curl -fsS -m 20 "$api/Azure/$module/azurerm${version:+/$version}") || {
  echo "Not found: Azure/$module/azurerm${version:+ $version}. Try: avm-info.sh search <term>" >&2
  exit 1
}

jq -r --argjson all "$all" '
  "module:    Azure/\(.name)/azurerm",
  "version:   \(.version)  (published \(.published_at[0:10]))",
  "source:    \(.source)",
  "pin as:    source = \"Azure/\(.name)/azurerm\"  version = \"\(.version)\"",
  "",
  "providers:",
  (.root.provider_dependencies[] | select(.source != "") | "  \(.source) \(.version)"),
  "",
  "required inputs:",
  (.root.inputs[] | select(.required) | "  \(.name): \(.type)\n      \(.description // "" | gsub("\n"; " ") | .[0:200])"),
  "",
  (if $all then
     "optional inputs:",
     (.root.inputs[] | select(.required | not) | "  \(.name) = \(.default // "null" | tostring | .[0:60])\n      type: \(.type | gsub("\n"; " ") | .[0:200])")
   else
     "optional inputs (names; --all for types and defaults):",
     "  " + ([.root.inputs[] | select(.required | not) | .name] | join(", "))
   end),
  "",
  "outputs:",
  (.root.outputs[] | "  \(.name): \(.description // "" | gsub("\n"; " ") | .[0:120])")
' <<<"$json"
