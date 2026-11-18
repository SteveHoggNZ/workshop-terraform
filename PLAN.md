# Plan

We build this one stage at a time and fail fast. Each stage ends with **visible output** and a **review gate**. The next stage only starts once you confirm.

Until Stage 7, all work targets **dev** only.

**Plan only.** We never run `terraform apply`, and nothing is created or changed in Azure. `plan` only reads from Azure.

**Every stage** runs the same checks before showing output: `terraform fmt -check` and `terraform validate`.

All Terraform code lives in `terraform/`, and every command runs from that directory.

---

## Stage 0: Toolchain and naming (no Azure calls)

**Build**
- `versions.tf`: latest stable Terraform plus pinned `azurerm`
- `variables.tf`, `locals.tf`: naming convention and tags
- `outputs.tf`: the generated names
- `dev.tfvars` and `prod.tfvars`

**Output shown**
- A table of every resource name for dev and prod, rendered with `terraform console` / `terraform plan`, plus the tags.

**Gate:** Do the names and tags match the standard?

## Stage 1: Remote state

**Build**
- `backend.tf` with a partial `azurerm` backend
- `backend/dev.hcl` and `backend/prod.hcl`, one Blob container/key per environment, each in its own subscription

**Prerequisite:** The state storage account and container must **already exist**, because we won't create them. If they don't exist yet, we keep local state for planning and switch over later.

**Output shown**
- `terraform init -backend-config=backend/dev.hcl` succeeds
- The state blob location is displayed

**Gate:** Is the state location and layout acceptable?

## Stage 2: Network foundation

**Build** (AVM modules)
- Resource group
- Spoke VNet
- `web` and `middleware` subnets
- NSGs with inbound 443 and outbound 1521

**Output shown**
- `terraform plan -var-file=dev.tfvars` summary: resources, address ranges, NSG rules

**Gate:** Are the address space and NSG rules right?

## Stage 3: Single VM spike (highest risk first)

**Build**
- 1 × Windows Server 2022 DS4 VM in `web` (AVM VM module), with `count = 1` set from tfvars
- Domain join extension, with credentials read from Key Vault

**Output shown**
- Plan output for the VM, its NIC and the domain join extension

**Gate:** Are the image, size, computer naming and domain join settings right?

**Limit:** Without an apply, a plan can only show that the domain join is configured. It cannot prove the VM actually joins the domain.

## Stage 4: Scale the web tier and add its load balancer

**Build**
- Web VM count raised to 4 (from tfvars)
- Internal web load balancer (AVM): backend pool, 443 health probe, rule

**Output shown**
- Plan summary
- LB frontend IP and backend pool membership

**Gate:** Is the web tier correct?

## Stage 5: Middleware tier

**Build**
- 4 × middleware VMs
- Internal middleware load balancer, reusing the Stage 4 pattern

**Output shown**
- Plan summary
- Full dev resource inventory

**Gate:** Is the full dev topology correct?

## Stage 6: Final quality review

**Build**
- A full run of `fmt` and `validate` across the finished code, plus a manual review against INTENT.md. These checks have already run at every stage.

**Output shown**
- Findings report, with fixes applied or any accepted exceptions recorded

**Gate:** Is the code accepted?

## Stage 7: Prod

**Build**
- `terraform plan -var-file=prod.tfvars` against the prod subscription

**Output shown**
- Prod plan, plus a diff of how prod differs from dev (tfvars only)

**Gate:** Does the prod plan match expectations? Any apply happens outside this exercise.

---

## Open items to confirm before Stage 3

1. **Domain:**
   - Domain FQDN, OU path, and the Key Vault/secret name for the join account
   - How a spoke-only VNet reaches the domain controllers. Do we use custom DNS servers on the VNet, and does peering already exist?
2. **Load balancers:** Should both be internal? The assumption is yes, with no public IPs.
3. **Port 443 source:** Allow from where? The assumption is the VirtualNetwork service tag only.
4. **Oracle destination:** What is the CIDR/IP for outbound 1521? The assumption is a variable that defaults to `VirtualNetwork`.
5. **Middleware LB port:** The assumption is 443.
6. **State storage:** Name of the existing storage account and container for each environment, or confirm we use local state for planning.
