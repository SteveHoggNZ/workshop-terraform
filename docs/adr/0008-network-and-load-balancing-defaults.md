# ADR-0008: Network and load-balancing defaults

- **Status:** Proposed (confirm at the Stage 2 and Stage 4 gates)
- **Date:** 2026-11-18

## Context

Each environment is a spoke virtual network with two tiers. Each tier has 4 Windows Server 2022 DS4 VMs that are domain-joined. Both tiers sit behind load balancers. Required traffic is 443 inbound and Oracle DB outbound.

## Decision

- **Network:**
  - One spoke VNet per environment.
  - No hub, peering or firewall in scope.
- **Subnets:**
  - `web` and `mid`, each with its own NSG.
- **NSG rules:**
  - Allow 443 inbound from `VirtualNetwork`.
  - Allow 1521 outbound to a configurable destination.
  - Deny all other inbound traffic.
- **Load balancers:**
  - Standard SKU, internal only: one for `web`, one for `mid`.
  - Both listen on 443 and use a 443 health probe.
- **No public IPs** anywhere.
- **VMs:** spread across availability zones. Secrets such as the domain-join account come from Key Vault and are never stored in code or variables files.

## Consequences

- The web tier can't be reached from the internet. Exposing it publicly would need a new ADR covering an internet-facing load balancer or Application Gateway/WAF.
- Domain join depends on the spoke being able to reach the domain controllers (through DNS and routing). That connection is outside this design and is still an open item in PLAN.md.
