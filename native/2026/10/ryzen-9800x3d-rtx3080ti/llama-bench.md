# llama-bench results: AMD Ryzen 7 9800X3D with an NVIDIA GeForce RTX 3080 Ti

Native baseline for the LocalMode Bench methodology. llama.cpp b29c606e2 (build 10964). Every cell is mean ± sd tokens/s over 5 timed repetitions; `*` marks a cell whose sd exceeds 10% of its mean. `pg128+128` and `pg512+128` are llama-bench's `pp128+tg128` and `pp512+tg128` tests (prompt then generate; tokens/s over all tokens of the test).

Where each row comes from:

- `cpu t=16`, `cpu t=12`, `cpu t=8`, `cpu t=4`: local CPU-only build (`build-cpu`), `-ngl 0`; result objects in `llama-bench.json`.
- `cuda`: release prebuilt `llama-b10964-bin-win-cuda-12.4-x64.zip`, `-ngl 99 -t 8`, RTX 3080 Ti; result objects in `llama-bench.json`.
- `vulkan (RTX 3080 Ti)`: local Vulkan build (`build-vulkan`), `-ngl 99 -t 8`, `GGML_VK_VISIBLE_DEVICES=0` (the RTX 3080 Ti, the only Vulkan device); result objects in `llama-bench-vulkan.json`.

## SmolLM2-135M-Instruct-Q4_K_M.gguf (smollm2-135m)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 3478.02 ± 361.56 * | 3242.85 ± 262.73 | 654.00 ± 72.09 * | 1046.84 ± 58.55 | 1515.52 ± 132.04 |
| cpu t=12 | 3227.84 ± 47.43 | 3201.29 ± 23.42 | 763.45 ± 4.94 | 1117.52 ± 9.19 | 1541.32 ± 3.77 |
| cpu t=8 | 2366.36 ± 34.27 | 2333.08 ± 64.22 | 663.77 ± 13.07 | 931.76 ± 10.91 | 1217.95 ± 16.34 |
| cpu t=4 | 1579.14 ± 193.13 * | 1796.58 ± 79.46 | 517.88 ± 12.48 | 692.52 ± 25.19 | 892.79 ± 10.42 |
| cuda | 15239.84 ± 2436.76 * | 48650.71 ± 5705.77 * | 733.83 ± 5.78 | 1381.82 ± 15.47 | 3442.47 ± 76.68 |
| vulkan (RTX 3080 Ti) | 6302.60 ± 5533.69 * | 39012.48 ± 149.84 | 722.52 ± 8.11 | 1338.42 ± 10.48 | 3000.54 ± 176.78 |

## Qwen3-0.6B-Q4_K_M.gguf (qwen3-0.6b)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 2140.32 ± 28.52 | 2099.35 ± 43.23 | 136.55 ± 0.71 | 242.32 ± 0.73 | 463.34 ± 6.87 |
| cpu t=12 | 1905.57 ± 54.83 | 1809.67 ± 29.85 | 142.53 ± 1.79 | 247.74 ± 0.48 | 468.62 ± 0.63 |
| cpu t=8 | 1789.99 ± 87.95 | 1646.77 ± 71.68 | 145.45 ± 0.25 | 248.34 ± 0.78 | 440.11 ± 6.21 |
| cpu t=4 | 1120.84 ± 104.65 | 1076.67 ± 29.04 | 136.27 ± 1.12 | 220.15 ± 2.99 | 354.27 ± 2.45 |
| cuda | 13694.17 ± 1785.49 * | 30647.14 ± 1485.36 | 550.65 ± 3.20 | 1032.04 ± 23.03 | 2346.78 ± 14.67 |
| vulkan (RTX 3080 Ti) | 17784.35 ± 33.55 | 17451.29 ± 12695.13 * | 532.16 ± 20.02 | 980.78 ± 67.83 | 2257.50 ± 115.05 |

## Llama-3.2-1B-Instruct-Q4_K_M.gguf (llama-3.2-1b)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 1159.48 ± 43.52 | 1156.19 ± 22.29 | 70.51 ± 0.19 | 130.01 ± 1.22 | 266.88 ± 2.06 |
| cpu t=12 | 1065.72 ± 20.82 | 1046.99 ± 7.64 | 71.78 ± 0.09 | 129.52 ± 0.65 | 261.62 ± 4.17 |
| cpu t=8 | 936.54 ± 72.93 | 944.71 ± 31.02 | 72.52 ± 0.43 | 131.71 ± 0.53 | 257.26 ± 1.58 |
| cpu t=4 | 582.65 ± 51.06 | 587.07 ± 15.29 | 71.30 ± 0.56 | 123.95 ± 0.68 | 214.65 ± 1.08 |
| cuda | 15609.92 ± 1381.33 | 27066.44 ± 648.82 | 595.22 ± 3.01 | 1138.52 ± 2.26 | 2686.25 ± 4.24 |
| vulkan (RTX 3080 Ti) | 19296.30 ± 41.17 | 22630.22 ± 1059.26 | 561.08 ± 25.91 | 1095.00 ± 10.13 | 2531.18 ± 5.36 |

## google_gemma-4-E2B-it-Q4_K_M.gguf (gemma-4-e2b)

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=16 | 398.47 ± 6.40 | 410.93 ± 5.24 | 31.94 ± 0.14 | 58.96 ± 0.10 | 119.45 ± 0.61 |
| cpu t=12 | 380.74 ± 4.07 | 374.82 ± 6.88 | 33.08 ± 0.07 | 60.36 ± 0.13 | 119.68 ± 0.39 |
| cpu t=8 | 346.28 ± 16.03 | 352.03 ± 3.69 | 33.80 ± 0.09 | 61.05 ± 0.11 | 118.23 ± 0.61 |
| cpu t=4 | 213.59 ± 14.99 | 203.58 ± 9.15 | 33.85 ± 0.18 | 57.67 ± 0.68 | 99.42 ± 0.71 |
| cuda | 6373.67 ± 599.86 | 11534.21 ± 454.44 | 229.11 ± 0.62 | 437.27 ± 0.67 | 1045.63 ± 1.43 |
| vulkan (RTX 3080 Ti) | 5791.08 ± 1330.60 * | 10026.59 ± 263.25 | 227.50 ± 0.50 | 429.09 ± 6.34 | 977.13 ± 13.31 |

## bge-small-en-v1.5-q8_0.gguf (bge-small-en), embedding mode (`-embd 1`)

| config | pp48 | pp1536 | pp512 |
|---|---:|---:|---:|
| cpu t=16 | 7796.60 ± 170.04 | not reported (FAILED(rc=-1073740791)) | not run |
| cpu t=8 | 4753.55 ± 277.89 | not reported (FAILED(rc=-1073740791)) | 8181.25 ± 78.80 |
| cuda | 26586.45 ± 7015.20 * | not reported (FAILED(rc=-1073740791)) | 104903.99 ± 16065.96 * |
| vulkan (RTX 3080 Ti) | 23777.75 ± 1894.08 | not reported (FAILED(rc=-1073740791)) | 87502.26 ± 2157.32 |

`pp48`/`pp1536` and `pp512` come from separate invocations (`..._cpu_t8` / `..._cuda` / `..._vulkan` and the matching `..._p512` ids); see the invocation status table. The cpu and cuda rows are in `llama-bench.json`, the vulkan row in `llama-bench-vulkan.json`.

## Comparison with the 1 Oct baseline on this desktop

tokens/s, mean ± sd. The 1 Oct columns are copied from `native/2026/10/ryzen-9800x3d/` (same CPU-only and Vulkan builds, same files, same flags; Vulkan then ran on the integrated Radeon). `†` marks a `cpu t=8` cell of this run that differs from the 1 Oct mean by more than 10%.

| model | test | cpu t=8, 1 Oct | cpu t=8, this run | Vulkan on the integrated Radeon, 1 Oct | Vulkan on the RTX 3080 Ti | CUDA on the RTX 3080 Ti |
|---|---|---:|---:|---:|---:|---:|
| SmolLM2 135M | pp512 | 2351.77 ± 55.75 | 2333.08 ± 64.22 | 1200.77 ± 2.41 | 39012.48 ± 149.84 | 48650.71 ± 5705.77 * |
| SmolLM2 135M | tg128 | 655.94 ± 22.49 | 663.77 ± 13.07 | 86.01 ± 7.50 | 722.52 ± 8.11 | 733.83 ± 5.78 |
| Qwen3 0.6B | pp512 | 1857.22 ± 136.62 | 1646.77 ± 71.68 † | 368.55 ± 17.69 | 17451.29 ± 12695.13 * | 30647.14 ± 1485.36 |
| Qwen3 0.6B | tg128 | 147.72 ± 0.60 | 145.45 ± 0.25 | 53.90 ± 0.13 | 532.16 ± 20.02 | 550.65 ± 3.20 |
| Llama 3.2 1B | pp512 | 995.89 ± 83.09 | 944.71 ± 31.02 | 245.04 ± 12.11 | 22630.22 ± 1059.26 | 27066.44 ± 648.82 |
| Llama 3.2 1B | tg128 | 72.20 ± 0.04 | 72.52 ± 0.43 | 31.44 ± 0.07 | 561.08 ± 25.91 | 595.22 ± 3.01 |
| Gemma 4 E2B | pp512 | 353.13 ± 12.30 | 352.03 ± 3.69 | 97.96 ± 0.09 | 10026.59 ± 263.25 | 11534.21 ± 454.44 |
| Gemma 4 E2B | tg128 | 33.83 ± 0.06 | 33.80 ± 0.09 | 14.04 ± 0.05 | 227.50 ± 0.50 | 229.11 ± 0.62 |

Cells off the 1 Oct mean by more than 10%:

- Qwen3 0.6B pp512 cpu t=8: 1646.77 vs 1857.22 on 1 Oct (-11.3%)

## Resolved defaults

Every configuration field in the JSON with the distinct values seen across the result objects of each build (count of objects in parentheses).

### CPU-only build (local, `build-cpu`) (83 objects)

| field | values seen |
|---|---|
| `build_commit` | `b29c606e2` (83) |
| `build_number` | `10964` (83) |
| `cpu_info` | `AMD Ryzen 7 9800X3D 8-Core Processor` (83) |
| `gpu_info` | `(empty)` (83) |
| `backends` | `CPU` (83) |
| `n_batch` | `2048` (83) |
| `n_ubatch` | `512` (83) |
| `n_threads` | `16` (21), `12` (20), `8` (22), `4` (20) |
| `cpu_mask` | `0x0` (83) |
| `cpu_strict` | `false` (83) |
| `poll` | `50` (83) |
| `type_k` | `f16` (83) |
| `type_v` | `f16` (83) |
| `n_gpu_layers` | `0` (83) |
| `n_cpu_moe` | `0` (83) |
| `split_mode` | `layer` (83) |
| `main_gpu` | `0` (83) |
| `no_kv_offload` | `false` (83) |
| `flash_attn` | `-1` (83) |
| `devices` | `auto` (83) |
| `tensor_split` | `0.00` (83) |
| `tensor_buft_overrides` | `none` (83) |
| `load_mode` | `auto` (83) |
| `lazy_mode` | `auto` (83) |
| `embeddings` | `false` (80), `true` (3) |
| `no_op_offload` | `0` (83) |
| `no_host` | `false` (83) |
| `fit_target` | `0` (83) |
| `fit_min_ctx` | `0` (83) |
| `n_depth` | `0` (83) |

### CUDA build (release prebuilt, CUDA 12.4) (22 objects)

| field | values seen |
|---|---|
| `build_commit` | `b29c606e2` (22) |
| `build_number` | `10964` (22) |
| `cpu_info` | `AMD Ryzen 7 9800X3D 8-Core Processor` (22) |
| `gpu_info` | `NVIDIA GeForce RTX 3080 Ti` (22) |
| `backends` | `CUDA` (22) |
| `n_batch` | `2048` (22) |
| `n_ubatch` | `512` (22) |
| `n_threads` | `8` (22) |
| `cpu_mask` | `0x0` (22) |
| `cpu_strict` | `false` (22) |
| `poll` | `50` (22) |
| `type_k` | `f16` (22) |
| `type_v` | `f16` (22) |
| `n_gpu_layers` | `99` (22) |
| `n_cpu_moe` | `0` (22) |
| `split_mode` | `layer` (22) |
| `main_gpu` | `0` (22) |
| `no_kv_offload` | `false` (22) |
| `flash_attn` | `-1` (22) |
| `devices` | `auto` (22) |
| `tensor_split` | `0.00` (22) |
| `tensor_buft_overrides` | `none` (22) |
| `load_mode` | `auto` (22) |
| `lazy_mode` | `auto` (22) |
| `embeddings` | `false` (20), `true` (2) |
| `no_op_offload` | `0` (22) |
| `no_host` | `false` (22) |
| `fit_target` | `0` (22) |
| `fit_min_ctx` | `0` (22) |
| `n_depth` | `0` (22) |

### Vulkan build (local, `build-vulkan`), RTX 3080 Ti (22 objects)

| field | values seen |
|---|---|
| `build_commit` | `b29c606e2` (22) |
| `build_number` | `10964` (22) |
| `cpu_info` | `AMD Ryzen 7 9800X3D 8-Core Processor` (22) |
| `gpu_info` | `NVIDIA GeForce RTX 3080 Ti` (22) |
| `backends` | `Vulkan` (22) |
| `n_batch` | `2048` (22) |
| `n_ubatch` | `512` (22) |
| `n_threads` | `8` (22) |
| `cpu_mask` | `0x0` (22) |
| `cpu_strict` | `false` (22) |
| `poll` | `50` (22) |
| `type_k` | `f16` (22) |
| `type_v` | `f16` (22) |
| `n_gpu_layers` | `99` (22) |
| `n_cpu_moe` | `0` (22) |
| `split_mode` | `layer` (22) |
| `main_gpu` | `0` (22) |
| `no_kv_offload` | `false` (22) |
| `flash_attn` | `-1` (22) |
| `devices` | `auto` (22) |
| `tensor_split` | `0.00` (22) |
| `tensor_buft_overrides` | `none` (22) |
| `load_mode` | `auto` (22) |
| `lazy_mode` | `auto` (22) |
| `embeddings` | `false` (20), `true` (2) |
| `no_op_offload` | `0` (22) |
| `no_host` | `false` (22) |
| `fit_target` | `0` (22) |
| `fit_min_ctx` | `0` (22) |
| `n_depth` | `0` (22) |

## Invocation status

Run from inside the models directory; paths are relative to it.

| # | id | status | wall s | command |
|---:|---|---|---:|---|
| 1 | `4a_smollm2-135m_cpu_t16` | OK | 5.9 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 2 | `4a_smollm2-135m_cpu_t12` | OK | 5.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 3 | `4a_smollm2-135m_cpu_t8` | OK | 7.0 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4 | `4a_smollm2-135m_cpu_t4` | OK | 9.4 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 5 | `4a_qwen3-0.6b_cpu_t16` | OK | 19.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 6 | `4a_qwen3-0.6b_cpu_t12` | OK | 19.5 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 7 | `4a_qwen3-0.6b_cpu_t8` | OK | 20.0 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 8 | `4a_qwen3-0.6b_cpu_t4` | OK | 24.2 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 9 | `4a_llama-3.2-1b_cpu_t16` | OK | 35.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 10 | `4a_llama-3.2-1b_cpu_t12` | OK | 36.1 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 11 | `4a_llama-3.2-1b_cpu_t8` | OK | 36.4 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 12 | `4a_llama-3.2-1b_cpu_t4` | OK | 42.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 13 | `4a_gemma-4-e2b_cpu_t16` | OK | 81.2 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 14 | `4a_gemma-4-e2b_cpu_t12` | OK | 80.7 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 12 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 15 | `4a_gemma-4-e2b_cpu_t8` | OK | 81.4 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 16 | `4a_gemma-4-e2b_cpu_t4` | OK | 96.5 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 17 | `4b_smollm2-135m_cuda` | OK | 3.3 | `..\llama-b10964-cuda12.4\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 18 | `4b_qwen3-0.6b_cuda` | OK | 4.6 | `..\llama-b10964-cuda12.4\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 19 | `4b_llama-3.2-1b_cuda` | OK | 4.4 | `..\llama-b10964-cuda12.4\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 20 | `4b_gemma-4-e2b_cuda` | OK | 10.8 | `..\llama-b10964-cuda12.4\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 21 | `4c_smollm2-135m_vulkan` | OK | 9.0 | `GGML_VK_VISIBLE_DEVICES=0 ..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 22 | `4c_qwen3-0.6b_vulkan` | OK | 8.6 | `GGML_VK_VISIBLE_DEVICES=0 ..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 23 | `4c_llama-3.2-1b_vulkan` | OK | 5.1 | `GGML_VK_VISIBLE_DEVICES=0 ..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 24 | `4c_gemma-4-e2b_vulkan` | OK | 29.3 | `GGML_VK_VISIBLE_DEVICES=0 ..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 25 | `4d_bge-small-en_cpu_t16` | FAILED(rc=-1073740791) | 1.8 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 16 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 26 | `4d_bge-small-en_cpu_t8` | FAILED(rc=-1073740791) | 1.4 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 27 | `4d_bge-small-en_cuda` | FAILED(rc=-1073740791) | 2.0 | `..\llama-b10964-cuda12.4\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 28 | `4d_bge-small-en_vulkan` | FAILED(rc=-1073740791) | 3.1 | `GGML_VK_VISIBLE_DEVICES=0 ..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 29 | `4d_bge-small-en_cpu_t8_p512` | OK | 0.5 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 8 -p 512 -n 0 -r 5 -o json -oe md` |
| 30 | `4d_bge-small-en_cuda_p512` | OK | 0.4 | `..\llama-b10964-cuda12.4\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 512 -n 0 -r 5 -o json -oe md` |
| 31 | `4d_bge-small-en_vulkan_p512` | OK | 1.7 | `GGML_VK_VISIBLE_DEVICES=0 ..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 512 -n 0 -r 5 -o json -oe md` |

## Parse notes

- `4d_bge-small-en_cpu_t16`: the JSON array was truncated by the abort (status FAILED(rc=-1073740791)); it ended without the closing `]`. The 1 completed object(s) were kept and the array was closed when merging into `llama-bench.json`.
- `4d_bge-small-en_cpu_t8`: the JSON array was truncated by the abort (status FAILED(rc=-1073740791)); it ended without the closing `]`. The 1 completed object(s) were kept and the array was closed when merging into `llama-bench.json`.
- `4d_bge-small-en_cuda`: the JSON array was truncated by the abort (status FAILED(rc=-1073740791)); it ended without the closing `]`. The 1 completed object(s) were kept and the array was closed when merging into `llama-bench.json`.
- `4d_bge-small-en_vulkan`: the JSON array was truncated by the abort (status FAILED(rc=-1073740791)); it ended without the closing `]`. The 1 completed object(s) were kept and the array was closed when merging into `llama-bench-vulkan.json`.
- `llama-bench.json` is the concatenation, in run order, of the result objects of the CPU-only and CUDA invocations exactly as llama-bench printed them (105 objects); `llama-bench-vulkan.json` is the same for the Vulkan invocations on the RTX 3080 Ti (22 objects). No field was changed or removed.
- Test names: an object with `n_gen` 0 is `pp<n_prompt>`, one with `n_prompt` 0 is `tg<n_gen>`, and one with both is `pg<n_prompt>+<n_gen>` (llama-bench prints these as `pp128+tg128` and `pp512+tg128`).
