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

## Integrity model (summary)

Every submission carries a server-issued session nonce and a canonical-JSON SHA-256 digest, and is checked against versioned plausibility rules: timestamp monotonicity, decode-rate envelopes by model size, text/chunk-length agreement, timer-quantization-grid conformance, environment cross-field consistency, and a mandatory deterministic matmul hardware-calibration check. Failing runs are quarantined, never silently dropped. Leaderboard rows need 3+ concordant submissions to leave provisional status, and only medians of per-device medians are shown. Full rules: [methodology](https://localmode.ai/bench/methodology).

Known limits, stated honestly: background native load, virtual machines, and browser flags cannot be detected from inside a page. The min-3-submissions rule and median-of-medians aggregation bound their influence.

Known device limitation: on the Galaxy Z Fold 7 (Adreno 830, Chrome 153 on Android) the llama.cpp WebGPU lane (`wllama-webgpu`) generates incoherent SmolLM2 text. All 18 timed chat iterations recorded on that phone across six runs and three protocol versions are strings of isolated letters and word fragments, and the lane's MMLU cell fails in every run with "Invalid typed array length". The WASM lane and every other runtime on the same phone produce coherent text, and no other device in the dataset shows this. The degenerate-output gate is length-based and 17 of the 18 iterations pass it, so those cells are `ok` and the `android/adreno-830` `wllama-webgpu` SmolLM2 `chat-pp128-tg128` rows (v4 and v5, plus a v2 `android/adreno-830` `wllama` row from before the lane split) are kept: they time a backend that is not producing a usable answer. Each iteration's `text` is in the run files, so anyone can check it. An output-coherence check would be a protocol change and is reserved for a future version.

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
