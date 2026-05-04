# Coding Style

These project rules are adapted from Catalyzed's TigerStyle-inspired rules.

## Meta-rule: always say WHY

When a rule conflicts with a local constraint, document why in comments, commit messages, PRs, or design docs. Unexplained choices are decisions nobody can revisit.

## Design hierarchy

Prefer safety, then performance, then developer experience. Never trade correctness or determinism for speed or ergonomics without an explicit reason.

## Control flow

- No unbounded recursion; prefer iteration with an explicit work list.
- Every loop should have an understandable upper bound or reachable break condition.
- Push validation branches up and keep hot-loop bodies simple where practical.

## Error handling

- Expected errors flow through typed errors, not panics.
- Errors should name what went wrong concretely.
- Do not silently swallow errors.

## Comments

- Explain WHY, not WHAT.
- Avoid tombstone comments and change-log narration.
- Default to no comment unless it preserves a non-obvious constraint or invariant.

## Naming

- Put units last: `size_bytes`, `duration_ms`, `capacity_rows`.
- Avoid abbreviations that need a glossary.
- Avoid single-letter names outside tight loops.

## Determinism

Use ordered containers when iteration order is observable in tests, protocol output, logs, or files. Prefer deterministic output over incidental hash ordering.

## Technical debt

TODOs committed to main should reference an issue or clearly state why the crate is still pre-alpha. Remove untracked TODOs before stabilization.
