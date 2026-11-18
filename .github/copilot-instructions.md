# Project Guidelines

Terraform proof of concept for Azure, with dev and prod deployed from one root module. See [README.md](../README.md) for layout and commands, and [docs/INTENT.md](../docs/INTENT.md) for scope.

- Never put secrets in `.tf` or `.tfvars` files. Secrets come from Key Vault.
- Work through [docs/PLAN.md](../docs/PLAN.md) one stage at a time, and stop at each gate.
- Read the relevant ADRs in `docs/adr/` before changing layout, naming, modules or network design. Record new decisions as new ADRs, superseding old ones rather than editing them.
- Use conventional commits, one per stage or restructure.
