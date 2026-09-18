# Run file schema

Every file under `runs/` and `quarantine/` is one `BenchRunResult` JSON object, produced by [`@localmode/bench`](https://github.com/LocalMode-AI/LocalMode/tree/main/packages/bench) (schema version 1, protocol `localmode-bench/1`). The TypeScript source of truth is [`packages/bench/src/types.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/packages/bench/src/types.ts); the executable validator is `validateRunShape()` / `validateSubmission()` in the same package.

## Top level

| Field | Type | Meaning |
| --- | --- | --- |
| `protocol` | `"localmode-bench/1"` | Versioned protocol identifier |
| `schemaVersion` | `1` | Result JSON schema version |
| `runId` | string | UUID of the run (also the filename) |
| `createdAt` | ISO 8601 string | UTC timestamp |
| `harness` | `{ name, version, appVersion? }` | Harness identity |
| `suite` | `quick \| standard \| thorough \| custom` | Suite preset |
| `environment` | object | Full environment capture (see below) |
| `fingerprint` | object | Deterministic matmul calibration microbenchmark (`mflops`, `iterations`, `durationMs`, `checksum`) |
| `cells` | array | One entry per (runtime × model × workload) cell (see below) |
| `events` | array | Suite-level trace events (`suite-start`, `visibility-hidden`, `wakelock-released`, `pressure-change`, …) with timestamps |
| `clientSummaries` | array? | Client-computed summaries (advisory; the server recomputes from traces) |
| `nonce` | string? | Server-issued session nonce (verified tier) |
| `digest` | string | SHA-256 hex of the canonical JSON of this object without `digest` |

## `environment`

Browser identity with provenance (`ua-ch` on Chromium; `ua-parse` elsewhere with `os.version: "unknown-frozen"` - UA strings are frozen by design), WebGPU adapter info (`vendor`, `architecture`, limits, features), hardware fields **labeled clamped** (`cores`, `deviceMemoryGB` - browsers cap or randomize them), cross-origin isolation, WASM SIMD, storage estimate, battery charging state, compute-pressure availability, inferred `timerResolutionUs`, and an optional `userReportedDevice` free-text field (displayed as user-reported, never trusted).

## `cells[]`

| Field | Meaning |
| --- | --- |
| `cellId` | `runtimeId/benchModelId/workloadId` |
| `runtimeId` | `transformers-webgpu \| transformers-wasm \| webllm \| wllama \| litert \| chrome-ai \| mediapipe` |
| `model` | Static model reference (provider model id, quantization, declared size, URL) |
| `workloadId` / `workloadKind` | e.g. `chat-pp128-tg128` / `llm-generate` |
| `resolvedBackend` | Backend actually used (probed, never the requested one) |
| `load` | Download/cache phase: `cached` (cold=false / warm=true), start/end timestamps, progress milestones |
| `warmupMs` | Untimed first-inference readiness (engine init + shader/JIT compile). Cold start = load + warmup |
| `iterations` | LLM: `{ startT, chunks: [{t, c}], endT, text, providerUsage?, finishReason, gates }` - per-chunk wall-clock trace + full generated text. Embedding: `{ startT, endT, count, dimensions, gates }` |
| `memory` | Bytes at protocol points (`baseline`/`postLoad`/`postRun`) + which API measured them |
| `quality` | Optional fidelity-lane score (tinyMMLU accuracy or STS-B Spearman) |
| `status` | `ok \| invalid \| error \| skipped` - invalid cells carry `invalidReasons`, never silent retries |

## Metric definitions (how to recompute)

- **TTFT** = first chunk with `c > 0` → `t − startT`.
- **Decode chars/s** = `(Σ chunk chars − first chunk chars) / (t_last − t_first) × 1000` - endpoints-based, first token excluded (MLPerf Client TPS definition).
- **Tokens/s** - apply the model's tokenizer to `text` post-hoc; provider-reported `providerUsage` is auxiliary only (its `fidelity` field says why: `estimated` or `chunk-count`).

`index/summary.json` is an array of light per-run summaries (`RunIndexEntry` in [`apps/ui/src/lib/bench/store.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/src/lib/bench/store.ts)) used to render the leaderboard without fetching every run file.
