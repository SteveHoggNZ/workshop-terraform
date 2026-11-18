---
name: new-adr
description: 'Create a new Architecture Decision Record in docs/adr/ with the next number, the project template, and supersede handling. Use when a decision is made or changed about layout, naming, modules, network, state, tooling or security, when asked to "record a decision", "add an ADR", or when an accepted ADR needs to change.'
argument-hint: 'Decision title, and the ADR it supersedes if any'
---

# New ADR

Follow the format in [ADR-0001](../../../docs/adr/0001-record-architecture-decisions.md).

## Procedure

1. **Check for an existing decision.** List `docs/adr/` and read any ADR on the same topic.
   - If an **Accepted** ADR's decision changes, the new ADR supersedes it. Never edit the old decision text.
   - If the new ADR only adds to an existing one without changing it, write `- **Extends:** [ADR-NNNN](NNNN-title.md)` instead.
2. **Number it** one higher than the highest existing `NNNN-*.md`, zero-padded to 4 digits.
3. **Name the file** `docs/adr/NNNN-short-kebab-title.md`.
4. **Write it** with this template:
   ```markdown
   # ADR-NNNN: Title in sentence case

   - **Status:** Accepted
   - **Date:** YYYY-MM-DD
   - **Supersedes:** [ADR-NNNN](NNNN-title.md)

   ## Context

   What forces the decision. Keep to facts and constraints.

   ## Decision

   What we will do, stated plainly. Use lists or a code block for layouts and values.

   ## Consequences

   What gets easier, what gets harder, and what would make us revisit it.
   ```
   - Leave out the `Supersedes` line when nothing is superseded.
   - Use `Proposed` instead of `Accepted` when the user hasn't confirmed the decision yet.
5. **Update the superseded ADR** by changing only its status line to `- **Status:** Superseded by [ADR-NNNN](NNNN-title.md)`.
6. **Fix references.** Search the repo for links to the superseded ADR in docs, instructions and skills, and point the ones that describe current behaviour at the new ADR.
7. Commit the ADR along with the change it records, not on its own.
