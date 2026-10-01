# llama-bench results: native baseline for the LocalMode Bench methodology

llama.cpp build 10964 (b29c606e2), two local builds: CPU-only (backends `CPU`) and Vulkan (backends `Vulkan`), cpu_info `Intel(R) Core(TM) Ultra 7 165H`, gpu_info `Intel(R) Arc(tm) Graphics (MTL)` on the Vulkan rows. All values are tokens/s, mean ± sd over 5 timed repetitions (llama-bench does its own warmup). `cpu t=N` is `-ngl 0 -t N` with the CPU-only build; `cpu t=6 p-cores` is `-ngl 0 -t 6 -C 0x54B --cpu-strict 1` (one thread pinned to each performance core: logical CPUs 0, 1, 3, 6, 8, 10); `vulkan` is `-ngl 99 -t 11` with the Vulkan build (every layer offloaded to the Arc iGPU). `tg128` generates from an empty context; the `pg` rows (prompt then generate) are the closer analogue of the browser decode-after-prompt measurement. Cells marked \* have sd > 10% of the mean. The cell marked † excludes one invalid sample (see Parse notes).

## SmolLM2 135M Instruct Q4_K_M (`SmolLM2-135M-Instruct-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 561.55 ± 12.24 | 611.88 ± 22.50 | 33.29 ± 5.39 \* | 44.78 ± 1.36 | 92.06 ± 4.99 |
| cpu t=16 | 673.91 ± 27.67 | 638.70 ± 16.32 | 72.73 ± 1.16 | 90.24 ± 15.45 \* | 127.93 ± 15.62 \* |
| cpu t=11 | 696.09 ± 60.53 | 618.77 ± 12.56 | 101.09 ± 7.52 | 129.46 ± 12.46 | 159.62 ± 9.49 |
| cpu t=6 | 507.23 ± 39.05 | 491.56 ± 43.76 | 110.53 ± 3.78 | 125.10 ± 12.23 | 154.95 ± 9.03 |
| cpu t=4 | 445.92 ± 89.34 \* | 391.15 ± 18.67 | 106.73 ± 3.50 | 137.82 ± 8.40 | 160.21 ± 8.30 |
| cpu t=6 p-cores | 764.28 ± 3.30 | 554.86 ± 120.97 \* | 126.47 ± 6.99 | 177.67 ± 6.61 | 171.79 ± 9.07 |
| vulkan | 3204.52 ± 632.82 \* | 3469.64 ± 128.30 | 101.21 ± 15.51 \* | 148.56 ± 7.34 | 275.67 ± 15.19 |

## Qwen3 0.6B Q4_K_M (`Qwen3-0.6B-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 315.72 ± 4.39 | 289.65 ± 4.85 | 18.85 ± 4.67 \* † | 28.44 ± 1.75 | 55.27 ± 0.77 |
| cpu t=16 | 356.50 ± 4.19 | 296.09 ± 36.91 \* | 34.87 ± 5.71 \* | 42.46 ± 0.97 | 73.91 ± 0.86 |
| cpu t=11 | 319.22 ± 6.44 | 225.84 ± 52.80 \* | 38.69 ± 4.93 \* | 49.80 ± 1.04 | 74.99 ± 1.15 |
| cpu t=6 | 251.82 ± 10.60 | 167.68 ± 24.20 \* | 34.57 ± 2.47 | 46.19 ± 0.49 | 63.79 ± 2.73 |
| cpu t=4 | 218.59 ± 15.20 | 148.54 ± 6.98 | 34.82 ± 5.95 \* | 42.44 ± 0.74 | 62.73 ± 3.08 |
| cpu t=6 p-cores | 315.75 ± 5.78 | 189.06 ± 9.78 | 53.72 ± 2.91 | 51.10 ± 2.06 | 75.99 ± 11.92 \* |
| vulkan | 596.20 ± 23.94 | 879.51 ± 94.85 \* | 41.19 ± 4.33 \* | 106.90 ± 23.37 \* | 240.60 ± 10.23 |

## Llama 3.2 1B Instruct Q4_K_M (`Llama-3.2-1B-Instruct-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 171.99 ± 2.19 | 125.59 ± 23.03 \* | 17.18 ± 2.98 \* | 27.23 ± 0.60 | 46.47 ± 1.11 |
| cpu t=16 | 175.47 ± 1.00 | 115.48 ± 7.99 | 24.91 ± 4.90 \* | 33.44 ± 1.16 | 54.56 ± 1.54 |
| cpu t=11 | 165.10 ± 4.51 | 101.66 ± 6.40 | 26.98 ± 2.45 | 35.25 ± 0.47 | 53.16 ± 1.05 |
| cpu t=6 | 115.23 ± 23.54 \* | 74.83 ± 3.74 | 22.64 ± 1.92 | 30.66 ± 0.38 | 43.77 ± 1.05 |
| cpu t=4 | 94.02 ± 8.80 | 68.76 ± 4.72 | 19.25 ± 2.52 \* | 25.34 ± 0.51 | 38.11 ± 0.61 |
| cpu t=6 p-cores | 124.25 ± 27.94 \* | 81.35 ± 5.28 | 25.24 ± 1.91 | 34.04 ± 2.20 | 48.51 ± 3.40 |
| vulkan | 516.97 ± 80.65 \* | 606.07 ± 21.68 | 59.50 ± 0.97 | 73.04 ± 12.73 \* | 201.56 ± 5.46 |

## Gemma 4 E2B it Q4_K_M (`google_gemma-4-E2B-it-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 64.77 ± 7.18 \* | 41.77 ± 1.34 | 7.16 ± 0.54 | 11.89 ± 0.29 | 20.16 ± 0.62 |
| cpu t=16 | 65.91 ± 10.79 \* | 44.03 ± 1.33 | 9.55 ± 1.09 \* | 14.82 ± 0.18 | 24.03 ± 0.77 |
| cpu t=11 | 56.90 ± 11.84 \* | 40.07 ± 0.57 | 10.75 ± 0.72 | 15.91 ± 0.16 | 23.78 ± 0.49 |
| cpu t=6 | 39.30 ± 4.72 \* | 31.63 ± 0.33 | 10.07 ± 0.59 | 14.68 ± 0.08 | 20.50 ± 0.45 |
| cpu t=4 | 35.71 ± 2.59 | 27.89 ± 0.60 | 8.94 ± 0.74 | 12.51 ± 0.15 | 18.17 ± 0.62 |
| cpu t=6 p-cores | 47.62 ± 7.23 \* | 35.03 ± 0.32 | 11.88 ± 0.15 | 16.46 ± 0.42 | 23.69 ± 0.62 |
| vulkan | 164.03 ± 4.86 | 158.08 ± 4.21 | 18.29 ± 3.84 \* | 36.31 ± 0.48 | 60.78 ± 7.13 \* |

## bge-small-en-v1.5 q8_0 (`bge-small-en-v1.5-q8_0.gguf`), `-embd 1 -n 0`

`pp48` and `pp1536` come from the `-p 48,1536` invocations; `pp512` from the supplementary `-p 512` invocations, which ran only at the protocol thread count and on Vulkan.

| config | pp48 | pp1536 | pp512 |
|---|---:|---:|---:|
| cpu t=22 | 1781.43 ± 115.48 | failed | not run |
| cpu t=11 | 3001.78 ± 478.88 \* | failed | 3142.29 ± 44.85 |
| vulkan | 2520.48 ± 72.29 | failed | 6507.54 ± 457.76 |

## Resolved defaults (from the JSON output)

| field | value(s) seen |
|---|---|
| `n_batch` | `2048` |
| `n_ubatch` | `512` |
| `flash_attn` | `-1` |
| `type_k` | `"f16"` |
| `type_v` | `"f16"` |
| `no_kv_offload` | `false` |
| `no_op_offload` | `0` |
| `cpu_mask` | `"0x0"`, `"0x54B"` |
| `cpu_strict` | `false`, `true` |
| `poll` | `50` |
| `split_mode` | `"layer"` |
| `main_gpu` | `0` |
| `load_mode` | `"auto"` |
| `lazy_mode` | `"auto"` |
| `no_host` | `false` |
| `devices` | `"auto"` |
| `tensor_split` | `"0.00"` |
| `tensor_buft_overrides` | `"none"` |
| `n_cpu_moe` | `0` |
| `fit_target` | `0` |
| `fit_min_ctx` | `0` |
| `n_depth` | `0` |

## Invocation status

Commands are exactly as executed, from inside the models directory; the binary is `../llama.cpp/build-cpu/bin/llama-bench` for `cpu` rows and `../llama.cpp/build-vulkan/bin/llama-bench` for `vulkan` rows, each wrapped in `timeout 1200`. `wall s` is the whole process lifetime including model load and warmup. `throttle` is cpu0 `package_throttle_count/core_throttle_count` read before and after the invocation.

| invocation | status | wall s | throttle before → after | command |
|---|---|---:|---|---|
| 4a_smollm2-135m_cpu_t22 | OK | 92 | 6038/98 → 6073/101 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t16 | OK | 56 | 6137/113 → 6290/119 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t11 | OK | 44 | 6325/128 → 6343/134 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t6 | OK | 46 | 6374/137 → 6440/142 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t4 | OK | 47 | 6479/151 → 6566/157 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t6_pcores | OK | 40 | 6616/161 → 6691/166 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t22 | OK | 147 | 6741/172 → 6895/178 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t16 | OK | 109 | 6954/193 → 7230/196 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t11 | OK | 106 | 7282/207 → 7292/211 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t6 | OK | 124 | 7337/215 → 7380/216 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t4 | OK | 132 | 7427/221 → 7523/225 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t6_pcores | OK | 105 | 7567/235 → 7613/239 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t22 | OK | 191 | 7684/253 → 9484/257 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t16 | OK | 163 | 9537/262 → 11489/271 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t11 | OK | 164 | 11532/272 → 11568/276 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t6 | OK | 202 | 11605/290 → 11646/291 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t4 | OK | 233 | 11671/297 → 11735/307 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t6_pcores | OK | 184 | 11792/322 → 11821/336 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t22 | OK | 461 | 11876/338 → 14070/343 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t16 | OK | 386 | 14126/358 → 16468/366 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t11 | OK | 385 | 16519/375 → 16789/378 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t6 | OK | 448 | 16831/386 → 16863/392 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t4 | OK | 510 | 16892/397 → 17001/414 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t6_pcores | OK | 392 | 17048/425 → 17097/433 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_smollm2-135m_vulkan | OK | 29 | 17149/439 → 18308/455 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_qwen3-0.6b_vulkan | OK | 50 | 18390/472 → 19043/474 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_llama-3.2-1b_vulkan | OK | 53 | 19120/494 → 19866/495 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_gemma-4-e2b_vulkan | OK | 167 | 19939/508 → 20634/522 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t22 | FAILED(rc=134) | 0 | 20720/534 → 20737/543 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 22 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t11 | FAILED(rc=134) | 1 | 20760/546 → 20782/554 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 11 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_vulkan | FAILED(rc=134) | 1 | 20797/554 → 20807/554 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 11 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t11_p512 | OK | 1 | 20829/556 → 20833/557 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 11 -p 512 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_vulkan_p512 | OK | 0 | 20853/557 → 20864/557 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 11 -p 512 -n 0 -r 5 -o json -oe md` |

## Parse notes

- 4c_bge-small-en_cpu_t22: truncated JSON array repaired (run did not finish; the completed `pp48` object was kept and the array closed). After the abort, stdout also carried ggml's gdb backtrace text, which was cut off after the last complete object.
- 4c_bge-small-en_cpu_t11: truncated JSON array repaired (run did not finish; the completed `pp48` object was kept and the array closed). After the abort, stdout also carried ggml's gdb backtrace text, which was cut off after the last complete object.
- 4c_bge-small-en_vulkan: truncated JSON array repaired (run did not finish; the completed `pp48` object was kept and the array closed). After the abort, stdout also carried ggml's gdb backtrace text, which was cut off after the last complete object.
- Qwen3-0.6B-Q4_K_M.gguf `cpu t=22` `tg128` (invocation 4a_qwen3-0.6b_cpu_t22): sample 1 of 5 is invalid. Its `samples_ns` value is 18446744071171093742, which is 2^64 - 2538457874: a duration of -2.538 s stored as an unsigned 64-bit integer, so the clock llama-bench timed it with went backwards during that repetition. Its `samples_ts` value is 6.93889e-09. `llama-bench.json` keeps the object exactly as emitted, including llama-bench's own `avg_ts` 15.08222 and `stddev_ts` 9.350184, which count the invalid sample; the table above shows the mean ± sd of the other 4 samples, 18.85 ± 4.67. No other `samples_ns` value in the file is negative or wrapped.
- `llama-bench.json` holds 145 result objects from 33 invocations, concatenated in run order; no field was changed or removed, and `model_filename` is the bare file name in every object.
- Every table value is recomputed from `samples_ns` (tokens / seconds per sample, then mean and sample sd); apart from the cell marked †, it matches llama-bench's own `avg_ts` and `stddev_ts`.
- Test names: an object with `n_gen` 0 is `pp<n_prompt>`, one with `n_prompt` 0 is `tg<n_gen>`, and one with both is `pg<n_prompt>+<n_gen>` (llama-bench prints these as `pp128+tg128` and `pp512+tg128`).
