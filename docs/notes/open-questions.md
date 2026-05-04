# Open Questions

## Determinism contract

- Which platforms are officially supported for byte-identical replay?
- Should state hashes be emitted after every command, turn, or configurable checkpoint?
- What is the canonical replay file format?

## Rule/schema system

- Will rules be schema-first, DSL-first, or generated from the future Python reference implementation?
- Which rule categories should compile to Rust code vs remain interpreted data?
- How are rule/schema versions represented in replay logs?

## State model

- What are the stable entity ID types?
- Which data should be dense arrays vs sparse maps?
- What is the canonical ordering for entities, commands, effects, and events?

## Harness API

- Should external agents interact through Rust APIs only, or also JSON/RPC schemas?
- How should legal commands and typed arguments be exposed?
- What state-query granularity is needed for agents and test harnesses?

## Parallelism and acceleration

- Where is Rayon allowed?
- Where is Tokio allowed?
- Which computations may be non-authoritative accelerators?
