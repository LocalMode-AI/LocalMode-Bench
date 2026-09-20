# LocalMode Bench - Open Data

Open dataset of community-submitted [LocalMode Bench](https://localmode.ai/bench) runs: LLM and embedding inference measured across browser AI runtimes on real consumer devices, with raw timing traces so every published number can be independently recomputed.

- **What is measured** - time-to-first-token, decode throughput (first token excluded), pp128/pp512 prefill, cold vs warm model loads, single vs batch-32 embedding performance, and optional quality-fidelity scores, per the versioned protocol ([`localmode-bench/3`](https://localmode.ai/bench/methodology) is current; every run file records the version it was measured under, and the leaderboard aggregates only the current one).
- **Which runtimes** - WebLLM (MLC), wllama (llama.cpp WASM), Transformers.js (WebGPU and WASM), LiteRT-LM, Chrome Built-in AI (Gemini Nano), and MediaPipe text embeddings - with the same weights family compared engine-to-engine where the catalogs allow (e.g. Qwen3-0.6B across four runtimes; Gemma 4 E2B across three in the thorough suite). The authoritative model catalog is versioned with the harness ([`catalog.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/src/lib/bench/catalog.ts)); each run file records the exact provider model id, quantization, and declared size of every lane it ran.
- **Why raw traces** - each run file contains per-chunk timestamp arrays, the generated text for the fixed public prompts, the full environment capture, and a SHA-256 digest. Summaries on the [leaderboard](https://localmode.ai/bench) are recomputed server-side from these traces; nothing is trusted from the client.
- **License** - [CC0 1.0](./LICENSE) (public domain). Submitters agree at submission time; no personal data is collected.

## Repository layout

| Path | Contents |
| --- | --- |
| `runs/YYYY/MM/<runId>.json` | Verified submissions (ran on the official site, passed all integrity rules) |
| `quarantine/YYYY/MM/<runId>.json` | Submissions flagged by the published integrity rules - kept public and auditable, hidden from the leaderboard |
| `index/summary.json` | Machine-written leaderboard index (light per-run summaries). **Do not edit by hand** - it is rebuilt by the submission API |

Files are written by the submission API at [localmode.ai/bench](https://localmode.ai/bench); this repository accepts no direct pull requests for run data (PRs improving documentation are welcome).

## Integrity model (summary)

Every submission carries a server-issued session nonce and a canonical-JSON SHA-256 digest, and is checked against versioned plausibility rules: timestamp monotonicity, decode-rate envelopes by model size, text/chunk-length agreement, timer-quantization-grid conformance, environment cross-field consistency, and a mandatory deterministic matmul hardware-calibration check. Failing runs are quarantined, never silently dropped. Leaderboard rows need 3+ concordant submissions to leave provisional status, and only medians of per-device medians are shown. Full rules: [methodology](https://localmode.ai/bench/methodology).

Known limits, stated honestly: background native load, virtual machines, and browser flags cannot be detected from inside a page. The min-3-submissions rule and median-of-medians aggregation bound their influence.

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
`llama-bench` binary on `PATH`; the published baselines use llama.cpp commit
`60b06ab` built from source. Never run it while a browser benchmark runs on
the same machine.
