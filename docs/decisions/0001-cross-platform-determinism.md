# 0001: Target cross-platform deterministic replay

## Status

Accepted.

## Context

`hexsmith` will power simulation systems where reproducible state is critical. A log of actions taken in the system must be replayable on any supported host/platform and produce the same authoritative state.

## Decision

`hexsmith` targets cross-platform deterministic replay as a core invariant.

The engine should be reproducible from:

- initial state
- rule/schema versions
- deterministic seed material
- ordered action log

Authoritative simulation code should avoid platform-dependent behavior.

## Consequences

- Prefer integer and fixed-point arithmetic over floating point for authoritative state transitions.
- Use stable logical IDs and canonical ordering.
- Do not rely on `HashMap`/`HashSet` iteration order for authoritative behavior or hashing.
- Use canonical serialization for replay/state hashing.
- Use a stable hash such as BLAKE3 for state verification.
- Async/parallel work may support the engine, but authoritative state mutation must happen in deterministic commit phases.
- GPU compute should not directly affect authoritative state unless results are quantized and CPU-validated.
