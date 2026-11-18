# workshop-terraform

Terraform for an Azure proof of concept: a spoke network with a web tier and a middleware tier. Each tier has 4 Windows Server 2022 VMs that are domain-joined and sit behind an internal load balancer. dev and prod are deployed from the same code into separate subscriptions.

> **Plan only.** This repo is used to run `terraform plan`. Nothing is applied. See [ADR-0006](docs/adr/0006-plan-only-local-state.md).

## Layout

```
README.md
docs/          intent, staged plan, architecture diagram, ADRs
env/<env>/     per-environment variables (and backend config, from Stage 1)
scripts/       doctor.sh (environment check) and plan.sh (checks + plan + summary)
terraform/     root module
```

## Prerequisites

- Terraform `~> 1.17`, `jq`, and Node (for the Copilot hooks)
- Azure CLI, logged in (`az login`) with the target subscription selected

Run `scripts/doctor.sh` to check all of these.

## Usage

Run from the repository root:

```sh
scripts/plan.sh --outputs dev   # init, fmt -check, validate, plan, summary and output values
scripts/plan.sh prod
```

`plan.sh` keeps the full plan log in `.plans/<env>.plan.log`. If `env/<env>/terraform.tfvars` sets `subscription_id`, it refuses to plan against any other subscription.

The underlying commands, if you need them:

```sh
terraform -chdir=terraform init
terraform fmt -check -recursive terraform
terraform -chdir=terraform validate
terraform -chdir=terraform plan -var-file=../env/dev/terraform.tfvars
terraform -chdir=terraform plan -var-file=../env/prod/terraform.tfvars
```

Paths passed to `-var-file` are relative to `terraform/`.

## Working with Copilot

| What | Where |
|---|---|
| Project rules | [.github/copilot-instructions.md](.github/copilot-instructions.md), and [terraform.instructions.md](.github/instructions/terraform.instructions.md) for `.tf`/`.tfvars` |
| Skills | `/stage-gate`, `/avm-module`, `/new-adr` in [.github/skills/](.github/skills/) |
| Hooks | Plan only, no secrets in Terraform files, `terraform fmt` after edits, and environment facts at session start ([ADR-0010](docs/adr/0010-helper-scripts-and-agent-guard-rails.md)) |

Start a new chat for each stage. The **Status** lines in [docs/PLAN.md](docs/PLAN.md) tell it where to pick up. For staged work, use the **Copilot** harness with **Default** or **Auto-approve** permissions, not autopilot: autopilot answers gate questions itself.

## Docs

- [Intent](docs/INTENT.md): what we're building and why
- [Plan](docs/PLAN.md): staged delivery with review gates
- [Diagram](docs/DIAGRAM.md): architecture
- [ADRs](docs/adr/): architecture decision records
