# Intent

## Goal

Move a multi-server application that runs in an on-prem data centre into Azure as a proof of concept. Deploy it with Terraform. The code must be reusable, follow our standards, and fit in with the infrastructure we already have.

## Environments

- **dev** and **prod** each live in their **own Azure subscription**.
- **One root module** serves both environments. Environment differences are set only in `env/dev/terraform.tfvars` / `env/prod/terraform.tfvars`.
- Both environments have the **same topology**. Counts, sizes and address ranges are variables, so either environment can be scaled independently.
- Each environment keeps its **own state file** in an **Azure Blob Storage** backend.

## Topology (per environment)

- 1 × Resource Group
- 1 × **Spoke** VNet. Hub, peering and firewall are out of scope.
- 2 × Subnets, each with an NSG:
  - **web** subnet: 4 × VMs behind a **web load balancer**
  - **middleware** subnet: 4 × app server VMs behind a **middleware load balancer**
- NSG rules:
  - Inbound: **443**
  - Outbound: **Oracle DB (1521)**

## Virtual machines

- Windows Server 2022, size DS4 (`Standard_DS4_v2`)
- **Domain joined**
- Server count per tier is a variable (default 4)

## Standards / guardrails

- Use **Azure Verified Modules (AVM)** wherever one exists.
- Follow our naming convention. For this demo we assume a CAF-style pattern: `<type>-<workload>-<env>-<region>-<nnn>`, e.g. `rg-poc-dev-aue-001`. Windows computer names are short forms that fit the 15-character limit.
- Mandatory tag: `supported-by = cloud-team`
- Region: **Australia East**
- Use the latest stable Terraform and `azurerm` provider, with versions pinned.
- Everything else uses sensible defaults:
  - Internal load balancers
  - Zone-redundant placement
  - No public IPs
  - Secrets come from Key Vault and are never stored in code
