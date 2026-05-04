## Research Findings So Far


### Round 1

#### Researcher 1: Rust crates for deterministic simulation game engine schema parsing compile-time macro codegen ECS async tokio task dispatch hex grid spatial computation AI planning hardware acceleration CPU GPU SIMD crates recommendations

<search queries="Rust deterministic simulation game engine ECS fixed timestep crates bevy hecs legion shipyard specs async tokio task dispatch; Rust schema parsing compile time macro codegen crates serde schemars pest nom chumsky proc macro; Rust hex grid spatial computation crates hexx hex2d pathfinding; Rust AI planning GOAP behavior tree utility AI crates; Rust SIMD GPU hardware acceleration crates wgpu rayon wide packed_simd portable_simd" />

## Rust Crates for Deterministic Simulation Game Engine: Schema Parsing, Compile-Time Codegen, ECS, Async Task Dispatch, Hex Grids, AI Planning, CPU/GPU/SIMD

### Executive Summary

For a deterministic Rust simulation/game engine with hex-grid spatial logic, schema-driven content, compile-time macro/codegen, ECS architecture, async/background task dispatch, AI planning, and optional hardware acceleration, the strongest crate stack is likely:

- **ECS / engine core**: `bevy_ecs` or `hecs`; use `bevy_tasks` / `async-executor` / `rayon` for tasking.
- **Determinism**: avoid floating-point where possible; use fixed-point crates like `fixed`, deterministic RNG such as `rand_chacha`, explicit tick scheduling, stable iteration order, and deterministic serialization.
- **Schema / data parsing**: `serde`, `serde_json`, `ron`, `toml`, `schemars`, `jsonschema`, `typify`, `pest`, `nom`, or `chumsky` depending on whether the schema is structured config or a custom DSL.
- **Compile-time macro/codegen**: `proc-macro2`, `syn`, `quote`, `darling`, `proc-macro-crate`, `inventory`, `linkme`, `build.rs`, and optionally `macro_rules_attribute`.
- **Hex-grid spatial computation**: `hexx` is currently one of the most directly useful crates for hex coordinates, neighbors, ranges, rings, and Bevy integration.
- **Pathfinding / AI**: `pathfinding`, `petgraph`, `big-brain`, `bonsai-bt`, `behavior-tree-lite`, or custom GOAP/HTN logic.
- **CPU parallelism / SIMD**: `rayon`, `wide`, `glam`, `nalgebra`, `ndarray`, and Rust `std::simd`/portable SIMD where toolchain support allows.
- **GPU acceleration**: `wgpu`, `vulkano`, `rust-gpu`, `pollster`, `bytemuck`, and `encase`.

For a deterministic sim, the biggest architectural warning is that **Tokio-style async is not automatically deterministic**. Use async for I/O, asset loading, networking, and background compute, but commit all state mutations back to the simulation only at deterministic tick boundaries.

---

### Comprehensive Findings

#### 1. Deterministic Simulation Architecture

- **Detailed Finding**: Deterministic simulation in Rust is less about a single crate and more about discipline: fixed timestep, deterministic scheduling, stable entity ordering, deterministic RNG, deterministic serialization, and avoidance of nondeterministic floating-point behavior. ECS frameworks can support deterministic workloads, but most do not guarantee full simulation determinism by default. Bevy’s ECS, for example, is highly capable, but scheduling order and parallel system execution need to be explicitly constrained where determinism matters.
  Sources: [https://bevyengine.org/](https://bevyengine.org/), [https://docs.rs/bevy_ecs/latest/bevy_ecs/](https://docs.rs/bevy_ecs/latest/bevy_ecs/)

- **Recommended crates**:
  - `fixed` for fixed-point arithmetic: [https://docs.rs/fixed/latest/fixed/](https://docs.rs/fixed/latest/fixed/)
  - `rand_chacha` for reproducible RNG streams: [https://docs.rs/rand_chacha/latest/rand_chacha/](https://docs.rs/rand_chacha/latest/rand_chacha/)
  - `ordered-float` only if floats are unavoidable and need ordering: [https://docs.rs/ordered-float/latest/ordered_float/](https://docs.rs/ordered-float/latest/ordered_float/)
  - `rust_decimal` for base-10 deterministic decimal arithmetic, usually more business/data oriented than game-sim oriented: [https://docs.rs/rust_decimal/latest/rust_decimal/](https://docs.rs/rust_decimal/latest/rust_decimal/)

- **Analysis**: If the simulation must be replayable or lockstep-networked, prefer integer/fixed-point math for authoritative state. Floating-point may be acceptable for rendering, interpolation, UI, animation, and non-authoritative prediction.

---

#### 2. ECS Choices

- **Detailed Finding**: The main Rust ECS options are `bevy_ecs`, `hecs`, `legion`, `shipyard`, and `specs`. `bevy_ecs` is probably the best-supported modern choice because it is actively maintained as part of Bevy, has a powerful scheduler, query system, resources, events/messages, and ecosystem integrations. `hecs` is smaller and simpler. `shipyard` offers a full-featured standalone ECS with borrow-checking-centered APIs. `specs` and `legion` are historically important but are less compelling for new projects than `bevy_ecs` or `hecs`.
  Sources: [https://docs.rs/bevy_ecs/latest/bevy_ecs/](https://docs.rs/bevy_ecs/latest/bevy_ecs/), [https://docs.rs/hecs/latest/hecs/](https://docs.rs/hecs/latest/hecs/), [https://docs.rs/shipyard/latest/shipyard/](https://docs.rs/shipyard/latest/shipyard/), [https://docs.rs/specs/latest/specs/](https://docs.rs/specs/latest/specs/)

- **Recommendations**:
  - Use **`bevy_ecs`** if you want scheduling, resources, events, reflection compatibility, and future Bevy ecosystem leverage.
  - Use **`hecs`** if you want a minimal, lightweight ECS and plan to build your own deterministic scheduler.
  - Use **`shipyard`** if you want a standalone ECS with rich features and no Bevy dependency.

- **Analysis**: For deterministic simulation, the ECS crate matters less than the scheduler policy. You should define explicit phases such as:
  1. collect intents,
  2. resolve conflicts,
  3. apply mutations,
  4. emit events,
  5. produce render snapshot.

---

#### 3. Async, Tokio, and Task Dispatch

- **Detailed Finding**: `tokio` is excellent for networking, timers, async I/O, and service-style concurrency, but its work-stealing runtime and async scheduling are not deterministic by design. For simulation ticks, async work should not directly mutate authoritative ECS state. Instead, use channels or task pools to return results that are committed in deterministic order.
  Sources: [https://tokio.rs/](https://tokio.rs/), [https://docs.rs/tokio/latest/tokio/), [https://docs.rs/rayon/latest/rayon/](https://docs.rs/rayon/latest/rayon/)

- **Useful crates**:
  - `tokio` for networking/I/O: [https://docs.rs/tokio/latest/tokio/](https://docs.rs/tokio/latest/tokio/)
  - `rayon` for CPU data parallelism: [https://docs.rs/rayon/latest/rayon/](https://docs.rs/rayon/latest/rayon/)
  - `crossbeam-channel` for deterministic queues: [https://docs.rs/crossbeam-channel/latest/crossbeam_channel/](https://docs.rs/crossbeam-channel/latest/crossbeam_channel/)
  - `flume` for ergonomic channels: [https://docs.rs/flume/latest/flume/](https://docs.rs/flume/latest/flume/)
  - `bevy_tasks` if using Bevy ecosystem: [https://docs.rs/bevy_tasks/latest/bevy_tasks/](https://docs.rs/bevy_tasks/latest/bevy_tasks/)

- **Analysis**: Best pattern:
  - Run expensive pathfinding/planning jobs asynchronously.
  - Tag jobs with deterministic IDs.
  - Collect completed outputs.
  - Sort outputs by tick/entity/job ID.
  - Apply them during the next simulation commit phase.

---

#### 4. Schema Parsing and Data Definition

- **Detailed Finding**: Rust has excellent structured data parsing via `serde`, plus schema validation through `schemars` and `jsonschema`. For custom game DSLs, `pest`, `nom`, and `chumsky` are the strongest candidates.
  Sources: [https://serde.rs/](https://serde.rs/), [https://docs.rs/schemars/latest/schemars/](https://docs.rs/schemars/latest/schemars/), [https://docs.rs/jsonschema/latest/jsonschema/](https://docs.rs/jsonschema/latest/jsonschema/), [https://docs.rs/pest/latest/pest/](https://docs.rs/pest/latest/pest/), [https://docs.rs/nom/latest/nom/](https://docs.rs/nom/latest/nom/), [https://docs.rs/chumsky/latest/chumsky/](https://docs.rs/chumsky/latest/chumsky/)

- **Recommendations**:
  - Use `serde` plus `ron`, `toml`, `serde_json`, or `serde_yaml` for content files.
  - Use `schemars` if you want JSON Schema generation from Rust types.
  - Use `jsonschema` if validating external JSON against schemas.
  - Use `typify` if generating Rust types from JSON Schema.
  - Use `pest` for grammar-driven custom DSLs.
  - Use `nom` for binary or streaming parsers.
  - Use `chumsky` for ergonomic parser combinators and good error reporting.

- **Analysis**: For game content, a strong pipeline is:
  - author data in RON/TOML/JSON,
  - validate schemas in CI,
  - compile assets into deterministic binary blobs,
  - load content as immutable ECS resources.

---

#### 5. Compile-Time Macros and Code Generation

- **Detailed Finding**: Rust procedural macro codegen typically uses `syn`, `quote`, and `proc-macro2`. `darling` is useful for parsing macro attributes. `inventory` and `linkme` can support compile-time registration patterns, though registration order must be handled carefully for determinism.
  Sources: [https://docs.rs/syn/latest/syn/](https://docs.rs/syn/latest/syn/), [https://docs.rs/quote/latest/quote/](https://docs.rs/quote/latest/quote/), [https://docs.rs/proc-macro2/latest/proc_macro2/](https://docs.rs/proc-macro2/latest/proc_macro2/), [https://docs.rs/darling/latest/darling/](https://docs.rs/darling/latest/darling/), [https://docs.rs/inventory/latest/inventory/](https://docs.rs/inventory/latest/inventory/), [https://docs.rs/linkme/latest/linkme/](https://docs.rs/linkme/latest/linkme/)

- **Useful crates**:
  - `syn`
  - `quote`
  - `proc-macro2`
  - `darling`
  - `proc-macro-crate`
  - `inventory`
  - `linkme`
  - `include_dir`
  - `phf`
  - `build.rs` with `codegen` or custom generators

- **Analysis**: For schema-driven game engines, consider generating:
  - component definitions,
  - typed asset handles,
  - reflection metadata,
  - event/message enums,
  - network serialization schemas,
  - deterministic content IDs.

Avoid depending on hash-map iteration order in generated registries.

---

#### 6. Hex Grid Spatial Computation

- **Detailed Finding**: `hexx` is a strong modern Rust crate for hexagonal grids. It supports common coordinate systems, layout, rings, ranges, lines, and Bevy integration. It is likely the best first choice for a hex-grid game or simulation.
  Source: [https://docs.rs/hexx/latest/hexx/](https://docs.rs/hexx/latest/hexx/)

- **Other relevant crates**:
  - `hex2d`: [https://docs.rs/hex2d/latest/hex2d/](https://docs.rs/hex2d/latest/hex2d/)
  - `pathfinding`: [https://docs.rs/pathfinding/latest/pathfinding/](https://docs.rs/pathfinding/latest/pathfinding/)
  - `petgraph`: [https://docs.rs/petgraph/latest/petgraph/](https://docs.rs/petgraph/latest/petgraph/)

- **Analysis**: Recommended model:
  - use axial/cube integer coordinates,
  - encode map positions as deterministic integer components,
  - precompute neighbor tables for static maps,
  - use `pathfinding` or custom A* for movement,
  - store terrain/cost maps in dense arrays where possible for cache locality.

---

#### 7. AI Planning, Behavior Trees, Utility AI, and Pathfinding

- **Detailed Finding**: Rust’s AI planning ecosystem is more fragmented than its ECS or parsing ecosystem. For pathfinding, `pathfinding` is mature and useful. For behavior trees and utility AI, options exist but may be smaller or less maintained than equivalents in larger game-engine ecosystems.
  Sources: [https://docs.rs/pathfinding/latest/pathfinding/](https://docs.rs/pathfinding/latest/pathfinding/), [https://docs.rs/petgraph/latest/petgraph/](https://docs.rs/petgraph/latest/petgraph/), [https://docs.rs/big-brain/latest/big_brain/](https://docs.rs/big-brain/latest/big_brain/)

- **Recommended crates**:
  - `pathfinding` for A*, Dijkstra, BFS, etc.
  - `petgraph` for graph modeling.
  - `big-brain` for utility AI, especially Bevy-oriented.
  - Behavior tree crates can be evaluated, but custom behavior logic may be preferable for deterministic sims.

- **Analysis**: For deterministic simulations, AI planning should be bounded:
  - fixed planning budget per tick,
  - deterministic tie-breaking,
  - deterministic RNG streams per agent,
  - stable priority ordering,
  - planner output committed only during simulation update phases.

---

#### 8. CPU Parallelism, SIMD, and Hardware Acceleration

- **Detailed Finding**: Rust has strong CPU-parallel tooling through `rayon` and growing SIMD support through crates like `wide`, math crates such as `glam`, and the evolving portable SIMD API. GPU compute is best approached through `wgpu` for portability.
  Sources: [https://docs.rs/rayon/latest/rayon/](https://docs.rs/rayon/latest/rayon/), [https://docs.rs/wide/latest/wide/](https://docs.rs/wide/latest/wide/), [https://docs.rs/glam/latest/glam/](https://docs.rs/glam/latest/glam/), [https://wgpu.rs/](https://wgpu.rs/), [https://docs.rs/wgpu/latest/wgpu/](https://docs.rs/wgpu/latest/wgpu/)

- **CPU crates**:
  - `rayon` for data parallel loops.
  - `wide` for explicit SIMD types.
  - `glam` for SIMD-friendly vector math.
  - `nalgebra` for linear algebra.
  - `ndarray` for dense numerical arrays.

- **GPU crates**:
  - `wgpu`
  - `bytemuck`
  - `encase`
  - `pollster`
  - `vulkano`
  - `rust-gpu`

- **Analysis**: Hardware acceleration should be isolated from authoritative deterministic state unless reproducibility across hardware is not required. GPU floating-point behavior can differ across vendors/drivers. For deterministic authoritative simulation, use GPU primarily for:
  - rendering,
  - visualization,
  - non-authoritative previews,
  - bulk heuristic computation that is later quantized and validated,
  - offline baking.

---

### Nuance & Conflicting Data

- **Tokio vs determinism**: Tokio is excellent but not deterministic. It should support the engine, not drive authoritative simulation ordering.
- **ECS determinism**: ECS frameworks can be deterministic if constrained, but parallel ECS scheduling often prioritizes throughput over reproducible ordering.
- **GPU acceleration**: GPU compute is powerful but risky for exact deterministic lockstep simulation due to floating-point and scheduling differences.
- **Schema strategy**: `serde`-first structured data is simpler and safer than inventing a DSL. Use `pest`/`chumsky` only if the authoring experience demands a custom language.
- **AI crates**: Rust AI planning crates are less standardized. Pathfinding is strong; GOAP/HTN/behavior-tree ecosystems may require custom implementation or careful vetting.

---

### CITED LINKS

* [https://docs.rs/bevy_ecs/latest/bevy_ecs/](https://docs.rs/bevy_ecs/latest/bevy_ecs/) - ECS implementation from Bevy; strong candidate for scheduling and world modeling.
* [https://docs.rs/hecs/latest/hecs/](https://docs.rs/hecs/latest/hecs/) - Lightweight standalone ECS.
* [https://docs.rs/shipyard/latest/shipyard/](https://docs.rs/shipyard/latest/shipyard/) - Standalone ECS alternative.
* [https://docs.rs/tokio/latest/tokio/](https://docs.rs/tokio/latest/tokio/) - Async runtime for I/O and background services.
* [https://docs.rs/rayon/latest/rayon/](https://docs.rs/rayon/latest/rayon/) - CPU parallelism.
* [https://serde.rs/](https://serde.rs/) - Core Rust serialization/deserialization framework.
* [https://docs.rs/schemars/latest/schemars/](https://docs.rs/schemars/latest/schemars/) - JSON Schema generation from Rust types.
* [https://docs.rs/pest/latest/pest/](https://docs.rs/pest/latest/pest/) - Grammar-based parser generator.
* [https://docs.rs/nom/latest/nom/](https://docs.rs/nom/latest/nom/) - Parser combinator framework.
* [https://docs.rs/chumsky/latest/chumsky/](https://docs.rs/chumsky/latest/chumsky/) - Parser combinator library with strong ergonomics.
* [https://docs.rs/syn/latest/syn/](https://docs.rs/syn/latest/syn/) - Rust syntax parsing for procedural macros.
* [https://docs.rs/quote/latest/quote/](https://docs.rs/quote/latest/quote/) - Token generation for procedural macros.
* [https://docs.rs/darling/latest/darling/](https://docs.rs/darling/latest/darling/) - Macro attribute parsing helper.
* [https://docs.rs/hexx/latest/hexx/](https://docs.rs/hexx/latest/hexx/) - Hex-grid coordinate and spatial computation crate.
* [https://docs.rs/pathfinding/latest/pathfinding/](https://docs.rs/pathfinding/latest/pathfinding/) - Pathfinding algorithms.
* [https://docs.rs/petgraph/latest/petgraph/](https://docs.rs/petgraph/latest/petgraph/) - Graph data structures and algorithms.
* [https://docs.rs/big-brain/latest/big_brain/](https://docs.rs/big-brain/latest/big_brain/) - Utility AI, especially relevant to Bevy users.
* [https://docs.rs/wgpu/latest/wgpu/](https://docs.rs/wgpu/latest/wgpu/) - Cross-platform GPU abstraction.
* [https://docs.rs/wide/latest/wide/](https://docs.rs/wide/latest/wide/) - Explicit SIMD types.
* [https://docs.rs/glam/latest/glam/](https://docs.rs/glam/latest/glam/) - SIMD-friendly math library.

### SCRAPE CANDIDATES

* [https://github.com/bevyengine/bevy](https://github.com/bevyengine/bevy) - High-value source for current Bevy ECS/task/runtime details.
* [https://github.com/ManevilleF/hexx](https://github.com/ManevilleF/hexx) - High-value source for examples and Bevy integration.
* [https://github.com/tokio-rs/tokio](https://github.com/tokio-rs/tokio) - Useful for runtime behavior and scheduler documentation.
* [https://github.com/gfx-rs/wgpu](https://github.com/gfx-rs/wgpu) - Useful for GPU compute examples and constraints.
* [https://github.com/rust-random/rand](https://github.com/rust-random/rand) - Useful for deterministic RNG implementation details.
* [https://github.com/dtolnay/syn](https://github.com/dtolnay/syn) - Useful for procedural macro codegen patterns.

