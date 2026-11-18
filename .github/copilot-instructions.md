# Project Guidelines

Terraform proof of concept for Azure: a spoke VNet with `web` and `mid` tiers, each with Windows VMs behind an internal load balancer. dev and prod are deployed from one root module. See [README.md](../README.md) and [docs/INTENT.md](../docs/INTENT.md).

## Hard rules

- **Plan only.** Never run `terraform apply`, `destroy`, `import`, or any `state` mutation ([ADR-0006](../docs/adr/0006-plan-only-local-state.md)). A hook enforces this.
- Never put secrets in `.tf` or `.tfvars` files. Secrets come from Key Vault.
- Work through the stages in [docs/PLAN.md](../docs/PLAN.md) one at a time. Stop at each gate and show the output.

## Build and validate

Run from the repo root. `-var-file` paths are relative to `terraform/`.

```sh
terraform fmt -check -recursive terraform
terraform -chdir=terraform validate
terraform -chdir=terraform plan -var-file=../env/dev/terraform.tfvars
```

## Architecture decisions

- Record any significant decision as a new ADR in `docs/adr/`, following [ADR-0001](../docs/adr/0001-record-architecture-decisions.md).
- Don't rewrite an accepted ADR. Supersede it with a new one.
- Read the relevant ADRs before changing layout, naming, modules, or network design.

## Commits

Conventional commits. Commit once per stage, or once per restructure.
