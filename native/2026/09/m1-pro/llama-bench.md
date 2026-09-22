# llama-bench results: native baseline for the LocalMode Bench methodology

llama.cpp build 10964 (b29c606e2), backends `BLAS,MTL`, cpu_info `Accelerate, Apple M1 Pro`, gpu_info `Apple M1 Pro`. All values are tokens/s, mean ± sd over 5 timed repetitions (llama-bench does its own warmup). `cpu t=N` is `-ngl 0 -t N`; `metal` is `-ngl 99` (every layer offloaded). `tg128` generates from an empty context; the `pg` rows (prompt then generate) are the closer analogue of the browser decode-after-prompt measurement. Cells marked \* have sd > 10% of the mean.

## SmolLM2 135M Instruct Q4_K_M (`SmolLM2-135M-Instruct-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=10 | 365.54 ± 90.96 \* | 837.45 ± 64.71 | 178.35 ± 41.76 \* | 264.86 ± 13.43 | 369.86 ± 20.56 |
| cpu t=8 | 1276.85 ± 18.57 | 1379.79 ± 18.60 | 394.89 ± 16.39 | 496.33 ± 49.44 | 729.35 ± 11.28 |
| cpu t=6 | 1577.69 ± 20.32 | 1625.61 ± 20.11 | 378.63 ± 3.72 | 537.90 ± 3.76 | 713.10 ± 2.66 |
| cpu t=4 | 1315.81 ± 6.23 | 1152.90 ± 2.45 | 345.88 ± 2.43 | 465.13 ± 3.71 | 543.90 ± 1.75 |
| metal | 7832.89 ± 28.46 | 10834.35 ± 10.87 | 251.49 ± 2.39 | 484.57 ± 0.24 | 1132.13 ± 5.15 |

## Qwen3 0.6B Q4_K_M (`Qwen3-0.6B-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=10 | 511.58 ± 35.22 | 396.56 ± 36.38 | 119.94 ± 5.33 | 155.82 ± 12.67 | 175.33 ± 9.61 |
| cpu t=8 | 790.55 ± 2.19 | 569.69 ± 8.60 | 161.85 ± 2.79 | 227.76 ± 2.98 | 279.83 ± 5.56 |
| cpu t=6 | 510.08 ± 0.28 | 395.68 ± 1.15 | 145.07 ± 0.82 | 195.90 ± 2.03 | 224.82 ± 2.25 |
| cpu t=4 | 420.99 ± 5.60 | 319.05 ± 2.60 | 126.58 ± 0.14 | 167.22 ± 0.23 | 182.61 ± 1.02 |
| metal | 2892.23 ± 145.89 | 3240.78 ± 0.92 | 189.41 ± 0.21 | 353.02 ± 0.73 | 738.28 ± 7.32 |

## Llama 3.2 1B Instruct Q4_K_M (`Llama-3.2-1B-Instruct-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=10 | 310.82 ± 61.68 \* | 349.74 ± 4.52 | 78.88 ± 8.14 \* | 127.04 ± 7.45 | 161.32 ± 8.16 |
| cpu t=8 | 489.15 ± 1.20 | 435.69 ± 5.11 | 111.28 ± 3.24 | 167.97 ± 2.27 | 220.71 ± 1.74 |
| cpu t=6 | 348.01 ± 0.54 | 316.33 ± 0.15 | 97.07 ± 0.46 | 141.38 ± 0.54 | 180.84 ± 1.82 |
| cpu t=4 | 254.42 ± 1.59 | 229.50 ± 0.35 | 80.36 ± 1.09 | 114.09 ± 2.55 | 141.96 ± 1.97 |
| metal | 1678.21 ± 84.65 | 1791.28 ± 0.99 | 141.96 ± 0.09 | 261.02 ± 0.94 | 529.87 ± 0.21 |

## Gemma 4 E2B it Q4_K_M (`google_gemma-4-E2B-it-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=10 | 131.84 ± 4.28 | 131.56 ± 6.57 | 32.00 ± 1.60 | 48.63 ± 2.53 | 71.03 ± 1.24 |
| cpu t=8 | 199.52 ± 0.64 | 178.67 ± 3.60 | 46.09 ± 0.22 | 70.00 ± 0.61 | 93.04 ± 1.65 |
| cpu t=6 | 151.93 ± 0.25 | 135.45 ± 0.50 | 40.52 ± 0.21 | 59.29 ± 0.72 | 78.78 ± 0.51 |
| cpu t=4 | 113.30 ± 0.33 | 99.26 ± 0.05 | 34.27 ± 0.34 | 50.37 ± 0.42 | 62.72 ± 0.13 |
| metal | 773.69 ± 18.39 | 800.30 ± 0.84 | 60.46 ± 0.07 | 112.15 ± 0.09 | 231.11 ± 0.35 |

## bge-small-en-v1.5 q8_0 (`bge-small-en-v1.5-q8_0.gguf`), `-embd 1 -n 0`

| config | pp48 | pp1536 |
|---|---:|---:|
| cpu t=10 | 7090.22 ± 525.10 | failed |
| cpu t=8 | 9906.22 ± 82.21 | failed |
| metal | 8868.74 ± 701.13 | failed |

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
| `cpu_mask` | `"0x0"` |
| `cpu_strict` | `false` |
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

## Invocation status

| invocation | status | wall s | command |
|---|---|---:|---|
| 4a_smollm2-135m_cpu_t10 | OK | 24 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t8 | OK | 12 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t6 | OK | 12 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t4 | OK | 14 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t10 | OK | 44 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t8 | OK | 29 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t6 | OK | 37 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t4 | OK | 44 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t10 | OK | 53 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t8 | OK | 39 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t6 | OK | 49 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t4 | OK | 62 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t10 | OK | 129 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 10 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t8 | OK | 94 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t6 | OK | 113 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t4 | OK | 141 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_smollm2-135m_metal | OK | 9 | `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_qwen3-0.6b_metal | OK | 14 | `llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_llama-3.2-1b_metal | OK | 18 | `llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_gemma-4-e2b_metal | OK | 44 | `llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 99 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t10 | FAILED(rc=134) | 0 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 10 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t8 | FAILED(rc=134) | 0 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_metal | FAILED(rc=134) | 0 | `llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -p 48,1536 -n 0 -r 5 -o json -oe md` |

## Parse notes

- 4c_bge-small-en_cpu_t10: truncated JSON array repaired (run did not finish)
- 4c_bge-small-en_cpu_t8: truncated JSON array repaired (run did not finish)
- 4c_bge-small-en_metal: truncated JSON array repaired (run did not finish)
