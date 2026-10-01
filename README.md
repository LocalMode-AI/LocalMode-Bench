# LocalMode Bench - Open Data

Open dataset of community-submitted [LocalMode Bench](https://localmode.ai/bench) runs: LLM and embedding inference measured across browser AI runtimes on real consumer devices, with raw timing traces so every published number can be independently recomputed.

- **What is measured** - time-to-first-token, decode throughput (first token excluded), pp128/pp512 prefill, cold vs warm model loads, single vs batch-32 embedding performance, and optional quality-fidelity scores, per the versioned protocol ([`localmode-bench/5`](https://localmode.ai/bench/methodology) is current; every run file records the version it was measured under, and the leaderboard shows the current protocol and the previous one in separate rows, never mixed, and nothing older).
- **Which runtimes** - WebLLM (MLC), wllama (llama.cpp WASM), Transformers.js (WebGPU and WASM), LiteRT-LM, Chrome Built-in AI (Gemini Nano), and MediaPipe text embeddings - with the same weights family compared engine-to-engine where the catalogs allow (e.g. Qwen3-0.6B across four runtimes; Gemma 4 E2B across three in the thorough suite). The authoritative model catalog is versioned with the harness ([`catalog.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/src/lib/bench/catalog.ts)); each run file records the exact provider model id, quantization, and declared size of every lane it ran.
- **Why raw traces** - each run file contains per-chunk timestamp arrays, the generated text for the fixed public prompts, the full environment capture, and a SHA-256 digest. Summaries on the [leaderboard](https://localmode.ai/bench) are recomputed server-side from these traces; nothing is trusted from the client.
- **License** - [CC0 1.0](./LICENSE) (public domain). Submitters agree at submission time.
- **Privacy** - a run file describes a device, never a person: browser and OS versions, device model, GPU, screen size, storage quota, network type, and the runtime configuration. It does not carry a time zone or language list, an exact battery figure (level to the quarter only), display preferences, the submission nonce, or the submitter's network address (used by the server as a rate-limit key only and never written). Paid-study runs carry a 12-hex SHA-256 prefix of the participant id, never the id. Files published before schema 3 (2026-09-21) were rewritten to this rule; see `scrubbedAt` in [SCHEMA.md](./SCHEMA.md).

## Repository layout

| Path | Contents |
| --- | --- |
| `runs/YYYY/MM/<runId>.json` | Verified submissions (ran on the official site, passed all integrity rules) |
| `quarantine/YYYY/MM/<runId>.json` | Submissions flagged by the published integrity rules - kept public and auditable, hidden from the leaderboard |
| `index/summary.json` | Machine-written leaderboard index (light per-run summaries). **Do not edit by hand** - it is rebuilt by the submission API |
| `native/YYYY/MM/<device>/` | Native `llama-bench` baselines on lab machines that also have browser runs: the same GGUF files and workload shapes as the llama.cpp lanes, run outside the browser (CPU thread sweep and the platform GPU backend), with every result row, the exact commands, the toolchain build and the machine's own capture. Maintainer-committed, not written by the submission API; not part of the leaderboard |

Files are written by the submission API at [localmode.ai/bench](https://localmode.ai/bench); this repository accepts no direct pull requests for run data (PRs improving documentation are welcome).

The submission API appends one entry per run to `index/summary.json`. The index can be regenerated from every file under `runs/` and `quarantine/` with [`apps/ui/scripts/rebuild-bench-index.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/scripts/rebuild-bench-index.ts) in the LocalMode monorepo (`pnpm exec tsx scripts/rebuild-bench-index.ts --dataset <clone>` from `apps/ui`), which writes the same entries the submission API writes, in `createdAt` order, and refuses to drop a run the current index lists.

## Integrity model (summary)

Every submission carries a server-issued session nonce and a canonical-JSON SHA-256 digest, and is checked against versioned plausibility rules: timestamp monotonicity, decode-rate envelopes by model size, text/chunk-length agreement, timer-quantization-grid conformance, environment cross-field consistency, and a mandatory deterministic matmul hardware-calibration check. Failing runs are quarantined, never silently dropped. Leaderboard rows need 3+ concordant submissions to leave provisional status, and only medians of per-device medians are shown. Full rules: [methodology](https://localmode.ai/bench/methodology).

Known limits, stated honestly: background native load, virtual machines, and browser flags cannot be detected from inside a page. The min-3-submissions rule and median-of-medians aggregation bound their influence.

Known device limitation: on the Galaxy Z Fold 7 (Adreno 830, Chrome 153 on Android) the llama.cpp WebGPU lane (`wllama-webgpu`) generates incoherent SmolLM2 text. All 18 timed chat iterations recorded on that phone across six runs and three protocol versions are strings of isolated letters and word fragments, and the lane's MMLU cell fails in every run with "Invalid typed array length". The WASM lane and every other runtime on the same phone produce coherent text, and no other device in the dataset shows this. The degenerate-output gate is length-based and 17 of the 18 iterations pass it, so those cells are `ok` and the `android/adreno-830` `wllama-webgpu` SmolLM2 `chat-pp128-tg128` rows (v4 and v5, plus a v2 `android/adreno-830` `wllama` row from before the lane split) are kept: they time a backend that is not producing a usable answer. Each iteration's `text` is in the run files, so anyone can check it. An output-coherence check would be a protocol change and is reserved for a future version.

Known prompt limitation: the Llama 3.2 1B chat template writes the current local date into its default system header ("Today Date: 25 Sep 2026", through the template's `strftime_now`). The bench sends no system prompt, so on the three Llama lanes that render this template (`transformers-webgpu`, `wllama` and `wllama-webgpu`) the prompt changes with the device's local calendar date. Decoding is greedy, so on the `transformers-webgpu` lane each date yields a different fixed output, and the decode rate follows the text: with no change to the model files, the browser or the harness, the pp128 decode rate of one machine moved by about 9 to 13% from one date to another, stepping at local midnight on the two machines that ran across it, and one tinyMMLU item changed from wrong to right. The `wllama` and `wllama-webgpu` Llama cells already produce a different `text` in every iteration, so there the date changes the prompt without leaving a mark in the output. The Qwen3, Gemma 4 and SmolLM2 templates carry no date on any lane. WebLLM's templates insert a fixed default system message instead (for Llama 3.2 1B, "You are a helpful, respectful and honest assistant."), so the prompts of one pairing already differ across runtimes; runtime-native templating is part of what is measured. In practice: same-day comparisons on a Llama lane use identical prompts; comparisons across days carry the date effect; and for crowd submissions the local date cannot be recovered (schema 3 stopped recording the time zone), so a Llama-lane row aggregates runs made with different prompts. Each iteration's `text` is in the run files, so anyone can partition the `transformers-webgpu` Llama cells by output. Pinning the date (or sending one fixed system prompt on every lane) and recording a digest of the rendered prompt per cell would be a protocol change and are reserved for a future version; no run is re-scored.

## Reproduce / analyze

The reference implementation is the MIT-licensed [`@localmode/bench`](https://github.com/LocalMode-AI/LocalMode/tree/main/packages/bench) package in the LocalMode monorepo. To rebuild every statistic from this dataset:

```bash
git clone https://github.com/LocalMode-AI/LocalMode-Bench
git clone https://github.com/LocalMode-AI/LocalMode
cd LocalMode && pnpm install
npx tsx packages/bench/scripts/analyze.ts ../LocalMode-Bench/runs ./analysis
# -> analysis/leaderboard.csv, analysis/iterations.csv, analysis/validation.txt
```

The run-file schema is documented in [SCHEMA.md](./SCHEMA.md). To contribute a run, open [localmode.ai/bench/run](https://localmode.ai/bench/run) on your device, run a suite, and press "Submit to leaderboard".

## Citing this dataset

See [CITATION.cff](./CITATION.cff). If you use this data in academic work, please cite the dataset and the protocol version(s) of the runs you used (each run file embeds its `protocol` field).

## Native baseline tooling

`tools/run-llama-bench.sh` runs llama.cpp's `llama-bench` on the same four GGUF
files the browser wllama lanes use, with the protocol's workload shape (pp128
and pp512 prefill, tg128 decode, 5 repetitions) in a GPU arm (Metal, `-ngl 99`)
and a CPU arm (`-ngl 0`, the comparator for the WASM lane). It needs a
`llama-bench` binary on `PATH`. Each baseline folder's `README.md` and
`environment.json` record the exact llama.cpp build used on that device
(commit, build number, install route, backends); the M1 Pro baseline
(`native/2026/09/m1-pro/`) used the Homebrew llama.cpp 0.4.1 bottle
(`arm64_tahoe`), build `b29c606e2` (10964), backends `BLAS,MTL`. Never run it
while a browser benchmark runs on the same machine.

| folder | machine | llama.cpp build | configurations |
| --- | --- | --- | --- |
| `native/2026/09/m1-pro/` | MacBook Pro, Apple M1 Pro (8 P + 2 E cores), 32 GB, macOS 26.5.2 | Homebrew 0.4.1 bottle, `b29c606e2` (10964), `BLAS,MTL` | CPU `-t 10, 8, 6, 4`; Metal `-ngl 99` |
| `native/2026/10/ryzen-9800x3d/` | Desktop, AMD Ryzen 7 9800X3D (8 cores, 16 threads), 96 GB, integrated Radeon (2 CUs), Windows 11 25H2 (26200.9457), AMD Software 26.8.1 | local MSVC builds at `b29c606e2` (10964): CPU-only (`GGML_NATIVE`, AVX-512) and Vulkan | CPU `-t 16, 12, 8, 4`; Vulkan `-ngl 99 -t 8` |
| `native/2026/10/core-ultra-165h/` | Dell XPS 13 9340, Intel Core Ultra 7 165H (6 P + 8 E + 2 LP-E cores, 22 threads), 16 GB, Arc iGPU, CachyOS kernel 7.0.3-1, Mesa 26.2.3 | local GCC builds at `b29c606e2` (10964): CPU-only (`-march=native`) and Vulkan (ANV) | CPU `-t 22, 16, 11, 6, 4` and `-t 6` pinned one per P-core; Vulkan `-ngl 99 -t 11` |

Each folder's `README.md` records the exact commands, the waits, the machine's state and every failure. The bge-small embedding run (`-embd 1 -p 48,1536`) aborts at `pp1536` on all three machines at this commit (`encoder requires n_ubatch >= n_tokens`), after `pp48` completes; the two newer folders add a `-p 512` embedding run inside the default micro-batch. The Core Ultra Vulkan rows ran on Mesa 26.2.3, not the 26.0.6 of that machine's browser runs.
