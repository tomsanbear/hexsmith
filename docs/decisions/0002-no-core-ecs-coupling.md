# 0002: Do not couple the core crate to a specific ECS

## Status

Accepted.

## Context

ECS crates such as `bevy_ecs`, `hecs`, and `shipyard` are useful, but `hexsmith` should not be tied to Bevy or another specific ECS. The crate needs to remain suitable for headless simulation, replay verification, agent harnesses, CLI/server runners, and future optional integrations.

## Decision

The authoritative `hexsmith` core will use a custom deterministic domain model rather than adopting a specific ECS implementation as the source of truth.

The public API may expose ECS-inspired concepts where useful:

- stable entities
- typed state/resources
- queryable views
- commands and command arguments
- deterministic rule evaluators

Optional adapters can bridge to ECS/game frameworks later.

## Consequences

- The core crate avoids a required Bevy/ECS dependency.
- Deterministic storage, ordering, IDs, replay, and hashing remain under project control.
- Adapters such as `hexsmith-bevy` can be introduced later without changing the authoritative model.
- We may still borrow ECS terminology and ergonomics for query/command APIs.
