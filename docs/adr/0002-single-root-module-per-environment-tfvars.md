# ADR-0002: Single root module with per-environment variables

- **Status:** Accepted
- **Date:** 2026-11-18

## Context

The proof of concept needs dev and prod environments with the same topology. The two options were:

1. A separate root folder per environment, each calling shared modules.
2. One root module that runs once per environment, with a different variables file each time.

## Decision

We use **one root module** (option 2).

- Everything that differs between environments lives in that environment's variables file. This includes VM counts, sizes and address ranges.
- Each environment is deployed to its **own Azure subscription**.
- Each environment has its **own state file**.

## Consequences

- dev and prod can't drift apart in code, only in variable values.
- Environment-specific resources must be switched on or off through variables (counts or feature flags), not separate code.
- A code change affects both environments. We protect prod by running a plan against dev first.
