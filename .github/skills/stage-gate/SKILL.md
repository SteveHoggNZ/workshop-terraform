---
name: stage-gate
description: 'Run the review gate for a stage in docs/PLAN.md: checks and plans for dev and prod via scripts/plan.sh, summarise the output, record ADRs, ask for approval as a form, update the stage status and commit. Use when finishing a stage, when asked to "run the gate", "prove it works", "check the stage", or before asking the user to approve a stage.'
argument-hint: 'Stage number, e.g. 2'
---

# Stage Gate

Proves that a stage from [docs/PLAN.md](../../../docs/PLAN.md) works and shows the evidence before the user approves it. **Plan only: never apply.**

## Procedure

1. Read the stage's **Build**, **Output shown**, **Gate** and **Status** in `docs/PLAN.md`. If an earlier stage isn't `Done`, stop and say so.
2. From the repo root, run the checks and plans. Each stops at the first failure:
   ```sh
   scripts/plan.sh --outputs dev
   scripts/plan.sh prod
   ```
   Run the prod plan whenever the stage changes anything prod uses. The full plan log is in `.plans/<env>.plan.log`.
3. If a check fails, fix the cause and run it again. Don't move to the next stage.
4. Show the user what the stage's **Output shown** section lists, using the real command output. Summarise the plan (`N to add, 0 to change, 0 to destroy`) and point out anything unexpected.
5. Record each decision the stage settled as an ADR using the `new-adr` skill.
6. Set the stage's status to `Built, awaiting gate approval` and commit: `feat(terraform): stage N - <summary>`.
7. Ask the stage's **Gate** question **as a form** (the ask-questions tool), with the choices "Approve", "Changes needed" and a free-text field for comments.
   - Only an explicit "Approve" from the user counts. A skipped form, a timeout or an automatic answer such as "the user is not available" is **not** approval: leave the status as it is and stop.
   - On approval, set the status to `Done (approved YYYY-MM-DD)`, set the next stage to `In progress`, and commit both as `docs: approve stage N`.
   - On "Changes needed", make the changes and run this procedure again.
