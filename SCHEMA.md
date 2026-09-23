# Run file schema

Every file under `runs/` and `quarantine/` is one `BenchRunResult` JSON object, produced by [`@localmode/bench`](https://github.com/LocalMode-AI/LocalMode/tree/main/packages/bench) (current: schema version 3, protocol `localmode-bench/5`; files record the protocol they were measured under, and archived runs are never re-scored). The TypeScript source of truth is [`packages/bench/src/types.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/packages/bench/src/types.ts); the executable validator is `validateRunShape()` / `validateSubmission()` in the same package.

## Top level

| Field | Type | Meaning |
| --- | --- | --- |
| `protocol` | `"localmode-bench/5"` (older files: `"localmode-bench/1"` to `"localmode-bench/4"`; the leaderboard shows v5 and v4 rows side by side, never mixed) | Versioned protocol identifier |
| `schemaVersion` | `3` (older files: `1` and `2` were rewritten to 3 by the scrub on 2026-09-21; see Schema versions) | Result JSON schema version |
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

Browser identity with provenance (`ua-ch` on Chromium; `ua-parse` elsewhere with `os.version: "unknown-frozen"` - UA strings are frozen by design; since bench 0.7.1 this includes iOS, where WebKit froze the token at `18_7`: a Safari or Firefox iOS run recorded earlier with `os.version: "18.7"` and a Safari version of 26 or higher is a frozen reading, and `browser.version` carries the OS generation), WebGPU adapter info (`vendor`, `architecture`, limits, features), hardware fields **labeled clamped** (`cores`, `deviceMemoryGB` - browsers cap or randomize them), cross-origin isolation, WASM SIMD, storage estimate, battery charging state, compute-pressure availability, inferred `timerResolutionUs`, and an optional `userReportedDevice` free-text field (displayed as user-reported, never trusted; paid-study runs carry `prolific:<12-hex SHA-256 prefix>` here, never a participant id).

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
| `runtimeConfig` | Since bench 0.5.0: the adapter's post-load configuration record, per cell (wllama: `n_threads` requested, `n_gpu_layers` requested, `webgpu_adapter`, `offloadedLayers` "N/M", `cache_prompt`, since v4 `mmproj: false` on language lanes, and, on runs whose `harness.runtimeVersions["@localmode/wllama"]` is 3.4.2 or later, `multithread` and `n_threads_used`, the pool wllama actually built from its own `isMultithread()` / `getNumThreads()`, so a lane that fell back to one thread says so; Transformers.js: `device`, `dtype`, `worker`) |
| `load` | Download/cache phase: `cached` (cold=false / warm=true), start/end timestamps, progress milestones |
| `warmupMs` | Untimed first-inference readiness (engine init + shader/JIT compile). Cold start = load + warmup |
| `iterations` | LLM: `{ startT, chunks: [{t, c}], endT, text, providerUsage?, finishReason, gates }` - per-chunk wall-clock trace + full generated text. Embedding: `{ startT, endT, count, dimensions, gates }` |
| `memory` | Bytes at protocol points (`baseline`/`postLoad`/`postRun`, and since v2 `atError` for cells that failed) + which API measured them |
| `quality` | Optional fidelity-lane score (tinyMMLU accuracy or STS-B Spearman). Since v2, MMLU cells also carry raw per-item `outputs` (capped at 400 chars each) and a `parseRate` (fraction of parseable answers; a low value marks a format-limited score), so scores are recomputable |
| `status` / `invalidReasons` | `ok \| invalid \| error \| skipped`. Since v2 a timed LLM iteration generating fewer than 16 chars is gated `degenerate-output` and the cell is `invalid`. The gate checks length only, not coherence: the Adreno 830 `wllama-webgpu` SmolLM2 chat cells are `ok` although their `text` is incoherent (see Known device limitation in the [README](./README.md)). `skipped` cells carry the reason in `invalidReasons` (`runtime unavailable: ...`, `lane disabled by the submitter`); since bench 0.4.0 every cell a suite defines is present, so a suite label describes what was attempted and a skipped cell says why it was not |
| `discardedIterations` | Since bench 0.5.0: timed iterations the tab was hidden during, kept with their gates (`started-hidden`, `hidden-during-run`) and never scored; the runner waited for the tab and repeated each of them (`iteration-redo` trace event) |
| `attempts` | Since bench 0.5.0: failed attempts that preceded the recorded outcome, oldest first (`{ error, at }`); the runner retries a cell up to twice after a watchdog timeout or a provider error and never silently |
| `error` | `{ name, message, cause?, causeName?, causeStack? }` for `error` cells; since v2 `cause` carries the wrapped provider error's message, and since bench 0.4.0 `causeName` its name and `causeStack` its stack (capped at 4,000 characters; a WASM abort such as wllama's `RuntimeError` "(ABORT) " names its native frame only there) |
| `status` | `ok \| invalid \| error \| skipped` - invalid cells carry `invalidReasons`, never silent retries |

## Metric definitions (how to recompute)

- **TTFT** = first chunk with `c > 0` → `t − startT`.
- **Decode chars/s** = `(Σ chunk chars − first chunk chars) / (t_last − t_first) × 1000` - endpoints-based, first token excluded (MLPerf Client TPS definition).
- **Tokens/s** - apply the model's tokenizer to `text` post-hoc; provider-reported `providerUsage` is auxiliary only (its `fidelity` field says why: `estimated` or `chunk-count`).

`index/summary.json` is an array of light per-run summaries (`RunIndexEntry` in [`apps/ui/src/lib/bench/store.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/src/lib/bench/store.ts)) used to render the leaderboard without fetching every run file. Each entry carries two device groupings: `deviceClass`, the coarse class every browser can supply (platform + WebGPU adapter vendor-architecture, e.g. `macos/apple-metal-3`, `windows/amd-rdna-2`, `linux/no-webgpu`), and, since bench 0.7.1, `deviceSubclass`, the class split by the GPU model where the browser names a specific part (`macos/apple-m1-pro`, `android/adreno-650`; `refineDeviceClass()` in `@localmode/bench`). Where the browser names nothing more specific (WebKit's `Apple GPU`, Windows' generation-less `AMD Radeon(TM) Graphics`, Firefox's masked `..., or similar` buckets) or the device has no WebGPU, the subclass equals the class. Entries written before 0.7.1 have no `deviceSubclass`; the leaderboard derives it from `deviceClass` and `gpuModel` with the same function, so the archive needs no rewrite. Leaderboard rows group by subclass; the coarse class remains the unit for cross-device rollups. Entries written since bench 0.3.0 also carry the run's disclosed device identity (`engine`, `osVersion`, `architecture`, `gpuArchitecture`, `gpuModel`, `deviceType`, `deviceModel`, `cores`, `deviceMemoryGB`, `jsHeapSizeLimitBytes`, `storageQuotaBytes`, `crossOriginIsolated`, `webgpu`, `timerResolutionUs`, `webdriver`), `harnessVersion`, `runtimeVersions`, `userReportedDevice`, and each cell's `runtimeVersion`, so cohort analyses can run on the index alone.

## Native baselines (`native/`)

`native/YYYY/MM/<device>/` holds `llama-bench` runs made outside the browser on lab machines that also have browser runs in `runs/`, so the browser lanes can be read against the native ceiling of the same weights on the same silicon. Each directory carries `llama-bench.json` (every result object `llama-bench` emitted, concatenated in run order; `model_filename` is the bare file name), `llama-bench.md` (mean ± sd tokens/s per model and configuration), `environment.json` / `environment.txt` (machine, OS, power and thermal state, toolchain, llama.cpp build), `models.json` (file, source URL, size, SHA-256 of each GGUF, the same files the browser lanes load), and a `README.md` with every command line, the order, the waits, and anything that failed or was skipped. Shapes match the browser cells (`-p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5`; note that `tg128` generates from an empty context, so the `pg` rows are the closer analogue of the browser's decode-after-prompt). These files are maintainer-committed, carry no digest or nonce, and are not aggregated into the leaderboard.

## Schema versions

- **3** (2026-09-21) - privacy pass. Not captured any more: `locale.timeZone`, `timeZoneOffsetMinutes`, `calendar`, `languages`, `power.chargingTimeSec` / `dischargingTimeSec`, `display.prefersReducedMotion` / `prefersColorScheme`; `power.level` rounded to the quarter; the submission nonce is never published and the digest no longer covers it. Every file published earlier (all from the maintainers' own devices) was rewritten by `tools/scrub-publication.mjs` on 2026-09-21: the fields above removed, `schemaVersion` raised to 3, the digest recomputed, `scrubbedAt` stamped. No measurement changed; the protocol stays `localmode-bench/4`.
- **2** (2026-09-19) - protocol v2 fields (`streamIncremental`, `overallCharsPerSec`, quality raw outputs).
- **1** (2026-09-18) - initial.

## Protocol versions

- **`localmode-bench/5`** (2026-09-22) - the llama.cpp lanes request half the browser's logical thread count (at least two) instead of all of it, and load with a 2,048-token context (`runtimeConfig.n_ctx`; the embedding lane 512). Under v4 a pool over every logical thread ran at half speed with high variance on hybrid and SMT processors (native M1 Pro sweep: tg128 178 ± 42 tokens/s at 10 threads, 395 ± 16 at 8; in the browser the M4 Max's 16-thread pool decoded a third as fast as the M1 Pro's 10); the browser exposes no core topology, so half the logical count is the rule, and both the requested count (`n_threads`) and the pool the runtime built (`multithread`, `n_threads_used`) are recorded. The smaller context is sized to the workloads (about 700 tokens) instead of the provider's 8,192 default and shrinks the Gemma 4 E2B GGUF's KV cache inside the CPU lane's 4 GB wasm heap; it does not rescue that lane's Gemma quality cell, which still fails on the per-request state allocation (`std::bad_alloc`) with the 3.46 GB weights resident and is recorded as an error, as under v4. Every other lane measures exactly as under v4; the leaderboard shows v4 rows beside v5 rows (rows never mix versions), and nothing is re-scored. Schema and plausibility rules unchanged.
- **`localmode-bench/4`** (2026-09-20) - the llama.cpp lanes (`wllama`, `wllama-webgpu`) load every language model as text only (`runtimeConfig.mmproj: false`). Under v3 the Gemma 4 E2B pairing also loaded the 557 MB vision projector the provider catalog lists for it: unused by the text-only workloads, downloaded and CLIP-warmed inside the untimed warmup, it turned wllama's model cache off for the two-file source (the warmup and the warm reload re-downloaded the 3.46 GB weights) and did not fit the CPU lane's 4 GB wasm heap (all three `wllama/gemma-4-e2b` cells errored on every Thorough run). Other pairings measure exactly as under v3. wllama `warm-reload` cells carry `offloadedLayers: "unreported"` and the lane's requested backend in every version: the warm reload times the provider's preload path (an OPFS cache probe), and llama.cpp loads in the untimed warmup of the timed cells. Schema and plausibility rules unchanged.
- **`localmode-bench/3`** (2026-09-20) - the wllama lane split into `wllama` (llama.cpp WASM on the CPU, `n_gpu_layers: 0`) and `wllama-webgpu` (every layer offloaded) over the same GGUF files, after llama.cpp's load log showed the v2 lane offloading to WebGPU by default on every WebGPU-capable browser while the files recorded `wasm`; cells carry `runtimeConfig`; the recorded backend follows llama.cpp's offload report. Schema and plausibility rules unchanged. Read archived v2 wllama cells as WebGPU wherever `environment.gpu.available` is true.
- **`localmode-bench/2`** (2026-09-19) - TTFT/decode derived only from genuinely incremental chunk traces (non-incremental lanes report an end-to-end rate via the `totalMs`/`overallCharsPerSec` summaries); quality lane: 48-token budget, reasoning-block stripping, uniform per-pairing no-think suffixes, raw outputs + parse rate stored; degenerate-output gate (< 16 generated chars invalidates the cell); every runtime receives the prompt as a single templated user turn with cross-request prompt caching disabled; error causes preserved; deterministic runtime execution order for reproducibility.
- **`localmode-bench/1`** (2026-09-18) - initial public protocol.

Full definitions: https://localmode.ai/bench/methodology
