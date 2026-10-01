# llama-bench results: native baseline for the LocalMode Bench methodology

llama.cpp build 10964 (b29c606e2), two local builds: CPU-only (backends `CPU`) and Vulkan (backends `Vulkan`), cpu_info `AMD Ryzen 7 9800X3D 8-Core Processor`, gpu_info `AMD Radeon(TM) Graphics` on the Vulkan rows. All values are tokens/s, mean ± sd over 5 timed repetitions (llama-bench does its own warmup). `cpu t=N` is `-ngl 0 -t N` with the CPU-only build; `vulkan` is `-ngl 99 -t 8` with the Vulkan build (every layer offloaded to the integrated Radeon). `tg128` generates from an empty context; the `pg` rows (prompt then generate) are the closer analogue of the browser decode-after-prompt measurement. Cells marked \* have sd > 10% of the mean.

## SmolLM2 135M Instruct Q4_K_M (`SmolLM2-135M-Instruct-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 3411.05 ± 447.25 \* | 3066.46 ± 111.05 | 396.50 ± 36.05 | 598.00 ± 36.31 | 992.19 ± 14.27 |
| cpu t=12 | 3323.21 ± 23.01 | 3253.91 ± 18.47 | 661.26 ± 39.28 | 1014.64 ± 11.80 | 1448.05 ± 32.58 |
| cpu t=8 | 2399.60 ± 27.55 | 2351.77 ± 55.75 | 655.94 ± 22.49 | 913.14 ± 16.82 | 1268.42 ± 35.15 |
| cpu t=4 | 1963.14 ± 23.24 | 1877.09 ± 30.55 | 547.78 ± 6.47 | 739.76 ± 6.49 | 936.97 ± 7.41 |
| vulkan | 1180.27 ± 4.78 | 1200.77 ± 2.41 | 86.01 ± 7.50 | 164.79 ± 0.96 | 329.95 ± 1.63 |

## Qwen3 0.6B Q4_K_M (`Qwen3-0.6B-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 2161.65 ± 66.14 | 2165.92 ± 34.89 | 140.31 ± 0.98 | 247.69 ± 1.17 | 478.95 ± 2.30 |
| cpu t=12 | 1955.96 ± 51.81 | 1872.29 ± 13.25 | 145.58 ± 0.23 | 252.19 ± 0.51 | 474.14 ± 1.99 |
| cpu t=8 | 1888.48 ± 125.69 | 1857.22 ± 136.62 | 147.72 ± 0.60 | 254.71 ± 1.03 | 460.95 ± 2.71 |
| cpu t=4 | 1217.80 ± 8.00 | 1141.37 ± 10.93 | 138.90 ± 0.43 | 226.20 ± 0.77 | 363.80 ± 7.93 |
| vulkan | 417.39 ± 2.08 | 368.55 ± 17.69 | 53.90 ± 0.13 | 93.76 ± 0.34 | 161.97 ± 0.07 |

## Llama 3.2 1B Instruct Q4_K_M (`Llama-3.2-1B-Instruct-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 1184.54 ± 50.81 | 1169.34 ± 16.48 | 70.67 ± 0.17 | 130.95 ± 0.17 | 269.32 ± 0.42 |
| cpu t=12 | 1098.74 ± 26.12 | 1068.16 ± 12.52 | 71.52 ± 0.04 | 131.78 ± 0.29 | 264.32 ± 1.20 |
| cpu t=8 | 964.71 ± 46.34 | 995.89 ± 83.09 | 72.20 ± 0.04 | 131.79 ± 0.69 | 255.22 ± 1.01 |
| cpu t=4 | 634.25 ± 3.33 | 613.33 ± 26.37 | 72.10 ± 0.11 | 125.16 ± 0.24 | 218.06 ± 1.17 |
| vulkan | 248.38 ± 0.99 | 245.04 ± 12.11 | 31.44 ± 0.07 | 55.57 ± 0.14 | 102.29 ± 0.32 |

## Gemma 4 E2B it Q4_K_M (`google_gemma-4-E2B-it-Q4_K_M.gguf`)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 407.20 ± 3.48 | 418.10 ± 0.59 | 32.08 ± 0.10 | 59.11 ± 0.05 | 120.46 ± 0.12 |
| cpu t=12 | 390.64 ± 2.75 | 389.67 ± 1.54 | 33.16 ± 0.28 | 60.37 ± 0.20 | 120.44 ± 0.12 |
| cpu t=8 | 355.71 ± 25.08 | 353.13 ± 12.30 | 33.83 ± 0.06 | 61.10 ± 0.29 | 117.33 ± 0.79 |
| cpu t=4 | 226.86 ± 0.76 | 221.37 ± 3.45 | 33.93 ± 0.12 | 58.43 ± 0.14 | 101.60 ± 0.79 |
| vulkan | 101.47 ± 7.87 | 97.96 ± 0.09 | 14.04 ± 0.05 | 24.39 ± 0.08 | 43.11 ± 0.14 |

## bge-small-en-v1.5 q8_0 (`bge-small-en-v1.5-q8_0.gguf`), `-embd 1 -n 0`

`pp48` and `pp1536` come from the `-p 48,1536` invocations; `pp512` from the supplementary `-p 512` invocations, which ran only at the protocol thread count and on Vulkan.

| config | pp48 | pp1536 | pp512 |
|---|---:|---:|---:|
| cpu t=16 | 7555.66 ± 299.75 | failed | not run |
| cpu t=8 | 4827.54 ± 61.20 | failed | 9453.49 ± 1797.77 \* |
| vulkan | 3286.04 ± 60.76 | failed | 3452.33 ± 9.89 |

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
| `n_depth` | `0` |

## Invocation status

Commands are exactly as executed, from inside the models directory. `wall s` is the whole process lifetime including model load and warmup.

| invocation | status | wall s | command |
|---|---|---:|---|
| 4a_smollm2-135m_cpu_t16 | OK | 8.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t12 | OK | 6.0 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t8 | OK | 6.9 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_smollm2-135m_cpu_t4 | OK | 8.8 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t16 | OK | 19.0 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t12 | OK | 19.1 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t8 | OK | 19.2 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_qwen3-0.6b_cpu_t4 | OK | 23.5 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t16 | OK | 35.3 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t12 | OK | 35.7 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t8 | OK | 36.5 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_llama-3.2-1b_cpu_t4 | OK | 41.8 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t16 | OK | 80.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t12 | OK | 80.2 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t8 | OK | 81.5 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4a_gemma-4-e2b_cpu_t4 | OK | 94.0 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_smollm2-135m_vulkan | OK | 29.9 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_qwen3-0.6b_vulkan | OK | 58.7 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_llama-3.2-1b_vulkan | OK | 93.6 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4b_gemma-4-e2b_vulkan | OK | 221.0 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t16 | FAILED(rc=-1073740791) | 0.8 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 16 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t8 | FAILED(rc=-1073740791) | 0.8 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_vulkan | FAILED(rc=-1073740791) | 1.5 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_cpu_t8_p512 | OK | 0.4 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 8 -p 512 -n 0 -r 5 -o json -oe md` |
| 4c_bge-small-en_vulkan_p512 | OK | 1.2 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 512 -n 0 -r 5 -o json -oe md` |

## Parse notes

- 4c_bge-small-en_cpu_t16: truncated JSON array repaired (run did not finish; the completed `pp48` object was kept and the array closed).
- 4c_bge-small-en_cpu_t8: truncated JSON array repaired (run did not finish; the completed `pp48` object was kept and the array closed).
- 4c_bge-small-en_vulkan: truncated JSON array repaired (run did not finish; the completed `pp48` object was kept and the array closed).
- `llama-bench.json` holds 105 result objects from 25 invocations, concatenated in run order; no field was changed or removed, and `model_filename` is the bare file name in every object.
- Every table value is recomputed from `samples_ns` (tokens / seconds per sample, then mean and sample sd) and matches llama-bench's own `avg_ts` and `stddev_ts`.
- Test names: an object with `n_gen` 0 is `pp<n_prompt>`, one with `n_prompt` 0 is `tg<n_gen>`, and one with both is `pg<n_prompt>+<n_gen>` (llama-bench prints these as `pp128+tg128` and `pp512+tg128`).
