# Project Guidelines

Terraform proof of concept for Azure, with dev and prod deployed from one root module. See [README.md](../README.md) for layout and commands, and [docs/INTENT.md](../docs/INTENT.md) for scope.

- Plan only: never run `terraform apply`, `destroy`, `import` or state changes ([ADR-0006](../docs/adr/0006-plan-only-local-state.md)). A hook blocks these in the terminal, but it can't cover every route.
- Never put secrets in `.tf` or `.tfvars` files. Secrets come from Key Vault.
- Work through [docs/PLAN.md](../docs/PLAN.md) one stage at a time, and stop at each gate. The **Status** lines there show the current stage, so a new session starts from them.
- Use `scripts/plan.sh <env>` for checks and plans, and `scripts/doctor.sh` for the toolchain and Azure login. Report their real output; never claim a tool is installed or a command ran without seeing it.
- Ask questions as a form, with a recommended default for each.
- Commit before restructuring or rewriting a document. Never overwrite source material such as `docs/INTENT_ORIGINAL.md`; write a new file instead.
- Read the relevant ADRs in `docs/adr/` before changing layout, naming, modules or network design. Record new decisions with the `new-adr` skill, superseding old ones rather than editing them.
- Edit hook scripts in `.github/hooks/scripts/` in place. Never delete or rename one while a hook config points at it.
- Use conventional commits, one per stage or restructure.
