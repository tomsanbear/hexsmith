# Rust Rules

Read `.claude/rules/style.md` first; this file is the Rust-specific supplement.

## Unsafe code

`unsafe_code = "deny"` at crate level via Cargo lints. Any exception requires a scoped `#[allow(unsafe_code, reason = "...")]` plus a `// SAFETY:` comment explaining the invariant.

## Lint suppressions

- Use `#[expect(lint, reason = "...")]` for temporary suppressions.
- Use `#[allow(lint, reason = "...")]` only for permanent exceptions.
- Suppressions require `reason = "..."`.

## Error handling

- Return `Result<T, E>` with domain-specific errors; prefer `thiserror` for library error enums.
- No `.unwrap()` or `.expect()` in production code. Tests may use them.
- Use `?` for propagation and preserve source errors where possible.

## API signatures

- Bundle 2+ config values into `*Config` structs.
- Bundle 3+ dependencies, or 2+ dependencies with the same erased shape, into `*Deps` structs.
- Bundle per-call inputs into `*Request` structs when signatures would otherwise grow.
- Avoid 4+ user-visible positional arguments.
- Avoid adjacent same-type public arguments; use newtypes or request structs.

## Defaults and builders

- Do not use `Option<T>` for fields that are required at runtime.
- Do not derive or implement `Default` for production structs with required fields.
- Prefer struct literals and explicit constants for optional defaults.
- Use typestate builders only when they materially improve a public API or handle complex defaults.

## Integer types

Use explicit integer sizes for wire, disk, and domain values. Use `usize` for in-memory indexing into Rust collections.

## Async discipline

All I/O should go through Tokio once async code is introduced. CPU-bound work on an async runtime should use `spawn_blocking` where needed.

## Toolchain and checks

- Toolchain is pinned in `rust-toolchain.toml`.
- Full local gate: `make check`.
- Clippy is run with `--all-targets -- -D warnings`.
- Public items require documentation.

## Build profiles and storage hygiene

- Keep debug info compact and dependency opt-level at 1 for warm build speed without disabling cross-crate generic sharing.
- rust-analyzer uses `target/rust-analyzer/` to avoid editor/terminal artifact thrash.
- Use `make rust-sweep` if `cargo-sweep` is installed to remove old artifacts.

## Visibility

`pub` is for the public crate API. Prefer module-private or `pub(crate)` for internals.
