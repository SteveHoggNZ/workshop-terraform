# ADR-0006: Plan-only delivery with local state for now

- **Status:** Accepted
- **Date:** 2026-11-18

## Context

This work proves the design. It must not change anything in Azure. Remote state in Azure Blob Storage is the target, but no storage account has been set up yet.

## Decision

- We only run `terraform plan`, never `terraform apply`. `plan` reads from Azure but doesn't change it.
- State stays **local** until an existing storage account and container are provided for each environment. We then move it to the `azurerm` backend using `terraform/env/<env>/backend.hcl`.
- Planning uses the subscription currently selected in the Azure CLI.

## Consequences

- Plans prove the configuration is valid and what it would create, but not runtime behaviour. For example, a plan can't prove a VM actually joins the domain.
- Local state files must never be committed. `.gitignore` enforces this.
