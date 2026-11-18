# ADR-0003: Repository layout

- **Status:** Superseded by [ADR-0009](0009-repository-layout-top-level-env-and-docs.md)
- **Date:** 2026-11-18

## Context

The team's convention is to keep Terraform code apart from documentation, and to keep each environment's configuration in its own folder.

## Decision

```
/                         docs: INTENT.md, PLAN.md, DIAGRAM.md
docs/adr/                 architecture decision records
terraform/                root module (*.tf, .terraform.lock.hcl)
terraform/env/<env>/      terraform.tfvars, backend.hcl (Stage 1)
```

- All Terraform commands run from `terraform/`, for example `terraform plan -var-file=env/dev/terraform.tfvars`.
- `.terraform.lock.hcl` is committed. `.terraform/` and state files are not.

## Consequences

- Adding an environment means adding a folder under `terraform/env/`. No code changes are needed.
- Terraform won't load `terraform.tfvars` automatically when it's in a subfolder. That's intentional: every plan has to name its environment with `-var-file`.
