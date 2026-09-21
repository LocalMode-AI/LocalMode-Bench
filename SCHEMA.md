# Run file schema

Every file under `runs/` and `quarantine/` is one `BenchRunResult` JSON object, produced by [`@localmode/bench`](https://github.com/LocalMode-AI/LocalMode/tree/main/packages/bench) (current: schema version 2, protocol `localmode-bench/4`; files record the version they were produced under, and archived runs are never re-scored). The TypeScript source of truth is [`packages/bench/src/types.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/packages/bench/src/types.ts); the executable validator is `validateRunShape()` / `validateSubmission()` in the same package.

## Top level

| Field | Type | Meaning |
| --- | --- | --- |
| `protocol` | `"localmode-bench/4"` (older files: `"localmode-bench/1"`, `"localmode-bench/2"`, `"localmode-bench/3"`) | Versioned protocol identifier |
| `schemaVersion` | `2` (older files: `1`) | Result JSON schema version |
| `runId` | string | UUID of the run (also the filename) |
| `createdAt` | ISO 8601 string | UTC timestamp |
| `harness` | `{ name, version, appVersion?, runtimeVersions?, commit? }` | Harness identity. Since bench 0.3.0 `runtimeVersions` maps each runtime package the host bundled to its version (e.g. `"@huggingface/transformers": "4.2.0"`, `"@wllama/wllama": "3.5.1"` - the CDN pin that executes) and `commit` is the host build's git commit when exposed |
| `suite` | `quick \| standard \| thorough \| custom` | Suite preset |
| `environment` | object | Full environment capture (see below) |
| `fingerprint` | object | Deterministic matmul calibration microbenchmark (`mflops`, `iterations`, `durationMs`, `checksum`) |
| `cells` | array | One entry per (runtime × model × workload) cell (see below) |
| `events` | array | Suite-level trace events (`suite-start`, `visibility-hidden`, `wakelock-released`, `pressure-change`, `cell-timeout`, `cell-retry`, `iteration-redo`, …) with timestamps. `pressure-change` is recorded per one-second sample in files produced before bench 0.4.0 and on state transitions only afterwards |
| `clientSummaries` | array? | Client-computed summaries (advisory; the server recomputes from traces) |
| `nonce` | absent | The submission carried a server-issued session nonce; the server strips it before publishing (since schema 3; older files may still carry one) |
| `digest` | string | SHA-256 hex of the canonical JSON of this object without `digest` and `nonce` (files published before schema 3 were digested with the nonce included; `verifyRunDigest` in `@localmode/bench` accepts both) |
| `scrubbedAt` | string? | ISO time at which the file was rewritten by the publication scrub (fields removed under schema 3, digest recomputed); absent when the file is exactly what the client submitted |

## `environment`

Browser identity with provenance (`ua-ch` on Chromium; `ua-parse` elsewhere with `os.version: "unknown-frozen"` - UA strings are frozen by design), WebGPU adapter info (`vendor`, `architecture`, limits, features), hardware fields **labeled clamped** (`cores`, `deviceMemoryGB` - browsers cap or randomize them), cross-origin isolation, WASM SIMD, storage estimate, battery charging state, compute-pressure availability, inferred `timerResolutionUs`, and an optional `userReportedDevice` free-text field (displayed as user-reported, never trusted; paid-study runs carry `prolific:<12-hex SHA-256 prefix>` here, never a participant id).

Since `@localmode/bench` 0.3.0 (additive optional fields; the schema version is unchanged and older files simply lack them) a run also records everything else the browser discloses, every probe guarded so a missing API records nothing for its key:

| Field | Meaning |
| --- | --- |
| `userAgent` | Raw `navigator.userAgent`, kept verbatim so future parsers can re-derive fields |
| `browser.engine` / `vendor` / `webdriver` / `pdfViewerEnabled` | Rendering engine (`Blink` / `Gecko` / `WebKit`), `navigator.vendor`, automation flag, PDF viewer (a headless signal) |
| `os.bitness` / `wow64` / `navigatorPlatform` | UA-CH bitness and WoW64 flag (Chromium); legacy `navigator.platform` |
| `device` | `{ type: phone \| tablet \| desktop \| xr \| tv \| unknown, mobile, formFactors?, maxTouchPoints, pointerCoarse?, hoverNone?, displayMode? }` - form factor from UA-CH form factors, the UA, and touch points (an iPad reporting as a Mac is unmasked by `maxTouchPoints`) |
| `hardware.jsHeapSizeLimitBytes` / `jsHeapUsedBytes` | `performance.memory` ceiling and idle usage (Chromium) |
| `gpu.subgroupMinSize` / `subgroupMaxSize` / `preferredCanvasFormat` / `wgslLanguageFeatures` | Further WebGPU adapter identity; `limits` now carries 12 limits |
| `webgl` | `{ contextKind, vendor, renderer, version, shadingLanguageVersion, maxTextureSize, maxRenderbufferSize, maxVertexUniformVectors, maxFragmentUniformVectors, extensionCount, softwareRenderer }` (unmasked strings where `WEBGL_debug_renderer_info` exists) |
| `gpuModel` | GPU model: the WebGPU adapter description where a browser fills it in, else parsed from the WebGL renderer string with the ANGLE wrapper, PCI id and Direct3D suffix removed (`"Apple M4"`, `"NVIDIA GeForce RTX 4070"`, `"Mali-G78 MP20"`; Firefox coarsens it to e.g. `"Apple M1, or similar"`; Playwright/headless software GL reports SwiftShader) |
| `flags.secureContext` / `flags.wasm` | Secure context; the WebAssembly proposal matrix probed by validating canonical modules (the wasm-feature-detect 1.9.0 detection modules): `simd, relaxedSimd, threads, bulkMemory, exceptions, exceptionsFinal, extendedConst, gc, memory64, multiMemory, multiValue, mutableGlobals, referenceTypes, saturatedFloatToInt, signExtensions, tailCall, typedFunctionReferences, wideArithmetic, jspi, typeReflection, streamingCompilation, jsStringBuiltins`, plus `maxMemoryPages` (largest 32-bit `WebAssembly.Memory` maximum the engine accepts; 65536 = 4 GiB) |
| `apis` | Presence checks: `webgpu, webgl2, webnn, opfs` (getDirectory resolved), `persistedStorage, indexedDB, cacheApi, serviceWorker, webWorkers, offscreenCanvas, webLocks, broadcastChannel, wakeLock, computePressure, performanceMemory, measureUserAgentSpecificMemory, schedulerYield, webCodecs, audioWorklet, mediaDevices, webTransport`, and the Chrome Built-in AI `availability()` verdicts `promptApi, summarizerApi, translatorApi` (en→es), `languageDetectorApi` where those globals exist |
| `storage.usageDetails` | Per-storage-system usage where the browser breaks it down |
| `power` | `{ batterySupported, charging?, level? }`; `level` is rounded to the quarter since schema 3 (the exact percentage and the Battery API times were removed: they track a device) |
| `network` | `{ supported, effectiveType?, type?, downlinkMbps?, rttMs?, saveData?, online? }` from the Network Information API (Chromium; `online` everywhere) |
| `display` | `{ width, height, availWidth, availHeight, dpr, colorDepth, orientation, viewportWidth, viewportHeight, hdr, wideGamut, isExtended }` (superset of `screen`; the two display preferences were removed in schema 3) |
| `locale` | `{ locale }`, the BCP 47 tag only, since schema 3 (the time zone, UTC offset, and calendar place a device in a city and are not captured; `languages` was removed for the same reason) |
| `pageOrigin` / `visibilityState` | Origin the run executed on (production vs local) and tab visibility at capture |

Note: `hardware.coresClamped` in files produced before bench 0.3.0 is `true` for every Chromium run (the label compared the UA-CH brand name "Google Chrome" against "Chrome"); Chromium reports real logical cores, so treat those values as unclamped when `browser.source` is `ua-ch`.

## `cells[]`

| Field | Meaning |
| --- | --- |
| `cellId` | `runtimeId/benchModelId/workloadId` |
| `runtimeId` | `transformers-webgpu \| transformers-wasm \| webllm \| wllama \| wllama-webgpu \| litert \| chrome-ai \| mediapipe`. Since `localmode-bench/3`, `wllama` is llama.cpp on the CPU (`n_gpu_layers: 0`) and `wllama-webgpu` offloads every layer to WebGPU; in v1/v2 files the single `wllama` lane ran on WebGPU wherever `environment.gpu.available` is true while recording `resolvedBackend: "wasm"` (wllama 3.5's default offload, unnoticed by the harness) |
| `runtimeVersion` | Version of the runtime package that produced the cell (since bench 0.3.0; Chrome Built-in AI has none - the browser version is its identity) |
| `model` | Static model reference (provider model id, quantization, declared size, URL) |
| `workloadId` / `workloadKind` | e.g. `chat-pp128-tg128` / `llm-generate` |
| `resolvedBackend` | Backend actually used (probed, never the requested one). For the wllama lanes since v3 it follows llama.cpp's own `offloaded N/M layers to GPU` load report |
| `runtimeConfig` | Since bench 0.5.0: the adapter's post-load configuration record, per cell (wllama: `n_threads`, `n_gpu_layers` requested, `webgpu_adapter`, `offloadedLayers` "N/M", `cache_prompt`, and since v4 `mmproj: false` on language lanes; Transformers.js: `device`, `dtype`, `worker`) |
| `load` | Download/cache phase: `cached` (cold=false / warm=true), start/end timestamps, progress milestones |
| `warmupMs` | Untimed first-inference readiness (engine init + shader/JIT compile). Cold start = load + warmup |
| `iterations` | LLM: `{ startT, chunks: [{t, c}], endT, text, providerUsage?, finishReason, gates }` - per-chunk wall-clock trace + full generated text. Embedding: `{ startT, endT, count, dimensions, gates }` |
| `memory` | Bytes at protocol points (`baseline`/`postLoad`/`postRun`, and since v2 `atError` for cells that failed) + which API measured them |
| `quality` | Optional fidelity-lane score (tinyMMLU accuracy or STS-B Spearman). Since v2, MMLU cells also carry raw per-item `outputs` (capped at 400 chars each) and a `parseRate` (fraction of parseable answers; a low value marks a format-limited score), so scores are recomputable |
| `status` / `invalidReasons` | `ok \| invalid \| error \| skipped`. Since v2 a timed LLM iteration generating fewer than 16 chars is gated `degenerate-output` and the cell is `invalid`. `skipped` cells carry the reason in `invalidReasons` (`runtime unavailable: ...`, `lane disabled by the submitter`); since bench 0.4.0 every cell a suite defines is present, so a suite label describes what was attempted and a skipped cell says why it was not |
| `discardedIterations` | Since bench 0.5.0: timed iterations the tab was hidden during, kept with their gates (`started-hidden`, `hidden-during-run`) and never scored; the runner waited for the tab and repeated each of them (`iteration-redo` trace event) |
| `attempts` | Since bench 0.5.0: failed attempts that preceded the recorded outcome, oldest first (`{ error, at }`); the runner retries a cell up to twice after a watchdog timeout or a provider error and never silently |
| `error` | `{ name, message, cause?, causeName?, causeStack? }` for `error` cells; since v2 `cause` carries the wrapped provider error's message, and since bench 0.4.0 `causeName` its name and `causeStack` its stack (capped at 4,000 characters; a WASM abort such as wllama's `RuntimeError` "(ABORT) " names its native frame only there) |
| `status` | `ok \| invalid \| error \| skipped` - invalid cells carry `invalidReasons`, never silent retries |

## Metric definitions (how to recompute)

- **TTFT** = first chunk with `c > 0` → `t − startT`.
- **Decode chars/s** = `(Σ chunk chars − first chunk chars) / (t_last − t_first) × 1000` - endpoints-based, first token excluded (MLPerf Client TPS definition).
- **Tokens/s** - apply the model's tokenizer to `text` post-hoc; provider-reported `providerUsage` is auxiliary only (its `fidelity` field says why: `estimated` or `chunk-count`).

`index/summary.json` is an array of light per-run summaries (`RunIndexEntry` in [`apps/ui/src/lib/bench/store.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/src/lib/bench/store.ts)) used to render the leaderboard without fetching every run file. Entries written since bench 0.3.0 also carry the run's disclosed device identity (`engine`, `osVersion`, `architecture`, `gpuArchitecture`, `gpuModel`, `deviceType`, `deviceModel`, `cores`, `deviceMemoryGB`, `jsHeapSizeLimitBytes`, `storageQuotaBytes`, `crossOriginIsolated`, `webgpu`, `timerResolutionUs`, `webdriver`), `harnessVersion`, `runtimeVersions`, `userReportedDevice`, and each cell's `runtimeVersion`, so cohort analyses can run on the index alone.

## Schema versions

- **3** (2026-09-21) - privacy pass. Not captured any more: `locale.timeZone`, `timeZoneOffsetMinutes`, `calendar`, `languages`, `power.chargingTimeSec` / `dischargingTimeSec`, `display.prefersReducedMotion` / `prefersColorScheme`; `power.level` rounded to the quarter; the submission nonce is never published and the digest no longer covers it. Every file published earlier (all from the maintainers' own devices) was rewritten by `tools/scrub-publication.mjs` on 2026-09-21: the fields above removed, `schemaVersion` raised to 3, the digest recomputed, `scrubbedAt` stamped. No measurement changed; the protocol stays `localmode-bench/4`.
- **2** (2026-09-19) - protocol v2 fields (`streamIncremental`, `overallCharsPerSec`, quality raw outputs).
- **1** (2026-09-18) - initial.

## Protocol versions

- **`localmode-bench/4`** (2026-09-20) - the llama.cpp lanes (`wllama`, `wllama-webgpu`) load every language model as text only (`runtimeConfig.mmproj: false`). Under v3 the Gemma 4 E2B pairing also loaded the 557 MB vision projector the provider catalog lists for it: unused by the text-only workloads, downloaded and CLIP-warmed inside the untimed warmup, it turned wllama's model cache off for the two-file source (the warmup and the warm reload re-downloaded the 3.46 GB weights) and did not fit the CPU lane's 4 GB wasm heap (all three `wllama/gemma-4-e2b` cells errored on every Thorough run). Other pairings measure exactly as under v3. wllama `warm-reload` cells carry `offloadedLayers: "unreported"` and the lane's requested backend in every version: the warm reload times the provider's preload path (an OPFS cache probe), and llama.cpp loads in the untimed warmup of the timed cells. Schema and plausibility rules unchanged.
- **`localmode-bench/3`** (2026-09-20) - the wllama lane split into `wllama` (llama.cpp WASM on the CPU, `n_gpu_layers: 0`) and `wllama-webgpu` (every layer offloaded) over the same GGUF files, after llama.cpp's load log showed the v2 lane offloading to WebGPU by default on every WebGPU-capable browser while the files recorded `wasm`; cells carry `runtimeConfig`; the recorded backend follows llama.cpp's offload report. Schema and plausibility rules unchanged. Read archived v2 wllama cells as WebGPU wherever `environment.gpu.available` is true.
- **`localmode-bench/2`** (2026-09-19) - TTFT/decode derived only from genuinely incremental chunk traces (non-incremental lanes report an end-to-end rate via the `totalMs`/`overallCharsPerSec` summaries); quality lane: 48-token budget, reasoning-block stripping, uniform per-pairing no-think suffixes, raw outputs + parse rate stored; degenerate-output gate (< 16 generated chars invalidates the cell); every runtime receives the prompt as a single templated user turn with cross-request prompt caching disabled; error causes preserved; deterministic runtime execution order for reproducibility.
- **`localmode-bench/1`** (2026-09-18) - initial public protocol.

Full definitions: https://localmode.ai/bench/methodology
