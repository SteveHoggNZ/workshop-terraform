---
name: avm-module
description: 'Find, inspect and pin an Azure Verified Module (AVM) for Terraform: latest version, required inputs, outputs and provider dependencies from the public registry. Use when adding or upgrading a module in terraform/, when asked which AVM to use, or before writing a module block for a resource group, VNet, NSG, load balancer, VM or Key Vault.'
argument-hint: 'Resource to build, e.g. "internal load balancer"'
---

# AVM Module

Use an Azure Verified Module with an exact pinned version for every resource ([ADR-0005](../../../docs/adr/0005-use-azure-verified-modules.md)). Get module facts from the registry, never from memory: AVM interfaces change between minor versions.

## Procedure

1. **Find the module.** Run [avm-info.sh](./scripts/avm-info.sh) with a search term:
   ```sh
   .github/skills/avm-module/scripts/avm-info.sh search loadbalancer
   ```
   AVM resource modules are named `avm-res-<provider>-<resource>`.
2. **Read its interface:**
   ```sh
   .github/skills/avm-module/scripts/avm-info.sh avm-res-network-loadbalancer
   .github/skills/avm-module/scripts/avm-info.sh avm-res-network-loadbalancer 0.6.0 --all   # types and defaults
   ```
   If the input types don't answer a question, such as how map keys link resources, read the module's `examples/` and `*.tf` at the `source` URL for that exact tag.
3. **Check providers.** Most AVM modules now use `Azure/azapi`. If a module needs a provider or version not yet in [versions.tf](../../../terraform/versions.tf), add it there with a `~>` constraint and run `terraform -chdir=terraform init -upgrade`.
4. **Write the module block** with:
   - `source = "Azure/<name>/azurerm"` and an exact `version = "x.y.z"`
   - `name` from `local.names` and `tags = local.tags`
   - `enable_telemetry` left at its default unless an ADR says otherwise
5. **Prove it:** run `scripts/plan.sh dev` and read the summary for the module's resources.
6. **Record it.** If no AVM exists and you use a raw resource instead, or you pin an older version on purpose, write an ADR with the `new-adr` skill.
