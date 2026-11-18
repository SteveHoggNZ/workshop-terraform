# ADR-0009: Repository layout with top-level env/ and docs/

- **Status:** Accepted
- **Date:** 2026-11-18
- **Supersedes:** [ADR-0003](0003-repository-layout.md)

## Context

Under ADR-0003, environment settings sat inside `terraform/` and the documents sat at the repository root. The team convention is different: environments are a top-level concern, and documentation belongs in `docs/` with a README at the root as the entry point.

## Decision

```
README.md                 entry point
docs/                     INTENT.md, PLAN.md, DIAGRAM.md
docs/adr/                 architecture decision records
env/<env>/                terraform.tfvars, backend.hcl (Stage 1)
terraform/                root module (*.tf, .terraform.lock.hcl)
```

- Commands run from the repository root using `-chdir`, for example `terraform -chdir=terraform plan -var-file=../env/dev/terraform.tfvars`.
- Paths given to `-var-file` and `-backend-config` are relative to `terraform/`, so they start with `../env/`.
- `.terraform.lock.hcl` is committed. `.terraform/` and state files are not.

## Consequences

- Adding an environment means adding a folder under `env/`. No code changes are needed.
- Environment settings are separate from code, so they can have their own CODEOWNERS or review rules later.
- The `../` paths are easy to get wrong. The README documents the exact commands.
