# ADR-0005: Use Azure Verified Modules

- **Status:** Accepted
- **Date:** 2026-11-18

## Context

We want reusable code that follows Microsoft's guidance, without maintaining our own modules for standard resources.

## Decision

- Where an Azure Verified Module (AVM) exists, we use it for each resource type: resource group, virtual network, network security group, virtual machine and load balancer.
- Module versions are pinned exactly and upgraded deliberately.
- We only write raw `azurerm` resources when no AVM module exists or it can't express what we need. Each such case gets its own ADR.

## Consequences

- Less code to maintain, and built-in support for things like diagnostics and role assignments.
- Our design depends on each module's inputs and outputs. Module upgrades can introduce breaking changes, so they need a plan review.
