# Native baseline for the LocalMode Bench methodology: llama-bench on an Apple M1 Pro

This directory holds the native `llama-bench` baseline for the LocalMode Bench methodology, produced on the same MacBook Pro (Apple M1 Pro, 8 performance + 2 efficiency cores, 32 GB) as the browser runs recorded for that machine, on the same five GGUF files and with the same workload shapes. Everything below is taken from the run's own logs.

## Files

| file | contents |
|---|---|
| `llama-bench.json` | every result object from every `llama-bench` invocation, concatenated in run order, every field kept as emitted (`model_filename` is the bare file name) |
| `llama-bench.md` | one table per model, `mean ± sd` tokens/s, plus the resolved defaults and the status of every invocation |
| `environment.json` / `environment.txt` | machine, OS, power and thermal state at the start, toolchain, llama.cpp build (parsed / raw) |
| `models.json` | file name, source URL, size in bytes and SHA-256 of each GGUF |
| `README.md` | this file |

## Wall clock (UTC)

- session start (first command, before installing anything): `2026-09-22T07:42:42Z (first command of the session)`
- environment captured: `Tue Sep 22 07:43:31 UTC 2026`
- measurement run start: `2026-09-22T07:51:12Z`
- measurement run end: `2026-09-22T08:18:34Z`
- session end: `2026-09-22T08:20:19Z`

## Machine and software

- `Apple M1 Pro`, 10 cores: 8 Performance + 2 Efficiency; GPU `Apple M1 Pro` with 16 cores, Metal 4; 32 GiB RAM
- macOS 26.5.2 (25F84), `arm64`
- power at start: `AC Power`, battery 76%; `pmset -g therm` at start: no thermal or performance warning level recorded
- llama.cpp installed via `brew install llama.cpp` (route `brew`): formula `homebrew/core llama.cpp` version **0.4.1**, poured from the `arm64_tahoe` bottle, ggml 0.24.0; binary `/opt/homebrew/bin/llama-bench`
- `llama-bench` build line: `build: b29c606e2 (10964)`; JSON `build_commit` = `b29c606e2`, `build_number` = `10964`; `cpu_info` = `Accelerate, Apple M1 Pro`, `gpu_info` = `Apple M1 Pro`, `backends` = `BLAS,MTL`
- toolchain: Xcode Command Line Tools at `/Library/Developer/CommandLineTools` (no full Xcode: `xcodebuild -version` printed nothing), Homebrew 6.0.12
- keep-awake: caffeinate -dims wrapping the whole run script; per-invocation timeout: perl -e 'alarm shift; exec @ARGV' 1200 llama-bench ... (SIGALRM after 20 min; coreutils timeout not installed)
- background: Chrome quit before the run (no localmode.ai/bench/run tab was open among its tabs); Safari and Firefox not running. Remaining non-system CPU users at launch: the terminal emulator (~5% of one core) and the CLI agent driving the session (~10% of one core). Load average had fallen from 20 (Chrome open) to about 3 before the first measurement.

## Model files

Downloaded with `curl -L --fail -o <name> <url>` into the models directory (two attempts allowed; none needed a second attempt). Sizes and hashes are of the files actually benchmarked.

| bench model id | file | bytes | sha256 | source |
|---|---|---:|---|---|
| smollm2-135m | `SmolLM2-135M-Instruct-Q4_K_M.gguf` | 105454432 | `2e8040ceae7815abe0dcb3540b9995eaa1fa0d2ca9e797d0a635ae4433c68c2d` | https://huggingface.co/bartowski/SmolLM2-135M-Instruct-GGUF/resolve/main/SmolLM2-135M-Instruct-Q4_K_M.gguf |
| qwen3-0.6b | `Qwen3-0.6B-Q4_K_M.gguf` | 396705472 | `ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a` | https://huggingface.co/unsloth/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_K_M.gguf |
| llama-3.2-1b | `Llama-3.2-1B-Instruct-Q4_K_M.gguf` | 807694464 | `6f85a640a97cf2bf5b8e764087b1e83da0fdb51d7c9fab7d0fece9385611df83` | https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf |
| gemma-4-e2b | `google_gemma-4-E2B-it-Q4_K_M.gguf` | 3462680032 | `923c4c86177d2ee173a7f5b4fa3d0ac65f5962ab15e6d6a5bc250aec4fd7bf7e` | https://huggingface.co/bartowski/google_gemma-4-E2B-it-GGUF/resolve/main/google_gemma-4-E2B-it-Q4_K_M.gguf |
| bge-small-en | `bge-small-en-v1.5-q8_0.gguf` | 36806944 | `ec38e8da142596baa913124ae50550de284b6916bf59577ef2f0cb9660c2f514` | https://huggingface.co/CompendiumLabs/bge-small-en-v1.5-gguf/resolve/main/bge-small-en-v1.5-q8_0.gguf |

Note: the task sheet's approximate sizes were about 70 MB for SmolLM2-135M and about 530 MB for Qwen3-0.6B; the files at the given URLs are 105 MB and 397 MB. The URLs were used exactly as given.

## Method

- All commands ran from inside the models directory with relative model paths, so `llama-bench` recorded only file names.
- Each invocation wrote `-o json` to its own file and `-oe md` (llama-bench's markdown table and `build:` line) to stderr; these two output-format flags are the only additions to the command lines below. Nothing else was set: `-b`, `-ub`, `-fa`, `-ctk`, `-ctv`, `-mmp` and all other options were left at the build's defaults, which the JSON records (seen values: `n_batch` `2048`, `n_ubatch` `512`, `flash_attn` `-1` (-1 = auto), `type_k` `"f16"`, `type_v` `"f16"`, `no_kv_offload` `false`, `no_op_offload` `0`, `load_mode` `"auto"`, `cpu_mask` `"0x0"`, `cpu_strict` `false`, `poll` `50`).
- `-r 5`: five timed repetitions per test after llama-bench's own warmup (the browser Thorough suite ran 5 timed iterations after 1 untimed warmup).
- Shapes: prompt 128 and 512 tokens (`-p 128,512`), generation 128 tokens (`-n 128`), and prompt-then-generate `-pg 128,128` and `-pg 512,128`. Embedding model: `-embd 1 -p 48,1536 -n 0` (one ~200-character text is about 48 tokens; a batch of 32 such texts is about 1536 tokens).
- Order: 4a (CPU, `-ngl 0`, threads 10, 8, 6, 4) for each language model in the order SmolLM2, Qwen3, Llama 3.2, Gemma 4; then 4b (Metal, `-ngl 99`) for each language model in the same order; then 4c (embedding model: CPU t=10, CPU t=8, Metal).
- `sleep 30` between consecutive invocations; `pmset -g therm` recorded before each model in each section (see below).
- The whole run was wrapped in `caffeinate -dims`; every invocation had a hard 20-minute limit (`perl -e 'alarm shift; exec @ARGV' 1200 llama-bench ...`, SIGALRM).
- Before the run: Chrome was quit (no `localmode.ai/bench/run` tab was open), Safari and Firefox were not running, the machine was on AC power. Two short smoke tests (SmolLM2 `-p 16 -n 8 -r 1`; bge `-embd 1 -p 16 -n 0 -r 1` on CPU and Metal) and one diagnostic (SmolLM2 `-ngl 0 -p 512 -n 0 -r 3` with and without `-nopo 1`) were run beforehand to check the output format and flags; they are not measurements and are not included in the results.
- The `-nopo` diagnostic: with op-offload disabled pp512 was 1386 ± 41 t/s, at the default 1317 ± 42 and 1335 ± 90 t/s, i.e. the same within noise. So `-ngl 0` here really runs on the CPU; the Metal backend is present (`backends` = `BLAS,MTL`) but does not take prompt batches when no layers are offloaded.
- The Homebrew build's CPU path uses Apple Accelerate BLAS (`cpu_info` = `Accelerate, Apple M1 Pro`). That is this build's default and was left in place.

## Every invocation, in order

Commands are exactly as executed (from inside the models directory). `wall s` is the whole process lifetime including model load and warmup.

| # | invocation | command | status | wall s |
|---:|---|---|---|---:|
| 1 | 4a_smollm2-135m_cpu_t10 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 24 |
| 2 | 4a_smollm2-135m_cpu_t8 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 12 |
| 3 | 4a_smollm2-135m_cpu_t6 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 12 |
| 4 | 4a_smollm2-135m_cpu_t4 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 14 |
| 5 | 4a_qwen3-0.6b_cpu_t10 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 44 |
| 6 | 4a_qwen3-0.6b_cpu_t8 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 29 |
| 7 | 4a_qwen3-0.6b_cpu_t6 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 37 |
| 8 | 4a_qwen3-0.6b_cpu_t4 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 44 |
| 9 | 4a_llama-3.2-1b_cpu_t10 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 53 |
| 10 | 4a_llama-3.2-1b_cpu_t8 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 39 |
| 11 | 4a_llama-3.2-1b_cpu_t6 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 49 |
| 12 | 4a_llama-3.2-1b_cpu_t4 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 62 |
| 13 | 4a_gemma-4-e2b_cpu_t10 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 129 |
| 14 | 4a_gemma-4-e2b_cpu_t8 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 94 |
| 15 | 4a_gemma-4-e2b_cpu_t6 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 113 |
| 16 | 4a_gemma-4-e2b_cpu_t4 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 141 |
| 17 | 4b_smollm2-135m_metal | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 9 |
| 18 | 4b_qwen3-0.6b_metal | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 14 |
| 19 | 4b_llama-3.2-1b_metal | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 18 |
| 20 | 4b_gemma-4-e2b_metal | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` | OK | 44 |
| 21 | 4c_bge-small-en_cpu_t10 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 10 -p 48,1536 -n 0 -r 5 -o json -oe md` | FAILED(rc=134) | 0 |
| 22 | 4c_bge-small-en_cpu_t8 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` | FAILED(rc=134) | 0 |
| 23 | 4c_bge-small-en_metal | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -p 48,1536 -n 0 -r 5 -o json -oe md` | FAILED(rc=134) | 0 |

## Failed or skipped

- `4c_bge-small-en_cpu_t10`: FAILED(rc=134) after 0 s (rc 134 = SIGABRT). Error: `src/llama-context.cpp:1437: GGML_ASSERT(cparams.n_ubatch >= n_tokens && "encoder requires n_ubatch >= n_tokens") failed`. Tests completed and written before the abort: pp48 = 7090.22 ± 525.10 t/s; the remaining test(s) of this invocation were not run. The JSON array was closed by the aggregation step (noted in `llama-bench.md`).
- `4c_bge-small-en_cpu_t8`: FAILED(rc=134) after 0 s (rc 134 = SIGABRT). Error: `src/llama-context.cpp:1437: GGML_ASSERT(cparams.n_ubatch >= n_tokens && "encoder requires n_ubatch >= n_tokens") failed`. Tests completed and written before the abort: pp48 = 9906.22 ± 82.21 t/s; the remaining test(s) of this invocation were not run. The JSON array was closed by the aggregation step (noted in `llama-bench.md`).
- `4c_bge-small-en_metal`: FAILED(rc=134) after 0 s (rc 134 = SIGABRT). Error: `src/llama-context.cpp:1437: GGML_ASSERT(cparams.n_ubatch >= n_tokens && "encoder requires n_ubatch >= n_tokens") failed`. Tests completed and written before the abort: pp48 = 8868.74 ± 701.13 t/s; the remaining test(s) of this invocation were not run. The JSON array was closed by the aggregation step (noted in `llama-bench.md`).

The three 4c invocations all aborted at the same place: bge-small-en-v1.5 is an encoder (BERT) model, and this build's `llama_context::encode` requires the whole prompt to fit in one micro-batch (`n_ubatch`, default 512), so the 1536-token test cannot run with the defaults. Per the plan the defaults were left alone and the test was recorded as failed rather than re-run with a larger `-ub`. The 48-token test ran to completion in each of the three invocations and those results are in `llama-bench.json`.

## Thermal readings (`pmset -g therm`, with the first line of `pmset -g batt`)

```
### 2026-09-22T07:51:12Z run start
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T07:51:13Z 4a before smollm2-135m
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T07:53:45Z 4a before qwen3-0.6b
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T07:58:19Z 4a before llama-3.2-1b
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T08:03:42Z 4a before gemma-4-e2b
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T08:13:39Z 4b before smollm2-135m
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T08:14:18Z 4b before qwen3-0.6b
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T08:15:02Z 4b before llama-3.2-1b
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T08:15:50Z 4b before gemma-4-e2b
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T08:17:04Z 4c before bge-small-en
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
### 2026-09-22T08:18:34Z run end
Note: No thermal warning level has been recorded
Note: No performance warning level has been recorded
Note: No CPU power status has been recorded
Now drawing from 'AC Power'
```

## Reading the numbers against the browser lanes

- `tg128` in `llama-bench` generates 128 tokens from an empty context. The browser lanes measure decode tokens/s after a real 128- or 512-token prompt. The `pg128+128` and `pg512+128` rows (prompt then generate, reported as total tokens over total time) are the closer analogue; a decode-only rate after the prompt can be derived from them together with the matching `pp` row (total time minus prompt time).
- `pp128` / `pp512` tokens/s correspond to the browser's estimated prefill rate; 128 or 512 divided by that rate is the closest analogue of the browser's time to first token.
- For the embedding model, `pp48` tokens/s divided by 48 is texts per second for a single ~200-character text, and `pp1536` divided by 48 is texts per second for the 32-text batch.
- The browser CPU lane ran llama.cpp compiled to WebAssembly with `n_threads: 10`; the native CPU rows are `-ngl 0` with `-t 10`, `-t 8` (performance cores only), `-t 6` and `-t 4`. The browser WebGPU lane offloaded every layer to WebGPU; the native `metal` rows are `-ngl 99`.

