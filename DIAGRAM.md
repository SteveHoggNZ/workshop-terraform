# Architecture Diagram

## Per-environment topology

The same code deploys dev and prod. Only the tfvars change. Names are shown for dev, and address ranges are example defaults.

```mermaid
flowchart TB
    subgraph SUB["Subscription: dev (prod is a separate subscription)"]
        subgraph RG["rg-poc-dev-aue-001 (Australia East)"]
            subgraph VNET["vnet-poc-dev-aue-001 (spoke) 10.10.0.0/16"]
                subgraph SNWEB["snet-web-dev-aue-001 10.10.1.0/24"]
                    LBWEB["lbi-web-dev-aue-001<br/>internal LB :443"]
                    W1["vmwebdaue01"]
                    W2["vmwebdaue02"]
                    W3["vmwebdaue03"]
                    W4["vmwebdaue04"]
                end
                subgraph SNMID["snet-mid-dev-aue-001 10.10.2.0/24"]
                    LBMID["lbi-mid-dev-aue-001<br/>internal LB :443"]
                    M1["vmmiddaue01"]
                    M2["vmmiddaue02"]
                    M3["vmmiddaue03"]
                    M4["vmmiddaue04"]
                end
            end
            NSGWEB["nsg-web-dev-aue-001"]
            NSGMID["nsg-mid-dev-aue-001"]
        end
    end

    CLIENT(["Clients (VNet / on-prem)"]) -- "443" --> LBWEB
    LBWEB --> W1 & W2 & W3 & W4
    W1 & W2 & W3 & W4 -- "443" --> LBMID
    LBMID --> M1 & M2 & M3 & M4
    M1 & M2 & M3 & M4 -- "1521" --> ORA[("Oracle DB<br/>existing")]
    W1 & M1 -. "domain join" .-> AD[("Active Directory<br/>existing")]

    NSGWEB -. "attached" .- SNWEB
    NSGMID -. "attached" .- SNMID
```

## NSG rules

```mermaid
flowchart LR
    IN(["Inbound"]) -- "allow 443" --> NSG{{"NSG<br/>web + mid"}}
    NSG -- "allow 1521 outbound" --> ORA[("Oracle DB")]
    NSG -. "deny all other inbound" .-x X(["blocked"])
```

## Terraform layout and environments

```mermaid
flowchart LR
    subgraph CODE["Single root module"]
        TF["main.tf / variables.tf / locals.tf<br/>AVM modules"]
    end
    DEVVARS["env/dev/terraform.tfvars"] --> TF
    PRODVARS["env/prod/terraform.tfvars"] --> TF
    DEVBE["env/dev/backend.hcl"] --> STDEV[("Blob state: dev")]
    PRODBE["env/prod/backend.hcl"] --> STPROD[("Blob state: prod")]
    TF -- "plan -var-file=env/dev/terraform.tfvars" --> DEVSUB["Dev subscription"]
    TF -- "plan -var-file=env/prod/terraform.tfvars" --> PRODSUB["Prod subscription"]
    TF -.-> STDEV
    TF -.-> STPROD
```
