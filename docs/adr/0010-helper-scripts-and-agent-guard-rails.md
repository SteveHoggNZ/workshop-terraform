# ADR-0010: Helper scripts and agent guard rails

- **Status:** Accepted
- **Date:** 2026-11-19
- **Extends:** [ADR-0009](0009-repository-layout-top-level-env-and-docs.md)

## Context

Reviewing the first working session showed where time was lost:

- Tools were assumed to be installed when they weren't.
- Long plan output was filtered by hand.
- Stage gates were skipped when the chat ran in autopilot.
- The plan-only hook was written for the Copilot harness, but the session ran on the Local harness, which sends a different payload, so the hook would have let everything through.

From Stage 2 on, plans call Azure, and dev and prod use different subscriptions. Stage 3 adds domain-join credentials, which are the most likely secret to be hard-coded.

## Decision

Add `scripts/` to the layout in ADR-0009, plus a generated `.plans/` folder that git ignores:

```
scripts/doctor.sh         read-only check: toolchain, Azure login, git state, current stage
scripts/plan.sh <env>     subscription guard, init, fmt -check, validate, plan, compact summary
.plans/                   plan files and logs (not committed)
```

- **Subscription guard:** when `env/<env>/terraform.tfvars` sets `subscription_id`, `plan.sh` plans against exactly that subscription. It fails if `ARM_SUBSCRIPTION_ID` points elsewhere or the current login can't access it.
- **Hooks** in `.github/hooks/`:

  | Hook | Event | What it does |
  |---|---|---|
  | `terraform-plan-only` | before a tool runs | Denies terraform/tofu `apply`, `destroy`, `import`, `taint`, `untaint`, `force-unlock` and state changes |
  | `terraform-no-secrets` | before a tool runs | Denies edits that write literal secrets into `.tf`/`.tfvars` |
  | `terraform-fmt` | after a tool runs | Runs `terraform fmt` on edited Terraform files and tells the agent |
  | `session-context` | session start | Gives the agent the `doctor.sh` report |

- **Both harnesses:** the hook scripts accept both the Copilot (camelCase) and the Local (snake_case) payloads, and write both output shapes. They filter tool calls themselves, because the Local harness ignores matchers.
- **Failure behaviour:**
  - If a hook script is missing, its command returns no decision, so a half-finished edit can't block every tool.
  - If a script crashes, the Copilot harness denies the tool call.
- **Stage status** is tracked in `docs/PLAN.md`. Only an explicit user approval in the gate form marks a stage `Done`.

## Consequences

- Each new session starts from facts about the environment, and from the current stage instead of the chat history. This allows one session per stage.
- Hooks are guard rails, not a security boundary. They don't see commands run outside the agent, and a determined workaround, such as writing a file through a shell redirect, gets past them.
- Every tool call starts a few short Node processes for the hooks.
- The subscription guard only works once `subscription_id` is set per environment. `doctor.sh` warns until then.
