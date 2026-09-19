# Run file schema

Every file under `runs/` and `quarantine/` is one `BenchRunResult` JSON object, produced by [`@localmode/bench`](https://github.com/LocalMode-AI/LocalMode/tree/main/packages/bench) (current: schema version 2, protocol `localmode-bench/2`; files record the version they were produced under, and archived runs are never re-scored). The TypeScript source of truth is [`packages/bench/src/types.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/packages/bench/src/types.ts); the executable validator is `validateRunShape()` / `validateSubmission()` in the same package.

## Top level

| Field | Type | Meaning |
| --- | --- | --- |
| `protocol` | `"localmode-bench/2"` (older files: `"localmode-bench/1"`) | Versioned protocol identifier |
| `schemaVersion` | `2` (older files: `1`) | Result JSON schema version |
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
| `memory` | Bytes at protocol points (`baseline`/`postLoad`/`postRun`, and since v2 `atError` for cells that failed) + which API measured them |
| `quality` | Optional fidelity-lane score (tinyMMLU accuracy or STS-B Spearman). Since v2, MMLU cells also carry raw per-item `outputs` (capped at 400 chars each) and a `parseRate` (fraction of parseable answers; a low value marks a format-limited score), so scores are recomputable |
| `status` / `invalidReasons` | `ok \| invalid \| error \| skipped`. Since v2 a timed LLM iteration generating fewer than 16 chars is gated `degenerate-output` and the cell is `invalid` |
| `error` | `{ name, message, cause? }` for `error` cells; since v2 `cause` carries the wrapped provider error's message |
| `status` | `ok \| invalid \| error \| skipped` - invalid cells carry `invalidReasons`, never silent retries |

## Metric definitions (how to recompute)

- **TTFT** = first chunk with `c > 0` → `t − startT`.
- **Decode chars/s** = `(Σ chunk chars − first chunk chars) / (t_last − t_first) × 1000` - endpoints-based, first token excluded (MLPerf Client TPS definition).
- **Tokens/s** - apply the model's tokenizer to `text` post-hoc; provider-reported `providerUsage` is auxiliary only (its `fidelity` field says why: `estimated` or `chunk-count`).

`index/summary.json` is an array of light per-run summaries (`RunIndexEntry` in [`apps/ui/src/lib/bench/store.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/src/lib/bench/store.ts)) used to render the leaderboard without fetching every run file.

## Protocol versions

- **`localmode-bench/2`** (2026-09-19) - TTFT/decode derived only from genuinely incremental chunk traces (non-incremental lanes report an end-to-end rate via the `totalMs`/`overallCharsPerSec` summaries); quality lane: 48-token budget, reasoning-block stripping, uniform per-pairing no-think suffixes, raw outputs + parse rate stored; degenerate-output gate (< 16 generated chars invalidates the cell); every runtime receives the prompt as a single templated user turn with cross-request prompt caching disabled; error causes preserved; deterministic runtime execution order for reproducibility.
- **`localmode-bench/1`** (2026-09-18) - initial public protocol.

Full definitions: https://localmode.ai/bench/methodology
