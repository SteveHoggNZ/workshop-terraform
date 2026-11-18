# workshop-terraform

Terraform for an Azure proof of concept: a spoke network with a web tier and a middleware tier. Each tier has 4 Windows Server 2022 VMs that are domain-joined and sit behind an internal load balancer. dev and prod are deployed from the same code into separate subscriptions.

> **Plan only.** This repo is used to run `terraform plan`. Nothing is applied. See [ADR-0006](docs/adr/0006-plan-only-local-state.md).

## Layout

```
README.md
docs/          intent, staged plan, architecture diagram, ADRs
env/<env>/     per-environment variables (and backend config, from Stage 1)
terraform/     root module
```

## Prerequisites

- Terraform `~> 1.17`
- Azure CLI, logged in (`az login`) with the target subscription selected

## Usage

Run from the repository root:

```sh
terraform -chdir=terraform init
terraform fmt -check -recursive terraform
terraform -chdir=terraform validate
terraform -chdir=terraform plan -var-file=../env/dev/terraform.tfvars
terraform -chdir=terraform plan -var-file=../env/prod/terraform.tfvars
```

Paths passed to `-var-file` are relative to `terraform/`.

## Docs

- [Intent](docs/INTENT.md): what we're building and why
- [Plan](docs/PLAN.md): staged delivery with review gates
- [Diagram](docs/DIAGRAM.md): architecture
- [ADRs](docs/adr/): architecture decision records
