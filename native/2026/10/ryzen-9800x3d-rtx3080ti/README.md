# Native baseline for the LocalMode Bench methodology: llama-bench on an AMD Ryzen 7 9800X3D with an NVIDIA GeForce RTX 3080 Ti

This folder is the native baseline for the LocalMode Bench methodology on the 9800X3D desktop, now fitted with an NVIDIA GeForce RTX 3080 Ti 12 GB (Ampere GA102, compute capability 8.6). The card ran NVIDIA driver 617.42, which supports CUDA 13.4. Native `llama-bench` ran on the same five GGUF files and workload shapes as the browser lanes, at llama.cpp `b29c606e2` (build 10964), the build of every native folder in the dataset. It used three builds:

- the local CPU-only build of the 1 Oct baseline, for a thread sweep at 16, 12, 8 and 4 threads;
- the release prebuilt `llama-b10964-bin-win-cuda-12.4-x64.zip` (CUDA 12.4 package), with every layer on the RTX 3080 Ti (`-ngl 99`);
- the local Vulkan build of the 1 Oct baseline, with every layer on the RTX 3080 Ti. This is a comparison row: the 1 Oct Vulkan row ran the same command on the integrated Radeon.

The integrated Radeon was disabled in the BIOS (not enumerated).

## Files

| file | contents |
|---|---|
| `README.md` | this description: machine, method, every invocation, failures, clock logs, driver-event check, comparison, reading notes |
| `llama-bench.json` | every result object of the CPU-only and CUDA invocations (105), in run order, unmodified; one JSON array |
| `llama-bench-vulkan.json` | every result object of the Vulkan invocations on the RTX 3080 Ti (22), in run order, unmodified; one JSON array |
| `llama-bench.md` | per-model tables (mean ± sd tokens/s), the comparison with 1 Oct, resolved defaults per build, invocation status, parse notes |
| `environment.json` | parsed machine, GPU, OS, power-plan, clock-witness, GPU-witness, toolchain, build, CUDA-package and Vulkan facts |
| `environment.txt` | raw output of the environment, build-verification, package-hash, `vulkaninfo`, `--help`, power, smoke-test, clock-log, event-log and GPU-logger commands |
| `models.json` | the five GGUF files: URL, expected and actual bytes and SHA-256, match flags, reuse |

## Redactions

- User-profile paths are shortened to `<home>`, or to the bare file name. This covers the DLL paths in the CUDA build's `load_backend:` lines and the source path in the assert messages.
- The PCI bus id in plain `nvidia-smi` output is replaced by `<pci-bus-id>`.
- `nvidia-smi` process paths are reduced to the executable name.
- The GUID of the machine-generated "Ultimate Performance" power plan is written as `<generated>`. The Balanced, High performance and Power saver GUIDs are the Windows built-in ones.
- `UUID`, `Serial`, `Board ID` and `LUID` lines are dropped, including vulkaninfo's `deviceUUID` and `driverUUID`.

None of these commands were run: `systeminfo`, `nvidia-smi -L`, a bare `nvidia-smi -q`, or a query of `uuid`, `serial` or `pci.bus_id`.

## Wall clock (UTC)

| event | time |
|---|---|
| session start | 2026-10-14T04:57:21Z |
| environment capture | 2026-10-14T04:59:05Z |
| measurement start | 2026-10-14T10:06:52Z |
| measurement end | 2026-10-14T10:52:02Z |
| session end | 2026-10-14T11:01:16Z |

The session waited about five hours between environment capture and measurement. RivaTuner Statistics Server (Afterburner's on-screen display server) was running elevated and could not be stopped from this session ("Access is denied"). The operator closed it from an elevated prompt. The process state was recorded again just before measuring (in `environment.txt`), and the CPU and GPU witnesses were sampled before each model.

## Machine and software

| | |
|---|---|
| CPU | AMD Ryzen 7 9800X3D 8-Core Processor (Zen 5), 8 cores / 16 logical processors (SMT, no efficiency cores), max clock 4700 MHz, L2 8 MB, L3 96 MB |
| RAM | 102602493952 bytes (96 GB). That is exactly 2 GiB more than the 1 Oct reading, when the integrated Radeon's 2 GB carve-out was reserved |
| GPU | NVIDIA GeForce RTX 3080 Ti, 12288 MiB, discrete. PCI device id 0x220810DE, VBIOS 94.02.71.80.74 |
| NVIDIA driver | 617.42 (Windows driver 32.0.16.1742). The `nvidia-smi` header prints `CUDA UMD Version: 13.4`, the highest CUDA version this driver supports; this driver no longer prints `CUDA Version` in the header |
| GPU power and clocks | power limit 400 W (enforced = default; min 100, max 450). Max clocks: graphics 2100 MHz, memory 9501 MHz. Target temperature 83 °C, slowdown 95 °C |
| PCIe link | read at idle (P8): Gen 1 of max Gen 4, width **x8 of max x16**. Not logged under load |
| Integrated Radeon | disabled in BIOS (not enumerated). `Win32_VideoController` lists only the RTX 3080 Ti. `Get-PnpDevice -Class Display` keeps a non-present `AMD Radeon(TM) Graphics` entry (Status Unknown, Present False). `vulkaninfo` lists one device |
| OS | Microsoft Windows 11 Pro 25H2, version 10.0.26200, build 26200.9711, 64-bit |
| Power plan | Balanced before. High performance (`8c5e7fda-…`) during, via `powercfg /setactive SCHEME_MIN`. Balanced restored after |
| HAGS | `HwSchMode` value absent (Windows default) |
| MSI Afterburner | 4.6.5 installed, not running. Its profile for this card has an empty `[Startup]` section: no power, clock, curve or fan override. RTSS 7.3.4 was closed before measuring (see above) |
| NVIDIA Control Panel power management mode | not read |
| llama.cpp | commit `b29c606e28a01b1bc8c1351026a0fa6e616bf6c4` (release `b10964`), `git rev-list --count HEAD` = 10964, `git status --short` empty |
| CPU-only build | reused from 1 Oct, not rebuilt (`llama-bench.exe` written 2026-10-01T01:13:46Z). `cmake -B build-cpu`, then `cmake --build build-cpu --config Release -j 16 --target llama-bench`, no options. `GGML_NATIVE=ON` resolved to `Adding CPU backend variant ggml-cpu: /arch:AVX512 GGML_AVX512` (1 Oct configure log). MSVC 19.44.35229.0, Visual Studio 17 2022 generator |
| CUDA build | release prebuilt. `llama-b10964-bin-win-cuda-12.4-x64.zip` (254067651 bytes, sha256 `264f20d7ee3860aecca9ec12418357a9f3e80349a2b186f66c63859ded1a9593`) and `cudart-llama-bin-win-cuda-12.4-x64.zip` (391443627 bytes, sha256 `8c79a9b226de4b3cacfd1f83d24f962d0773be79f1e7b75c6af4ded7e32ae1d6`). Both match the GitHub release digests and were expanded into one folder. The CPU variant it loaded is `ggml-cpu-zen4.dll`; the release has no Zen 5 variant. The local-build fallback was not used |
| CUDA device line | `Device 0: NVIDIA GeForce RTX 3080 Ti, compute capability 8.6, VMM: yes, VRAM: 12287 MiB` (after `ggml_cuda_init: found 1 CUDA devices (Total VRAM: 12287 MiB):`) |
| Vulkan build | reused from 1 Oct, not rebuilt (`llama-bench.exe` written 2026-10-01T01:15:54Z). `cmake -B build-vulkan -DGGML_VULKAN=ON`, same build command, Vulkan SDK 1.4.363.0 |
| Vulkan device | `vulkaninfo` lists one device: NVIDIA GeForce RTX 3080 Ti, `PHYSICAL_DEVICE_TYPE_DISCRETE_GPU`, driverName NVIDIA, driverInfo 617.42, apiVersion 1.4.351, driverVersion 617.42.0.0. llama.cpp picked it: `ggml_vulkan: 0 = NVIDIA GeForce RTX 3080 Ti (NVIDIA) \| uma: 0 \| fp16: 1 \| bf16: 1 \| fp4: 0 \| warp size: 32 \| shared memory: 49152 \| int dot: 1 \| matrix cores: NV_coopmat2v` (verbatim). `GGML_VK_VISIBLE_DEVICES=0` was set for the Vulkan invocations only; Vulkan lists only this card, so it was set anyway |

All three builds printed `build: b29c606e2 (10964)`, and their JSON carries `build_commit` `b29c606e2` and `build_number` 10964. JSON `backends` / `gpu_info`:

- CPU-only build: `CPU` / empty;
- CUDA build: `CUDA` / `NVIDIA GeForce RTX 3080 Ti`;
- Vulkan build: `Vulkan` / `NVIDIA GeForce RTX 3080 Ti`.

## Ambient conditions

- **Power.** Desktop on mains power (no battery present). The High performance plan was active for every measurement.
- **Browsers closed.** No Chrome or Edge window was open, so no `localmode.ai/bench/run` tab was running. The 18 `chrome` and 5 `msedge` background processes were stopped. `Get-Process chrome, msedge, firefox` returned nothing at environment capture and at measurement launch.
- **GPU tools and overlays.**
  - MSI Afterburner was not running.
  - RTSS was closed before measuring. Its Vulkan implicit layer (`VK_LAYER_RTSS`) stays registered, and `vulkaninfo` still lists it. The llama-bench Vulkan logs print no layer message.
  - The NVIDIA App's `NVIDIA Overlay` processes were stopped once but are restarted by `nvcontainer` within seconds. They were running, with no game and no overlay shown.
- **Windows Update** was not installing: no update worker process was running, and BITS was stopped. The last update event was a Defender intelligence download at 04:49Z.
- **Also running**, top CPU at launch:
  - HYTE Nexus (case control software, service and app), at about 0.1 core on average since boot;
  - the Claude desktop app (which drove this session);
  - DCv2, OneDrive, Explorer, AUEPMaster, nvsphelper64, nvcontainer, Norton (NortonUI).

  Between invocations the GPU reported 1–21 % utilization at P8. That comes from desktop composition and the processes `nvidia-smi` lists on the GPU.
- **Microsoft Defender** real-time protection was left on, with no exclusions (`RealTimeProtectionEnabled: True`). Its scanning of freshly downloaded files can slow the downloads and the first read of each file. `llama-bench` loads the model and runs a warmup before it times anything, so this does not enter the measurements.
- **Keep-awake.** `SetThreadExecutionState([uint32]2147483651)` (ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED) was called in the orchestrator thread at 10:04:48Z, before the smoke tests; it returned 2147483648, which means success. `SetThreadExecutionState([uint32]2147483648)` was called at 10:52:02Z. The whole measurement window was covered.

## Model files

All five files were already present from the 1 Oct session and were reused (`download_attempts: 0`). Each matched both the expected size (browser harness catalog) and the expected SHA-256 (published native folders).

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
- **Timeout.** `Wait-Process -Timeout 1200`, then `Stop-Process` if still running. No invocation came near the limit; the longest took 96.5 s.
- **Defaults left alone.** No `-b`, `-ub`, `-fa`, `-ctk`, `-ctv`, `-mmp`, `-sm`, `-mg`, CPU mask or priority was passed. All three builds resolved them identically:
  - `n_batch` 2048, `n_ubatch` 512;
  - `flash_attn` -1 (auto), which lets the backend decide per device; on CUDA, auto normally enables flash attention;
  - `type_k`/`type_v` f16;
  - `cpu_mask` 0x0, `poll` 50;
  - `split_mode` layer, `main_gpu` 0, `devices` auto, `load_mode` auto.

  These are the same values as on 1 Oct. The browser side also runs the library defaults, which its run files do not record. The per-build list is under "Resolved defaults" in `llama-bench.md`.
- **Context size.** `llama-bench --help` at this build has no `-c` / `--ctx-size` option in any of the three binaries (`-C` is `--cpu-mask`). `-fitc` / `--fit-ctx` applies only with `--fit-target`, which is off. So nothing was added: `llama-bench` sizes each test's context to the test itself (at most 640 tokens here), and its JSON has no `n_ctx` field.
- **Shapes.** Language models: `-p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5`. bge: `-embd 1 -p 48,1536 -n 0 -r 5`, plus supplementary `-p 512` runs.
- **Order.** Models in the order SmolLM2, Qwen3, Llama 3.2, Gemma 4.
  - 4a: CPU-only build, `-ngl 0`, threads 16 → 12 → 8 → 4 per model.
  - 4b: CUDA build, `-ngl 99 -t 8`.
  - 4c: Vulkan build on the RTX 3080 Ti, `-ngl 99 -t 8`.
  - 4d: bge, in the order CPU t16, CPU t8, CUDA, Vulkan, then the `-p 512` runs on CPU t8, CUDA and Vulkan.
- **Waits.** 30 s between invocations, 120 s between models and between sections, and 120 s after the smoke tests.
- **Witnesses.** The CPU clock witness was sampled before each model in each section. The GPU witness was sampled before each model of 4b, 4c and 4d.
- **GPU logger.** The background GPU logger ran during 4b and 4c only, not during the CPU sweep. It ran the brief's `nvidia-smi --query-gpu=…,clocks_event_reasons.active --format=csv` query once per second, from a PowerShell loop. nvidia-smi's own `-lms 1000 -f <file>` logger buffers its output: in a test on this machine it had written 0 bytes after 8 s and lost everything when stopped with `Stop-Process`. This driver accepted `clocks_event_reasons.active`.
- **`GGML_VK_VISIBLE_DEVICES`** was set to `0` only around each Vulkan invocation and removed afterwards. It was not set for any CPU or CUDA invocation.
- **Smoke tests**, not included in the results: `-p 16 -n 8 -r 1` on SmolLM2 with each build, using the brief's commands (default markdown output). The `backends` and `gpu_info` JSON fields above therefore come from the measurement JSON.
  - CPU at 8 threads: pp16 2142.70, tg8 670.33.
  - CUDA at `-ngl 99`: pp16 2331.68, tg8 620.54.
  - Vulkan at `-ngl 99`: pp16 5124.59, tg8 672.36.

  Full output is in `environment.txt`.

## Invocations

Paths are relative to the models directory. Status, exit code and wall seconds come from the orchestrator. Wall seconds include model load and warmup.

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

## Failed and skipped invocations

Nothing was skipped, nothing was killed at the limit, and every language-model invocation completed on every build. Four invocations failed: the four bge `-p 48,1536` runs (CPU t16, CPU t8, CUDA, Vulkan). Each completed and wrote the `pp48` test, then aborted at `pp1536` with exit code -1073740791 (0xC0000409). The stderr of each ends with:

```
llama-context.cpp:1437: GGML_ASSERT(cparams.n_ubatch >= n_tokens && "encoder requires n_ubatch >= n_tokens") failed
```

The source path before `llama-context.cpp` is shortened here. The local builds print the clone's path; the CUDA prebuilt prints the release CI path `D:/a/llama.cpp/llama.cpp/src/`. This is the same assert as on 1 Oct and on the M1 Pro. The runs were not repeated with a larger `-ub`. Their truncated JSON arrays were closed when merging, and the completed `pp48` objects were kept (see "Parse notes" in `llama-bench.md`). The supplementary `-p 512` runs stay inside the micro-batch, and all three completed.

## Results (tokens/s, mean ± sd over 5 repetitions; `*` = sd > 10% of mean)

| model | config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---|---:|---:|---:|---:|---:|
| SmolLM2 135M | cpu t=16 | 3478.02 ± 361.56 * | 3242.85 ± 262.73 | 654.00 ± 72.09 * | 1046.84 ± 58.55 | 1515.52 ± 132.04 |
|  | cpu t=12 | 3227.84 ± 47.43 | 3201.29 ± 23.42 | 763.45 ± 4.94 | 1117.52 ± 9.19 | 1541.32 ± 3.77 |
|  | cpu t=8 | 2366.36 ± 34.27 | 2333.08 ± 64.22 | 663.77 ± 13.07 | 931.76 ± 10.91 | 1217.95 ± 16.34 |
|  | cpu t=4 | 1579.14 ± 193.13 * | 1796.58 ± 79.46 | 517.88 ± 12.48 | 692.52 ± 25.19 | 892.79 ± 10.42 |
|  | cuda | 15239.84 ± 2436.76 * | 48650.71 ± 5705.77 * | 733.83 ± 5.78 | 1381.82 ± 15.47 | 3442.47 ± 76.68 |
|  | vulkan (RTX 3080 Ti) | 6302.60 ± 5533.69 * | 39012.48 ± 149.84 | 722.52 ± 8.11 | 1338.42 ± 10.48 | 3000.54 ± 176.78 |
| Qwen3 0.6B | cpu t=16 | 2140.32 ± 28.52 | 2099.35 ± 43.23 | 136.55 ± 0.71 | 242.32 ± 0.73 | 463.34 ± 6.87 |
|  | cpu t=12 | 1905.57 ± 54.83 | 1809.67 ± 29.85 | 142.53 ± 1.79 | 247.74 ± 0.48 | 468.62 ± 0.63 |
|  | cpu t=8 | 1789.99 ± 87.95 | 1646.77 ± 71.68 | 145.45 ± 0.25 | 248.34 ± 0.78 | 440.11 ± 6.21 |
|  | cpu t=4 | 1120.84 ± 104.65 | 1076.67 ± 29.04 | 136.27 ± 1.12 | 220.15 ± 2.99 | 354.27 ± 2.45 |
|  | cuda | 13694.17 ± 1785.49 * | 30647.14 ± 1485.36 | 550.65 ± 3.20 | 1032.04 ± 23.03 | 2346.78 ± 14.67 |
|  | vulkan (RTX 3080 Ti) | 17784.35 ± 33.55 | 17451.29 ± 12695.13 * | 532.16 ± 20.02 | 980.78 ± 67.83 | 2257.50 ± 115.05 |
| Llama 3.2 1B | cpu t=16 | 1159.48 ± 43.52 | 1156.19 ± 22.29 | 70.51 ± 0.19 | 130.01 ± 1.22 | 266.88 ± 2.06 |
|  | cpu t=12 | 1065.72 ± 20.82 | 1046.99 ± 7.64 | 71.78 ± 0.09 | 129.52 ± 0.65 | 261.62 ± 4.17 |
|  | cpu t=8 | 936.54 ± 72.93 | 944.71 ± 31.02 | 72.52 ± 0.43 | 131.71 ± 0.53 | 257.26 ± 1.58 |
|  | cpu t=4 | 582.65 ± 51.06 | 587.07 ± 15.29 | 71.30 ± 0.56 | 123.95 ± 0.68 | 214.65 ± 1.08 |
|  | cuda | 15609.92 ± 1381.33 | 27066.44 ± 648.82 | 595.22 ± 3.01 | 1138.52 ± 2.26 | 2686.25 ± 4.24 |
|  | vulkan (RTX 3080 Ti) | 19296.30 ± 41.17 | 22630.22 ± 1059.26 | 561.08 ± 25.91 | 1095.00 ± 10.13 | 2531.18 ± 5.36 |
| Gemma 4 E2B | cpu t=16 | 398.47 ± 6.40 | 410.93 ± 5.24 | 31.94 ± 0.14 | 58.96 ± 0.10 | 119.45 ± 0.61 |
|  | cpu t=12 | 380.74 ± 4.07 | 374.82 ± 6.88 | 33.08 ± 0.07 | 60.36 ± 0.13 | 119.68 ± 0.39 |
|  | cpu t=8 | 346.28 ± 16.03 | 352.03 ± 3.69 | 33.80 ± 0.09 | 61.05 ± 0.11 | 118.23 ± 0.61 |
|  | cpu t=4 | 213.59 ± 14.99 | 203.58 ± 9.15 | 33.85 ± 0.18 | 57.67 ± 0.68 | 99.42 ± 0.71 |
|  | cuda | 6373.67 ± 599.86 | 11534.21 ± 454.44 | 229.11 ± 0.62 | 437.27 ± 0.67 | 1045.63 ± 1.43 |
|  | vulkan (RTX 3080 Ti) | 5791.08 ± 1330.60 * | 10026.59 ± 263.25 | 227.50 ± 0.50 | 429.09 ± 6.34 | 977.13 ± 13.31 |

| bge-small-en (`-embd 1`) | pp48 | pp1536 | pp512 |
|---|---:|---:|---:|
| cpu t=16 | 7796.60 ± 170.04 | aborted (assert) | not run |
| cpu t=8 | 4753.55 ± 277.89 | aborted (assert) | 8181.25 ± 78.80 |
| cuda | 26586.45 ± 7015.20 * | aborted (assert) | 104903.99 ± 16065.96 * |
| vulkan (RTX 3080 Ti) | 23777.75 ± 1894.08 | aborted (assert) | 87502.26 ± 2157.32 |

Cells with an sd above 10% of the mean:

- SmolLM2 135M `cpu t=16` pp128: samples 3680.07, 3747.61, 3527.82, 2849.22, 3585.36.
- SmolLM2 135M `cpu t=16` tg128: samples 685.33, 542.02, 680.92, 731.36, 630.36.
- SmolLM2 135M `cpu t=4` pp128: samples 1301.52, 1625.00, 1711.45, 1474.63, 1783.09.
- SmolLM2 135M `cuda` pp128: samples 11406.30, 16127.00, 14623.20, 17898.80, 16143.90.
- SmolLM2 135M `cuda` pp512: samples 38885.40, 50908.80, 50018.60, 53847.10, 49593.70.
- Qwen3 0.6B `cuda` pp128: samples 10500.50, 14496.40, 14524.80, 14455.30, 14493.90.
- bge-small-en `cuda` pp48: samples 14049.10, 29261.20, 29830.30, 29690.10, 30101.60.
- bge-small-en `cuda` pp512: samples 76306.30, 109824.00, 111876.00, 112190.00, 114324.00.
- SmolLM2 135M `vulkan (RTX 3080 Ti)` pp128: samples 1898.10, 1896.95, 3032.42, 12252.70, 12432.90.
- Qwen3 0.6B `vulkan (RTX 3080 Ti)` pp512: samples 7196.65, 7209.75, 10270.70, 31121.60, 31457.70.
- Gemma 4 E2B `vulkan (RTX 3080 Ti)` pp128: samples 3410.90, 6385.12, 6370.38, 6401.82, 6387.16.

On both GPU backends, every starred cell has the same shape: the first one to three repetitions are slow and the rest fast. Each GPU model started from idle (P8, 210 MHz in every GPU witness sample) after a 120 s wait. The 1 s GPU logger shows the card leaving P8 for P2 (CUDA) or P0 (Vulkan) when each invocation starts, passing through P5/P3 in some ramps. The CPU starred cells (SmolLM2 at 16 and 4 threads) do not follow that pattern: their low samples fall at different repetitions.

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

Seven of the eight `cpu t=8` cells are within 10% of 1 Oct. Llama 3.2 `pp512` is −5.1%; the others are within ±2%. The CPU rows therefore reproduce the 1 Oct rows with the new card installed, with one exception. Qwen3 0.6B `pp512` at 8 threads came out 11.3% lower: 1646.77 ± 71.68 against 1857.22 ± 136.62. Its sd was 7% on 1 Oct and 4% here; it was not re-run. On the same model, `tg128` at 8 threads is within 2% of 1 Oct.

GPU backend comparison, RTX 3080 Ti (ratio of means):

| model | pp512 CUDA / Vulkan | tg128 CUDA / Vulkan | pp512 CUDA / cpu t=8 | tg128 CUDA / cpu t=8 |
|---|---:|---:|---:|---:|
| SmolLM2 135M | 1.25 | 1.02 | 20.9 | 1.11 |
| Qwen3 0.6B | 1.76 | 1.03 | 18.6 | 3.79 |
| Llama 3.2 1B | 1.20 | 1.06 | 28.7 | 8.21 |
| Gemma 4 E2B | 1.15 | 1.01 | 32.8 | 6.78 |

The Qwen3 `pp512` Vulkan mean is 17451.29 ± 12695.13: three slow samples (7196.65, 7209.75, 10270.70) and two fast ones (31121.60, 31457.70). Its ratio mixes the two.

## Clock logs

**CPU.** `\Processor Information(_Total)\% Processor Performance` was sampled 3 times at 1 s before each model in each section. Above 100 means the CPU is boosting. `Processor Frequency` read 4700 (the nominal clock) in every sample.

| UTC | label | % Processor Performance |
|---|---|---|
| 04:59:08 | environment capture (Balanced) | 84.98, 84.07, 84.11 |
| 10:06:52 | 4a smollm2-135m | 95.19, 95.62, 88.27 |
| 10:10:53 | 4a qwen3-0.6b | 87.69, 89.42, 87.10 |
| 10:15:50 | 4a llama-3.2-1b | 86.83, 86.47, 92.40 |
| 10:21:53 | 4a gemma-4-e2b | 88.39, 93.11, 95.33 |
| 10:31:06 | 4b smollm2-135m | 106.54, 101.65, 95.31 |
| 10:33:12 | 4b qwen3-0.6b | 95.47, 93.43, 96.19 |
| 10:35:20 | 4b llama-3.2-1b | 96.23, 93.75, 95.88 |
| 10:37:28 | 4b gemma-4-e2b | 92.68, 100.35, 94.19 |
| 10:39:43 | 4c smollm2-135m | 106.45, 99.32, 99.06 |
| 10:41:55 | 4c qwen3-0.6b | 94.51, 94.28, 93.68 |
| 10:44:06 | 4c llama-3.2-1b | 97.46, 98.63, 97.00 |
| 10:46:14 | 4c gemma-4-e2b | 95.53, 96.28, 93.47 |
| 10:48:47 | 4d bge-small-en | 92.54, 90.43, 91.17 |
| 10:52:02 | final (Balanced restored) | 106.13, 92.61, 86.74 |

Every sample was taken after a wait, so it describes the clock between models, not under load. There is no drop between models.

**GPU witness** (before each model of 4b, 4c, 4d). Every sample read P8, 210 MHz graphics, 405 MHz memory, 23.5–25.3 W, enforced limit 400 W, 44–49 °C, fan 0 %. The final sample, after the run, read P5, 240 MHz, 810 MHz, 26.67 W, 49 °C.

**GPU logger** (1 s samples, timestamps converted to UTC; raw rows in `environment.txt`):

| invocation | samples | P-states | graphics MHz | power W | temp °C | util max % | mem used max MiB | event reasons |
|---|---:|---|---|---|---|---:|---:|---|
| `4b_smollm2-135m_cuda` | 3 | P2 | 1920–1920 | 73.82–177.21 | 50–52 | 93 | 1653 | `0x400` |
| `4b_qwen3-0.6b_cuda` | 5 | P2 | 1800–1935 | 33.84–265.38 | 47–57 | 95 | 2186 | `0x000`, `0x400` |
| `4b_llama-3.2-1b_cuda` | 5 | P2, P8 | 210–1920 | 24.31–384.23 | 47–64 | 94 | 2437 | `0x000`, `0x001`, `0x400`, `0x404` |
| `4b_gemma-4-e2b_cuda` | 11 | P2, P8 | 210–1935 | 24.75–315.58 | 48–64 | 97 | 3423 | `0x001`, `0x400` |
| `4c_smollm2-135m_vulkan` | 9 | P0, P3, P5 | 210–1935 | 31.15–186.5 | 49–57 | 92 | 1364 | `0x001`, `0x400` |
| `4c_qwen3-0.6b_vulkan` | 8 | P0, P5 | 870–1935 | 28.52–259.64 | 50–60 | 95 | 1909 | `0x001`, `0x400` |
| `4c_llama-3.2-1b_vulkan` | 5 | P0 | 1800–1935 | 25.05–370.56 | 49–65 | 94 | 2200 | `0x001`, `0x400`, `0x600` |
| `4c_gemma-4-e2b_vulkan` | 29 | P0, P3, P5, P8 | 210–1950 | 24.8–318.72 | 48–66 | 98 | 3303 | `0x001`, `0x600` |

- Section 4b (CUDA), 10:31:07–10:37:42Z, 392 rows. Under load the card ran at P2 (P0/P3/P5 appear only during ramps) and 1800–1935 MHz, up to 384.23 W and 64 °C. The fan stayed at 0 %.
- Section 4c (Vulkan), 10:39:43–10:46:46Z, 420 rows. P0 under load, 1800–1950 MHz, up to 370.56 W and 66 °C, fan up to 55 %.
- Event reasons other than idle:
  - `0x400` (4b: 25 rows; 4c: 16 rows) and `0x600` (4c: 13 rows) under load. `nvidia-smi --help-query-gpu` does not give the bit values for the `0x200` and `0x400` bits, so they are recorded verbatim and not decoded.
  - One sample of `0x404` during `4b_llama-3.2-1b_cuda` at 384.23 W. Bit `0x4` is the SW power cap.
  - No HW slowdown, HW thermal, power-brake or SW thermal reason appeared in any sample.
- The logger samples once per second, and the CUDA runs last 3–11 s. These are coarse windows; they do not trace each repetition.

## Display-driver event check

`Get-WinEvent -FilterHashtable @{ LogName = 'System'; StartTime = <session start> } | Where-Object { $_.ProviderName -match 'nvlddmkm|Display|amdkmdag' }` was checked after section 4c, at 10:46:47Z. Result: **none**.

## Reading the numbers against the browser lanes

- **`tg128` starts from an empty context.** The browser decodes after a real prompt, so the `pg128+128` and `pg512+128` rows are the closer analogue of the browser's decode. A `pg` figure is tokens/s over all prompt and generated tokens of the test.
- **Prefill.** `pp128` and `pp512` correspond to the browser's prefill of a 128- or 512-token prompt.
- **bge.** `pp48 / 48` is texts per second for one ~48-token text, the browser's single-text embedding:
  - cpu t=16: 162.4 texts/s
  - cpu t=8: 99.0 texts/s
  - cuda: 553.9 texts/s
  - vulkan (RTX 3080 Ti): 495.4 texts/s

  The batch-of-32 analogue, `pp1536`, aborted at the default micro-batch on every build.
- **Instruction sets.** The native CPU build uses AVX-512 (`GGML_NATIVE`, `/arch:AVX512`). The browser llama.cpp CPU lane runs WebAssembly SIMD (128-bit).
- **Thread counts.** The browser's llama.cpp lanes requested 8 threads under protocol v5 (`max(2, ceil(16 / 2))`) and 16 under v4. The `cpu t=8` and `cpu t=16` rows are the respective native counterparts. The CUDA and Vulkan rows use `-t 8`, matching the 8 threads the `wllama-webgpu` lane requests for its CPU-side work under v5.
- **API path.** The browser's WebGPU path on Windows runs on D3D12 (through Dawn). These GPU rows run on CUDA and on Vulkan, so neither is the same API path as the browser.
- **Units differ.** Browser decode figures are characters per second; these are tokens per second.
