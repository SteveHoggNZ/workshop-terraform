# ADR-0007: Toolchain versions and quality checks

- **Status:** Accepted
- **Date:** 2026-11-18

## Context

We want the latest stable tooling, pinned so builds can be reproduced. We considered `tflint` and `checkov` for linting and security scanning, but they couldn't be installed on the workstation.

## Decision

- **Terraform:** `~> 1.17` (developed on 1.17.2).
- **azurerm provider:** `~> 5.14`, with exact versions locked in `.terraform.lock.hcl`.
- **Checks at every stage:** `terraform fmt -check -recursive` and `terraform validate`, then `terraform plan` for the target environment.
- `tflint` and `checkov` are **out of scope for now**.

## Consequences

- Without tflint, there is no automatic check that VM sizes or other Azure values are valid. Errors like that will only show up when Azure is called during `plan`.
- Without checkov, there is no automated security scan. Security posture is reviewed by hand at each stage gate.
- If either tool is adopted later, record it in a new ADR that supersedes this one.
