## Research Findings So Far


### Round 1

#### Researcher 1: Rust cross-platform deterministic simulation replay state hashing crates fixed point deterministic serialization ECS scheduler no_std hash stable ordering bincode postcard rkyv ciborium blake3 xxhash rust portable SIMD determinism GPU non deterministic floating point rayon deterministic parallel reductions

<search queries={["Rust deterministic simulation replay state hashing fixed point serialization ECS scheduler no_std", "Rust deterministic floating point fixed point crates no_std simulation replay", "Rust ECS deterministic scheduler stable ordering bevy hecs legion deterministic", "bincode postcard rkyv ciborium deterministic serialization Rust no_std", "Rust deterministic hashing blake3 xxhash stable ordering rayon deterministic parallel reductions"]} />
<search queries={["site:docs.rs fixed deterministic fixed point rust no_std", "site:docs.rs rust deterministic hash no_std blake3 xxhash", "site:docs.rs bincode postcard rkyv ciborium no_std", "site:docs.rs rayon deterministic parallel iterator order reduce rust", "site:docs.rs bevy_ecs schedule deterministic rust"]} />
<search sourceType="github" queries={["rust deterministic lockstep simulation fixed point ECS replay", "rust deterministic game simulation replay state hash", "rust no_std deterministic serialization postcard rkyv bincode ciborium", "rust portable simd deterministic floating point"]} />

<scrape urls={["https://docs.rs/bincode/latest/bincode/", "https://docs.rs/postcard/latest/postcard/", "https://docs.rs/rkyv/latest/rkyv/", "https://docs.rs/ciborium/latest/ciborium/", "https://docs.rs/blake3/latest/blake3/", "https://docs.rs/xxhash-rust/latest/xxhash_rust/", "https://docs.rs/fixed/latest/fixed/", "https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html", "https://docs.rs/bevy_ecs/latest/bevy_ecs/schedule/index.html", "https://doc.rust-lang.org/std/hash/trait.Hasher.html"]} />

<scrape urls={["https://docs.rs/bincode/latest/bincode/", "https://docs.rs/postcard/latest/postcard/", "https://docs.rs/fixed/latest/fixed/"]} excludeLinks={["https://docs.rs/ciborium/latest/ciborium/", "https://docs.rs/xxhash-rust/latest/xxhash_rust/"]} />

<scrape urls={["https://docs.rs/rkyv/latest/rkyv/", "https://docs.rs/blake3/latest/blake3/"]} />

<scrape urls={["https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html", "https://docs.rs/bevy_ecs/latest/bevy_ecs/schedule/index.html", "https://doc.rust-lang.org/std/hash/trait.Hasher.html"]} />

## Rust Cross-Platform Deterministic Simulation Replay: State Hashing, Serialization, ECS Scheduling, Numeric Determinism, and Parallelism

### Executive Summary

For deterministic Rust simulation replay across platforms, the safest architecture is to treat determinism as a full-stack constraint: deterministic state representation, deterministic serialization, stable entity/system ordering, platform-independent numeric behavior, and deterministic reduction/hash pipelines. Rust has good building blocks—`fixed` for fixed-point arithmetic, `postcard`/`bincode`/`rkyv`/`ciborium` for serialization tradeoffs, `blake3` or `xxhash-rust` for hashing, and ECS schedulers such as `bevy_ecs`—but none automatically guarantee whole-simulation determinism.

The highest-confidence path is:

- Use integer or fixed-point math for authoritative simulation state, preferably via `fixed`, which supports `no_std` and fixed-width numeric formats.
- Serialize canonical state explicitly, not by dumping memory layout.
- Prefer deterministic encodings such as `postcard` or carefully configured `bincode`; avoid relying on map iteration order.
- Hash canonical serialized state with a stable algorithm such as BLAKE3 for replay verification.
- Ensure ECS entity iteration, component storage traversal, and system execution order are stable and explicitly controlled.
- Avoid nondeterministic floating-point behavior, especially across CPU architectures, SIMD backends, GPUs, or parallel reductions.
- Treat Rayon parallelism as deterministic only when order-insensitive operations are mathematically associative/commutative over exact types, or when using explicitly ordered collection/reduction strategies.

### Comprehensive Findings

#### 1. Deterministic State Hashing Requires Canonical State, Not Just a Good Hash

- **Detailed Finding**: Hashing state for simulation replay is only as deterministic as the byte stream being hashed. Rust’s standard `Hasher` trait explicitly does not define a portable or stable hash format across implementations; it is intended for hash table use, not persistent or cross-platform hashing. The Rust standard library documentation warns that data fed into `Hasher` should not be considered portable across platforms or compiler versions unless the hasher and input encoding are controlled [citation](https://doc.rust-lang.org/std/hash/trait.Hasher.html).

- **Detailed Finding**: For replay verification, cryptographic or fixed-algorithm content hashes are preferable. `blake3` provides a stable, high-performance cryptographic hash API and supports Rust usage through a crate-level hasher interface [citation](https://docs.rs/blake3/latest/blake3/). `xxhash-rust` is faster and non-cryptographic, useful for debug or high-frequency frame checksums, but less appropriate for adversarial or authoritative validation [citation](https://docs.rs/xxhash-rust/latest/xxhash_rust/).

- **Analysis**: The crucial design point is to separate “state canonicalization” from “hashing.” A deterministic replay hash should be computed over an explicitly ordered serialization of authoritative simulation state: entities sorted by stable IDs, components sorted by component type/version, map entries sorted by key, and floating/fixed numeric fields encoded in a stable endian format. BLAKE3 is a strong default for correctness-oriented replay validation; xxHash can be useful for development-time fast checks but should not be confused with canonical state definition.

#### 2. Serialization Crates: `postcard`, `bincode`, `rkyv`, and `ciborium`

- **Detailed Finding**: `postcard` is a compact `serde`-based binary serialization format designed for constrained and embedded systems. It is commonly used in `no_std` contexts and is attractive for deterministic simulation snapshots because it produces compact, schema-driven binary output [citation](https://docs.rs/postcard/latest/postcard/).

- **Detailed Finding**: `bincode` is also a compact binary encoder/decoder, historically popular for Rust-to-Rust serialization. Modern `bincode` versions expose explicit configuration options, which is important because deterministic replay should lock down endianness, integer encoding, and compatibility behavior rather than relying on defaults [citation](https://docs.rs/bincode/latest/bincode/).

- **Detailed Finding**: `rkyv` is an archival/zero-copy serialization framework. It can be very fast and attractive for large snapshots, but deterministic replay users should be careful: zero-copy/archive formats can expose layout, alignment, type representation, or versioning concerns if not managed deliberately. The crate is valuable where performance matters, but canonical cross-platform hashing should not assume native memory layout equals deterministic wire format [citation](https://docs.rs/rkyv/latest/rkyv/).

- **Detailed Finding**: `ciborium` implements CBOR serialization/deserialization in Rust [citation](https://docs.rs/ciborium/latest/ciborium/). CBOR can support canonical encodings in principle, but deterministic use requires ensuring canonical ordering and representation rules are followed. Generic CBOR serialization of maps does not automatically solve stable ordering if the source container iteration is nondeterministic.

- **Analysis**: For deterministic replay, `postcard` and configured `bincode` are straightforward choices for compact binary state encoding. `rkyv` is compelling for performance but should be treated with extra scrutiny for cross-platform deterministic hashing. `ciborium` is useful where CBOR interoperability matters, but canonical CBOR discipline is necessary. Across all formats, `HashMap`/`HashSet` iteration order and ECS storage iteration order are bigger practical determinism hazards than the serializer itself.

#### 3. Fixed-Point Arithmetic and Numeric Determinism

- **Detailed Finding**: The `fixed` crate provides fixed-point numeric types with a specified number of fractional bits and supports a wide range of signed and unsigned fixed-point formats [citation](https://docs.rs/fixed/latest/fixed/). This makes it a strong candidate for deterministic game/simulation logic where platform-independent results matter.

- **Detailed Finding**: Floating-point determinism is fragile across platforms. Even if Rust follows IEEE-754 semantics in many ordinary cases, bit-identical results can diverge due to fused multiply-add, extended precision, SIMD lowering, math library implementations, CPU flags, target features, GPU execution, and parallel operation ordering.

- **Analysis**: If replay determinism must hold across x86_64, ARM64, WebAssembly, and possibly different compiler versions, authoritative simulation should avoid unconstrained `f32`/`f64` accumulation. Fixed-point or integer math is safer. Floating point can still be used for rendering, interpolation, audio, or non-authoritative prediction, but authoritative state should be quantized or represented exactly. Portable SIMD is especially delicate: SIMD may change operation grouping, rounding points, or use target-specific instructions. GPUs are worse for deterministic simulation because shader compilers, drivers, and hardware scheduling can produce nondeterministic or non-bit-identical results.

#### 4. ECS Scheduling and Stable Ordering

- **Detailed Finding**: `bevy_ecs` provides schedule/system infrastructure for ECS workloads [citation](https://docs.rs/bevy_ecs/latest/bevy_ecs/schedule/index.html). ECS schedulers typically optimize execution by ordering systems according to dependencies and may run systems in parallel when no conflicts are detected.

- **Detailed Finding**: Deterministic ECS simulation requires more than deterministic system graph construction. Entity creation order, entity IDs, archetype/table iteration, command buffers, deferred insertion/removal, event ordering, and parallel system execution can all affect replay.

- **Analysis**: To make ECS deterministic, systems should have explicit ordering constraints, stable labels/sets, and deterministic conflict resolution. Avoid depending on implicit query iteration order unless the ECS explicitly documents it as stable under the relevant operations. For replay hashing, do not hash ECS internal storage directly. Instead, export canonical state: stable entity identifiers, sorted components, deterministic map order, and versioned component schemas. If using command buffers, ensure command application order is deterministic. If systems run in parallel, ensure all write conflicts are statically prevented and that observable event/resource mutation order is fixed.

#### 5. `no_std` Compatibility Considerations

- **Detailed Finding**: Several relevant crates are suitable for constrained or `no_std`-leaning contexts. `postcard` is particularly associated with embedded and `no_std` serialization [citation](https://docs.rs/postcard/latest/postcard/). `fixed` supports fixed-point arithmetic without requiring the full standard library in many configurations [citation](https://docs.rs/fixed/latest/fixed/). `blake3` and `xxhash-rust` have feature configurations that can be used in constrained environments, though exact feature choices should be locked in Cargo configuration [citation](https://docs.rs/blake3/latest/blake3/), [citation](https://docs.rs/xxhash-rust/latest/xxhash_rust/).

- **Analysis**: `no_std` determinism can actually be easier because it discourages reliance on randomized hash maps, OS-specific behavior, threads, locale, file-system ordering, or platform math libraries. However, `alloc`-dependent structures still need stable iteration discipline. For deterministic maps, prefer sorted containers or canonical sorting before serialization.

#### 6. Hash Maps, Stable Ordering, and Rust Standard Hashing

- **Detailed Finding**: Rust’s standard hash infrastructure is intentionally not designed for stable, persistent hashes. The `Hasher` trait is generic over hash algorithm implementations, and the standard `HashMap` default hasher uses randomized seeding to resist collision attacks. Therefore, `HashMap` iteration or `Hash` output must not be used as replay-stable state [citation](https://doc.rust-lang.org/std/hash/trait.Hasher.html).

- **Analysis**: Use `BTreeMap`/`BTreeSet` where canonical key order matters, or sort `Vec` entries before serialization. If hash maps are required for performance, treat them as internal acceleration structures and export deterministic sorted state for hashing. For entity maps, assign stable logical IDs rather than relying on allocation address, generational index creation quirks, or ECS internal IDs unless explicitly controlled.

#### 7. Rayon and Deterministic Parallel Reductions

- **Detailed Finding**: Rayon’s `ParallelIterator` API provides parallel iteration and reduction tools [citation](https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html). Parallel execution can split work dynamically, and reduction tree shape may vary depending on scheduling.

- **Detailed Finding**: For exact associative operations such as integer addition without overflow ambiguity, bitwise XOR, min/max over total orderings, or BLAKE3 chunk-tree hashing with defined semantics, parallelism can be deterministic if the operation and ordering are controlled. For floating-point addition, multiplication, and many aggregate calculations, parallel reductions are generally not bit-deterministic because floating-point arithmetic is not associative.

- **Analysis**: Rayon should be used carefully in deterministic simulation. Safe patterns include:
  - Parallel compute into per-entity slots, then deterministic serial commit.
  - Parallel map over a stable indexed collection, followed by ordered collection.
  - Integer/fixed-point reductions with explicit overflow policy.
  - Per-chunk hashes combined in a canonical chunk index order.

  Risky patterns include:
  - `reduce` over floating-point values.
  - Mutation through shared resources where ordering affects results.
  - Event generation from parallel systems without stable sorting.
  - Depending on work-stealing execution order.

#### 8. GPU and Portable SIMD Determinism

- **Detailed Finding**: GPU computation is generally unsuitable for authoritative deterministic simulation unless the entire hardware/compiler/driver environment is fixed and tested. GPUs may reorder operations, use approximate math, flush denormals, fuse operations, and execute reductions nondeterministically.

- **Detailed Finding**: Rust portable SIMD can improve performance but does not automatically guarantee cross-target bit identity when used with floating-point operations. Integer SIMD is much safer. Floating SIMD may still differ because of target feature lowering, FMA behavior, and compiler optimizations.

- **Analysis**: For deterministic replay:
  - Use integer/fixed-point SIMD if needed.
  - Keep authoritative state updates on CPU with controlled arithmetic.
  - Treat GPU outputs as non-authoritative visual effects unless quantized and validated.
  - Disable or control target features that change floating-point behavior if floats are unavoidable.
  - Test replay hashes across all target triples and CPU feature sets.

### Nuance & Conflicting Data

- **Serialization determinism is not binary**: Crates like `bincode`, `postcard`, `rkyv`, and `ciborium` can all be part of a deterministic pipeline, but none guarantee determinism if the input data structure has nondeterministic ordering. The serializer is only one layer.

- **`rkyv` is both attractive and risky**: Its performance and zero-copy model are valuable, but deterministic cross-platform replay hashing should avoid assuming archived memory layout is inherently canonical across all targets and versions [citation](https://docs.rs/rkyv/latest/rkyv/).

- **BLAKE3 vs xxHash**: BLAKE3 is more robust for authoritative replay verification, while xxHash is faster and often sufficient for non-adversarial debug checks. The tradeoff is correctness/security margin versus speed [citation](https://docs.rs/blake3/latest/blake3/), [citation](https://docs.rs/xxhash-rust/latest/xxhash_rust/).

- **Floating-point determinism is contextual**: Some applications can achieve acceptable determinism by pinning hardware, compiler, target features, and math settings. Cross-platform simulation replay, however, should assume floats are unsafe for authoritative state unless heavily constrained.

- **Parallelism is not inherently nondeterministic**: Rayon can be deterministic when each task writes to independent indexed outputs and final commit order is stable. It becomes nondeterministic when operation order affects results, especially with floating-point reductions or unordered event emission [citation](https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html).

### CITED LINKS

* [https://docs.rs/bincode/latest/bincode/](https://docs.rs/bincode/latest/bincode/) - Used for binary serialization configuration and suitability discussion.
* [https://docs.rs/postcard/latest/postcard/](https://docs.rs/postcard/latest/postcard/) - Used for compact `serde`-based serialization and `no_std`-oriented state encoding.
* [https://docs.rs/rkyv/latest/rkyv/](https://docs.rs/rkyv/latest/rkyv/) - Used for zero-copy/archive serialization tradeoff analysis.
* [https://docs.rs/ciborium/latest/ciborium/](https://docs.rs/ciborium/latest/ciborium/) - Used for CBOR serialization and canonical encoding considerations.
* [https://docs.rs/blake3/latest/blake3/](https://docs.rs/blake3/latest/blake3/) - Used for stable cryptographic state hashing recommendation.
* [https://docs.rs/xxhash-rust/latest/xxhash_rust/](https://docs.rs/xxhash-rust/latest/xxhash_rust/) - Used for fast non-cryptographic hashing comparison.
* [https://docs.rs/fixed/latest/fixed/](https://docs.rs/fixed/latest/fixed/) - Used for fixed-point deterministic arithmetic recommendation.
* [https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html](https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html) - Used for deterministic and nondeterministic parallel iterator/reduction analysis.
* [https://docs.rs/bevy_ecs/latest/bevy_ecs/schedule/index.html](https://docs.rs/bevy_ecs/latest/bevy_ecs/schedule/index.html) - Used for ECS scheduling and system-ordering discussion.
* [https://doc.rust-lang.org/std/hash/trait.Hasher.html](https://doc.rust-lang.org/std/hash/trait.Hasher.html) - Used for warning against Rust standard hash traits as stable replay hashes.

### SCRAPE CANDIDATES

* [https://docs.rs/ciborium/latest/ciborium/](https://docs.rs/ciborium/latest/ciborium/) - High-value for deeper CBOR canonicalization and `no_std` details; deprioritized behind more central Rust simulation crates.
* [https://docs.rs/xxhash-rust/latest/xxhash_rust/](https://docs.rs/xxhash-rust/latest/xxhash_rust/) - Useful for deeper feature-flag and `no_std` investigation; deprioritized because BLAKE3 is the safer authoritative hash.
* [https://docs.rs/bevy_ecs/latest/bevy_ecs/schedule/index.html](https://docs.rs/bevy_ecs/latest/bevy_ecs/schedule/index.html) - Worth deeper follow-up for exact scheduler ordering guarantees and ambiguity around parallel schedules.
* [https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html](https://docs.rs/rayon/latest/rayon/iter/trait.ParallelIterator.html) - Worth deeper follow-up for exact guarantees of ordered collection, indexed parallel iterators, and reduction semantics.

