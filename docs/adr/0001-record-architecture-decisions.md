# ADR-0001: Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-11-18

## Context

The design is changing while we build it in stages. Decisions made in chat get lost and are later hard to explain.

## Decision

We record each significant decision as an Architecture Decision Record (ADR) in `docs/adr/`.

- Files are named `NNNN-short-title.md` and numbered in sequence.
- Each ADR has: Status, Date, Context, Decision, Consequences.
- Status values are `Proposed`, `Accepted`, `Superseded by ADR-NNNN`, or `Deprecated`.
- We don't edit an accepted ADR to change its decision. Instead we write a new ADR that supersedes it.

## Consequences

- Reviewers can see why the code looks the way it does.
- Each stage gate in PLAN.md should add or update ADRs for any decision it settles.
