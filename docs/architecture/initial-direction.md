# Initial Architecture Direction

`hexsmith` is a deterministic Rust game-engine harness for sequential Civilization VI-style simulation. It is not an AI implementation and is not initially a rendering/game-client crate.

## Goals

- deterministic, cross-platform replay
- queryable authoritative state
- queryable legal commands and typed command args
- schema/rule-driven game logic
- build-time validation/code generation where practical
- efficient hex-map spatial computation
- async-friendly harness boundaries without nondeterministic simulation mutation

## Non-goals for the core crate

- graphical rendering
- implementing a specific AI strategy
- coupling to Bevy or another ECS/game engine
- authoritative GPU-dependent simulation

## Tentative crate areas

Potential future split:

```text
hexsmith-core        # deterministic state, commands, rules, replay
hexsmith-schema      # schema parsing/codegen pipeline
hexsmith-macros      # proc macros
hexsmith-agent-api   # query/command interface types
hexsmith-bevy        # optional adapter later
```

The current crate can start as a single library while preserving boundaries in modules and docs.

## Likely foundational crates to evaluate

- `serde`
- `postcard` or configured `bincode`
- `blake3`
- `fixed`
- `rand_chacha`
- `hexx`
- `pathfinding`
- `petgraph`
- `rayon`
- `tokio`
- `schemars` / `jsonschema` / `typify`
- `syn` / `quote` / `proc-macro2` / `darling`
- `phf`
