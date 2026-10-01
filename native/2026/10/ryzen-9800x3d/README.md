# Native baseline for the LocalMode Bench methodology: llama-bench on an AMD Ryzen 7 9800X3D

This folder is the native baseline for the LocalMode Bench methodology. Native `llama-bench` ran on the same GGUF files and workload shapes as the browser lanes, at the llama.cpp commit used for the M1 Pro baseline (`b29c606e2`, build 10964). It has two builds:

- a CPU-only build, used for a thread sweep at 16, 12, 8 and 4 threads;
- a Vulkan build that offloads every layer to the integrated Radeon.

## Files

| file | contents |
|---|---|
| `README.md` | this description: machine, method, every invocation, failures, clock witness, driver-event check, reading notes |
| `llama-bench.json` | every result object `llama-bench` emitted (105), in run order, unmodified; one JSON array |
| `llama-bench.md` | per-model tables (mean ± sd tokens/s), resolved defaults, invocation status, parse notes |
| `environment.json` | parsed machine, OS, power-plan, clock-witness, toolchain, build, Vulkan and Adrenalin facts |
| `environment.txt` | raw output of the environment, toolchain, build, `vulkaninfo`, power, smoke-test and event-log commands |
| `models.json` | the five GGUF files: URL, expected and actual bytes and SHA-256, match flags, download time |

Redactions: the computer name (the `\\<computer name>` prefix of the `Get-Counter` paths), the working-directory prefix of the build output (shortened to `<native-bench>`), the machine-generated GUID of the "Ultimate Performance" power plan, the `deviceUUID`, `driverUUID` and `deviceLUID` lines of `vulkaninfo`, and the time of day of the display driver's `DriverDate` (it is rendered in the local time zone) were removed or replaced by the placeholders shown. `environment.txt` mixed CRLF and LF line endings and is stored with LF; `llama-bench.json` keeps the CRLF line endings llama-bench wrote on Windows. No other recorded output was altered.

## Wall clock (UTC)

| event | time |
|---|---|
| session start | 2026-10-01T00:59:46Z |
| environment capture | 2026-10-01T01:00:03Z |
| measurement start | 2026-10-01T01:16:43Z |
| measurement end | 2026-10-01T01:57:56Z |
| session end | 2026-10-01T02:02:47Z |

The run instructions named the folder `2026/09`; it is filed under `native/2026/10/` because the whole session ran on 2026-10-01 UTC, and the native folders follow the UTC date of the run (the M1 Pro baseline's `native/2026/09/m1-pro/` is its UTC session date).

## Machine and software

| | |
|---|---|
| CPU | AMD Ryzen 7 9800X3D 8-Core Processor (Zen 5), 8 cores / 16 logical processors (SMT, no efficiency cores), max clock 4700 MHz, L2 8 MB, L3 96 MB |
| RAM | 100455010304 bytes (96 GB) |
| GPU | AMD Radeon(TM) Graphics, the CPU's integrated GPU (2 CUs, RDNA 2, 2 GB carve-out); no discrete GPU. Driver 32.0.21045.5002 (8/16/2026) |
| AMD Software: Adrenalin Edition | 26.8.1. Read from the installed-programs entry "AMD Software", not from the AMD Software GUI. `vulkaninfo` `driverInfo` also reads `26.8.1` |
| OS | Microsoft Windows 11 Pro 25H2, version 10.0.26200, build 26200.9457, 64-bit |
| Power plan | Balanced before. High performance (`8c5e7fda-…`) during, via `powercfg /setactive SCHEME_MIN`. Balanced restored after |
| llama.cpp | commit `b29c606e28a01b1bc8c1351026a0fa6e616bf6c4` (tags `b10964` and `v0.4.1`; `git describe --tags --always` prints `v0.4.1`), `git rev-list --count HEAD` = 10964, full-history clone. Same commit as the M1 Pro baseline |
| CPU-only build | `cmake -B build-cpu`, then `cmake --build build-cpu --config Release -j 16 --target llama-bench`. No options changed. `GGML_NATIVE=ON` resolved to `Adding CPU backend variant ggml-cpu: /arch:AVX512 GGML_AVX512` (AVX, AVX2, FMA and AVX-512 detected). OpenMP on (MSVC `-openmp`, 2.0), no BLAS. Backends: `ggml-cpu` |
| Vulkan build | `cmake -B build-vulkan -DGGML_VULKAN=ON`, same build command. Same CPU variant. Backends: `ggml-cpu;ggml-vulkan` |
| Toolchain | MSVC 19.44.35229.0 (toolset 14.44.35207) from Visual Studio Build Tools 2022 17.14.41. Generator: Visual Studio 17 2022. Windows SDK 10.0.26100.0. CMake 4.4.3, Git 2.55.0.windows.5. Both builds compiled with MSVC on the first try; the ClangCL fallback was not used |
| Vulkan SDK | 1.4.363.0 (glslc from shaderc v2026.4) |
| Vulkan device | `vulkaninfo` lists one device: AMD Radeon(TM) Graphics, `PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU`, AMD proprietary driver, apiVersion 1.4.315, driverVersion 2.0.353. llama.cpp picked it: `ggml_vulkan: 0 = AMD Radeon(TM) Graphics (AMD proprietary driver) \| uma: 1 \| fp16: 1 \| bf16: 0 \| fp4: 0 \| warp size: 32 \| shared memory: 32768 \| int dot: 1 \| matrix cores: none`. `GGML_VK_VISIBLE_DEVICES` was not set |

`llama-bench` printed `build: b29c606e2 (10964)` for both builds, and its JSON carries `build_commit` `b29c606e2` and `build_number` 10964.

## Ambient conditions

- Desktop on mains power (no battery present). The High performance plan was active for every measurement.
- **Browsers closed.** No Chrome or Edge window was open, so no `localmode.ai/bench/run` tab was running. The 36 `chrome` and 7 `msedge` background processes were stopped. `Get-Process chrome, msedge, firefox` returned nothing before and during the run.
- **Windows Update** was not downloading or installing: BITS was stopped and no update worker process was running. `wuauserv` was trigger-started by the installs.
- **Also running**, top CPU before measuring: HYTE Nexus (service and app), the Claude desktop app (which drove this session), AUEPMaster, MSI Afterburner, DCv2, Norton (NortonUI), nvcontainer, Explorer. Idle total CPU just before measuring was 7–8%.
- **Microsoft Defender** real-time protection was left on, with no exclusions (`RealTimeProtectionEnabled: True`). Its scanning of freshly downloaded and freshly built files can slow the downloads, the build and the first read of each model file. `llama-bench` loads the model and runs a warmup before it times anything, so this does not enter the measurements.
- **Keep-awake.** The `SetThreadExecutionState` snippet from the run instructions fails in Windows PowerShell 5.1. The literal `0x80000003` parses as a negative Int32: `Cannot convert argument "esFlags", with value: "-2147483645", for "SetThreadExecutionState" to type "System.UInt32"`. A helper process held `ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED` (passed as `[uint32]`) from 01:17:23Z until the orchestrator exited at 01:57:59Z. The first 40 s of the run were not covered; only `4a_smollm2-135m_cpu_t16` (8.6 s) ran in that window.

## Model files

All five files matched both the expected size (browser harness catalog) and the expected SHA-256 (M1 Pro baseline).

| bench model id | file | bytes | sha256 | match |
|---|---|---:|---|---|
| smollm2-135m | SmolLM2-135M-Instruct-Q4_K_M.gguf | 105454432 | `2e8040ceae7815abe0dcb3540b9995eaa1fa0d2ca9e797d0a635ae4433c68c2d` | bytes ✓ sha ✓ |
| qwen3-0.6b | Qwen3-0.6B-Q4_K_M.gguf | 396705472 | `ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a` | bytes ✓ sha ✓ |
| llama-3.2-1b | Llama-3.2-1B-Instruct-Q4_K_M.gguf | 807694464 | `6f85a640a97cf2bf5b8e764087b1e83da0fdb51d7c9fab7d0fece9385611df83` | bytes ✓ sha ✓ |
| gemma-4-e2b | google_gemma-4-E2B-it-Q4_K_M.gguf | 3462680032 | `923c4c86177d2ee173a7f5b4fa3d0ac65f5962ab15e6d6a5bc250aec4fd7bf7e` | bytes ✓ sha ✓ |
| bge-small-en | bge-small-en-v1.5-q8_0.gguf | 36806944 | `ec38e8da142596baa913124ae50550de284b6916bf59577ef2f0cb9660c2f514` | bytes ✓ sha ✓ |

## Method

- **Working directory and paths.** Every invocation ran from inside the models directory, with relative model paths, so `model_filename` is the bare file name. Each was started with `Start-Process -PassThru`, with stdout redirected byte for byte to `<id>.json` and stderr to `<id>.log`.
- **Output flags.** `-o json -oe md` only.
- **Timeout.** `Wait-Process -Timeout 1200`, then `Stop-Process` if still running. No invocation came near the limit; the longest took 221 s.
- **Defaults left alone.** No `-b`, `-ub`, `-fa`, `-ctk`, `-ctv`, load-mode, CPU mask or priority was passed. They resolved to `n_batch` 2048, `n_ubatch` 512, `flash_attn` -1 (auto), `type_k`/`type_v` f16, `cpu_mask` 0x0, `poll` 50, `load_mode` auto, `split_mode` layer. This matches the M1 Pro (`n_batch` 2048, `n_ubatch` 512). The browser side also runs the library defaults, which its run files do not record. The full list is under "Resolved defaults" in `llama-bench.md`.
- **Context size.** `llama-bench --help` at this commit has no `-c` / `--ctx-size` option. `-fitc` / `--fit-ctx` exists but only applies together with `--fit-target`, which is off. So nothing was added: `llama-bench` sizes each test's context to the test itself (at most 640 tokens, for `pg512+128`), and its JSON has no `n_ctx` field. The browser loads the language models with `n_ctx` 2048 and bge with 512.
- **Shapes.** Language models: `-p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5`. bge: `-embd 1 -p 48,1536 -n 0 -r 5`, plus supplementary `-p 512` runs.
- **Order.**
  - 4a: CPU-only build, `-ngl 0`, threads 16 → 12 → 8 → 4 per model, models in the order SmolLM2, Qwen3, Llama 3.2, Gemma 4.
  - 4b: Vulkan build, `-ngl 99 -t 8`, same model order.
  - 4c: bge, CPU t16, CPU t8, Vulkan, then the two `-p 512` runs.
- **Waits.** 30 s between invocations, 120 s between models and between sections. The clock witness was sampled before each model in each section.
- **Placement.** No CPU mask or priority; Windows placed the threads.
- **Smoke tests**, not included in the results: `-p 16 -n 8 -r 1` on SmolLM2 with each build. CPU at 8 threads: pp16 1678.82, tg8 422.77. Vulkan at `-ngl 99`: pp16 550.14, tg8 91.34. Full output is in `environment.txt`. The first measurement started 3.5 s after the Vulkan smoke test, with no 120 s gap.

## Invocations

Paths are relative to the models directory. Status, exit code and wall seconds come from the orchestrator.

| # | id | status | wall s | command |
|---:|---|---|---:|---|
| 1 | `4a_smollm2-135m_cpu_t16` | OK | 8.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 2 | `4a_smollm2-135m_cpu_t12` | OK | 6.0 | same with `-t 12` |
| 3 | `4a_smollm2-135m_cpu_t8` | OK | 6.9 | same with `-t 8` |
| 4 | `4a_smollm2-135m_cpu_t4` | OK | 8.8 | same with `-t 4` |
| 5 | `4a_qwen3-0.6b_cpu_t16` | OK | 19.0 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 6 | `4a_qwen3-0.6b_cpu_t12` | OK | 19.1 | same with `-t 12` |
| 7 | `4a_qwen3-0.6b_cpu_t8` | OK | 19.2 | same with `-t 8` |
| 8 | `4a_qwen3-0.6b_cpu_t4` | OK | 23.5 | same with `-t 4` |
| 9 | `4a_llama-3.2-1b_cpu_t16` | OK | 35.3 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 10 | `4a_llama-3.2-1b_cpu_t12` | OK | 35.7 | same with `-t 12` |
| 11 | `4a_llama-3.2-1b_cpu_t8` | OK | 36.5 | same with `-t 8` |
| 12 | `4a_llama-3.2-1b_cpu_t4` | OK | 41.8 | same with `-t 4` |
| 13 | `4a_gemma-4-e2b_cpu_t16` | OK | 80.6 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 14 | `4a_gemma-4-e2b_cpu_t12` | OK | 80.2 | same with `-t 12` |
| 15 | `4a_gemma-4-e2b_cpu_t8` | OK | 81.5 | same with `-t 8` |
| 16 | `4a_gemma-4-e2b_cpu_t4` | OK | 94.0 | same with `-t 4` |
| 17 | `4b_smollm2-135m_vulkan` | OK | 29.9 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -t 8 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 18 | `4b_qwen3-0.6b_vulkan` | OK | 58.7 | same with `-m Qwen3-0.6B-Q4_K_M.gguf` |
| 19 | `4b_llama-3.2-1b_vulkan` | OK | 93.6 | same with `-m Llama-3.2-1B-Instruct-Q4_K_M.gguf` |
| 20 | `4b_gemma-4-e2b_vulkan` | OK | 221.0 | same with `-m google_gemma-4-E2B-it-Q4_K_M.gguf` |
| 21 | `4c_bge-small-en_cpu_t16` | FAILED(rc=-1073740791) | 0.8 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 16 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 22 | `4c_bge-small-en_cpu_t8` | FAILED(rc=-1073740791) | 0.8 | same with `-t 8` |
| 23 | `4c_bge-small-en_vulkan` | FAILED(rc=-1073740791) | 1.5 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 24 | `4c_bge-small-en_cpu_t8_p512` | OK | 0.4 | `..\llama.cpp\build-cpu\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 8 -p 512 -n 0 -r 5 -o json -oe md` |
| 25 | `4c_bge-small-en_vulkan_p512` | OK | 1.2 | `..\llama.cpp\build-vulkan\bin\Release\llama-bench.exe -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 8 -p 512 -n 0 -r 5 -o json -oe md` |

The exact command line of every invocation is in the "Invocation status" table of `llama-bench.md`. Wall seconds include model load and warmup; the Gemma 4 E2B CPU runs spend much of their ~80 s loading the 3.46 GB file.

## Failed and skipped invocations

Nothing was skipped and nothing was killed at the limit. Three invocations failed, the three bge `-p 48,1536` runs. Each completed and wrote the `pp48` test, then aborted at `pp1536` with exit code -1073740791 (0xC0000409, the Windows code for an abort). The stderr of each ends with:

```
llama-context.cpp:1437: GGML_ASSERT(cparams.n_ubatch >= n_tokens && "encoder requires n_ubatch >= n_tokens") failed
```

The full source path before `llama-context.cpp` is shortened to the bare file name here. bge-small is an encoder and the default micro-batch is 512 tokens. This is the same assert the M1 Pro run hit at this commit. The runs were not repeated with a larger `-ub`. Their truncated JSON arrays were closed when merging, and the completed `pp48` objects were kept (see "Parse notes" in `llama-bench.md`). The supplementary `-p 512` runs stay inside the micro-batch and both completed.

## Results (tokens/s, mean ± sd over 5 repetitions; `*` = sd > 10% of mean)

| model | config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---|---:|---:|---:|---:|---:|
| SmolLM2 135M | cpu t=16 | 3411.05 ± 447.25 * | 3066.46 ± 111.05 | 396.50 ± 36.05 | 598.00 ± 36.31 | 992.19 ± 14.27 |
| | cpu t=12 | 3323.21 ± 23.01 | 3253.91 ± 18.47 | 661.26 ± 39.28 | 1014.64 ± 11.80 | 1448.05 ± 32.58 |
| | cpu t=8 | 2399.60 ± 27.55 | 2351.77 ± 55.75 | 655.94 ± 22.49 | 913.14 ± 16.82 | 1268.42 ± 35.15 |
| | cpu t=4 | 1963.14 ± 23.24 | 1877.09 ± 30.55 | 547.78 ± 6.47 | 739.76 ± 6.49 | 936.97 ± 7.41 |
| | vulkan | 1180.27 ± 4.78 | 1200.77 ± 2.41 | 86.01 ± 7.50 | 164.79 ± 0.96 | 329.95 ± 1.63 |
| Qwen3 0.6B | cpu t=16 | 2161.65 ± 66.14 | 2165.92 ± 34.89 | 140.31 ± 0.98 | 247.69 ± 1.17 | 478.95 ± 2.30 |
| | cpu t=12 | 1955.96 ± 51.81 | 1872.29 ± 13.25 | 145.58 ± 0.23 | 252.19 ± 0.51 | 474.14 ± 1.99 |
| | cpu t=8 | 1888.48 ± 125.69 | 1857.22 ± 136.62 | 147.72 ± 0.60 | 254.71 ± 1.03 | 460.95 ± 2.71 |
| | cpu t=4 | 1217.80 ± 8.00 | 1141.37 ± 10.93 | 138.90 ± 0.43 | 226.20 ± 0.77 | 363.80 ± 7.93 |
| | vulkan | 417.39 ± 2.08 | 368.55 ± 17.69 | 53.90 ± 0.13 | 93.76 ± 0.34 | 161.97 ± 0.07 |
| Llama 3.2 1B | cpu t=16 | 1184.54 ± 50.81 | 1169.34 ± 16.48 | 70.67 ± 0.17 | 130.95 ± 0.17 | 269.32 ± 0.42 |
| | cpu t=12 | 1098.74 ± 26.12 | 1068.16 ± 12.52 | 71.52 ± 0.04 | 131.78 ± 0.29 | 264.32 ± 1.20 |
| | cpu t=8 | 964.71 ± 46.34 | 995.89 ± 83.09 | 72.20 ± 0.04 | 131.79 ± 0.69 | 255.22 ± 1.01 |
| | cpu t=4 | 634.25 ± 3.33 | 613.33 ± 26.37 | 72.10 ± 0.11 | 125.16 ± 0.24 | 218.06 ± 1.17 |
| | vulkan | 248.38 ± 0.99 | 245.04 ± 12.11 | 31.44 ± 0.07 | 55.57 ± 0.14 | 102.29 ± 0.32 |
| Gemma 4 E2B | cpu t=16 | 407.20 ± 3.48 | 418.10 ± 0.59 | 32.08 ± 0.10 | 59.11 ± 0.05 | 120.46 ± 0.12 |
| | cpu t=12 | 390.64 ± 2.75 | 389.67 ± 1.54 | 33.16 ± 0.28 | 60.37 ± 0.20 | 120.44 ± 0.12 |
| | cpu t=8 | 355.71 ± 25.08 | 353.13 ± 12.30 | 33.83 ± 0.06 | 61.10 ± 0.29 | 117.33 ± 0.79 |
| | cpu t=4 | 226.86 ± 0.76 | 221.37 ± 3.45 | 33.93 ± 0.12 | 58.43 ± 0.14 | 101.60 ± 0.79 |
| | vulkan | 101.47 ± 7.87 | 97.96 ± 0.09 | 14.04 ± 0.05 | 24.39 ± 0.08 | 43.11 ± 0.14 |

| bge-small-en (`-embd 1`) | pp48 | pp1536 | pp512 |
|---|---:|---:|---:|
| cpu t=16 | 7555.66 ± 299.75 | aborted (assert) | not run |
| cpu t=8 | 4827.54 ± 61.20 | aborted (assert) | 9453.49 ± 1797.77 * |
| vulkan | 3286.04 ± 60.76 | aborted (assert) | 3452.33 ± 9.89 |

Two cells have an sd above 10% of the mean:

- SmolLM2 `cpu t=16` pp128: samples 3570.36, 3753.89, 3387.09, 3692.67, 2651.23.
- bge `cpu t=8` pp512: samples 11639.8, 11189.6, 8204.26, 8128.49, 8105.31. The first two are fast, then the rate drops by about 30% and stays there.

## Clock witness

`\Processor Information(_Total)\% Processor Performance` was sampled 3 times at 1 s before each model in each section. Above 100 means the CPU is boosting. `Processor Frequency` read 4700 (the nominal clock) in every sample.

| UTC | label | % Processor Performance |
|---|---|---|
| 01:00:06 | environment capture (Balanced) | 83.35, 85.26, 82.49 |
| 01:16:45 | 4a smollm2-135m | 108.02, 110.18, 108.98 |
| 01:20:48 | 4a qwen3-0.6b | 84.06, 84.36, 85.77 |
| 01:25:42 | 4a llama-3.2-1b | 85.87, 86.17, 85.64 |
| 01:31:44 | 4a gemma-4-e2b | 85.83, 84.34, 83.41 |
| 01:40:54 | 4b smollm2-135m | 84.03, 82.39, 83.97 |
| 01:43:27 | 4b qwen3-0.6b | 83.67, 84.94, 85.94 |
| 01:46:28 | 4b llama-3.2-1b | 83.92, 84.68, 83.36 |
| 01:50:05 | 4b gemma-4-e2b | 84.51, 84.37, 87.62 |
| 01:55:49 | 4c bge-small-en | 87.63, 89.45, 85.72 |
| 01:57:57 | final (Balanced restored) | 99.81, 85.15, 82.67 |

The first 4a sample (108–110) was taken seconds after the smoke tests, while the cores were still clocked up. Every later sample came after a 120 s idle wait and reads 82–89. Those later readings describe the idle clock between models, not the clock under load. Across them there is no downward trend that would point to heat build-up.

## Display-driver event check

`Get-WinEvent -FilterHashtable @{ LogName = 'System'; StartTime = <session start> } | Where-Object { $_.ProviderName -match 'amdkmdag|Display' }` was checked after section 4b. Result: **none**.

## Reading the numbers against the browser lanes

- **`tg128` starts from an empty context.** The browser decodes after a real prompt, so the `pg128+128` and `pg512+128` rows are the closer analogue of the browser's decode. Note that a `pg` figure is tokens/s over all prompt and generated tokens of the test.
- **Prefill.** `pp128` and `pp512` correspond to the browser's prefill of a 128- or 512-token prompt.
- **bge.** `pp48 / 48` is texts per second for one ~48-token text, the browser's single-text embedding: 157 at 16 threads, 101 at 8, 68 on Vulkan. The batch-of-32 analogue, `pp1536`, aborted at the default micro-batch.
- **Instruction sets.** The native CPU build uses this CPU's native vector instructions (AVX-512, through `GGML_NATIVE`). The browser llama.cpp CPU lane runs WebAssembly SIMD (128-bit).
- **Thread counts.** The browser's llama.cpp lanes requested 8 threads under protocol v5 (`max(2, ceil(16 / 2))`) and 16 under v4. The `cpu t=8` and `cpu t=16` rows are the respective native counterparts.
- **Units differ.** Browser decode figures are characters per second; these are tokens per second.
