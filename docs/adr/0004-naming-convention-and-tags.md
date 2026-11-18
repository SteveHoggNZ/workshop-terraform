# ADR-0004: Naming convention and mandatory tags

- **Status:** Accepted (demo convention; replace with the organisation standard when available)
- **Date:** 2026-11-18

## Context

New resources must fit in with the existing estate. The organisation's real naming standard wasn't available, so we use a convention in the style of the Microsoft Cloud Adoption Framework (CAF).

## Decision

- **Resources:** `<type>-<name>-<env>-<region>-<nnn>`.
  - `<name>` is the workload for shared resources and the tier for tier resources. Examples: `rg-poc-dev-aue-001`, `snet-web-dev-aue-001`, `lbi-mid-prod-aue-001`.
- **VMs:** `vm<tier><e><region><nn>`, so names fit the 15-character Windows computer-name limit. Examples: `vmwebdaue01`, `vmmidpaue04`.
- **Region short codes:** `australiaeast = aue`, `australiasoutheast = aus`.
- **Tags:**
  - Mandatory: `supported-by = cloud-team`, `environment`, `workload`, `managed-by = terraform`.
  - These are merged last, so variables can't override them.
- All names are generated in `terraform/locals.tf`. No resource has a hand-written name.

## Consequences

- Changing the convention is a one-file change. However, renaming existing Azure resources forces them to be replaced.
- Tier keys are limited to three lowercase letters, which keeps VM names within 15 characters.
