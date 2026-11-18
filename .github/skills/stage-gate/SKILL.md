---
name: stage-gate
description: 'Run the review gate for a stage in docs/PLAN.md: fmt, validate, plan for dev and prod, summarise the output, record ADRs and commit. Use when finishing a stage, when asked to "run the gate", "prove it works", "check the stage", or before asking the user to approve a stage.'
argument-hint: 'Stage number, e.g. 2'
---

# Stage Gate

Proves that a stage from [docs/PLAN.md](../../../docs/PLAN.md) works and shows the evidence before the user approves it. **Plan only: never apply.**

## Procedure

1. Read the stage's **Build**, **Output shown** and **Gate** sections in `docs/PLAN.md`.
2. From the repo root, run the checks and stop at the first failure:
   ```sh
   terraform -chdir=terraform init -input=false
   terraform fmt -check -recursive terraform
   terraform -chdir=terraform validate
   terraform -chdir=terraform plan -input=false -var-file=../env/dev/terraform.tfvars
   ```
   Also run the prod plan when the stage changes anything prod would use.
3. If a check fails, fix the cause and run it again. Don't move to the next stage.
4. Show the user what the stage's **Output shown** section lists. Summarise the plan (`N to add, 0 to change, 0 to destroy`) and point out anything unexpected.
5. Record each decision the stage settled as an ADR in `docs/adr/`. Supersede older ADRs rather than editing them.
6. Commit: `feat(terraform): stage N - <summary>`.
7. Ask the stage's **Gate** question and wait for approval before starting the next stage.
