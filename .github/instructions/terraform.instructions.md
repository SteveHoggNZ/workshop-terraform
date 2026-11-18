---
description: "Use when writing or editing Terraform (.tf) or tfvars files: naming, tags, AVM modules, variables, version pinning."
applyTo: "terraform/**/*.tf, env/**/*.tfvars"
---
# Terraform Conventions

- **Names:** generate every resource name in `terraform/locals.tf` (`local.names`). Never hard-code a name. See [ADR-0004](../../docs/adr/0004-naming-convention-and-tags.md).
- **Tags:** pass `local.tags` to every resource and module.
- **Modules:** use an Azure Verified Module (`Azure/avm-res-*`) with an exact pinned `version` wherever one exists. If you use a raw `azurerm` resource instead, it needs an ADR ([ADR-0005](../../docs/adr/0005-use-azure-verified-modules.md)).
- **Variables:** every variable gets a `description` and a `type`, plus a `validation` block where the values are constrained.
- **Environment differences** go in `env/<env>/terraform.tfvars` only, never as conditionals on `var.environment` in the code.
- **Formatting:** keep files `terraform fmt`-clean.
- **Lock file:** commit `.terraform.lock.hcl`.
