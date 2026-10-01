# Native baseline for the LocalMode Bench methodology: llama-bench on an Intel Core Ultra 7 165H

`llama-bench` at llama.cpp `b29c606e2` (build 10964), the same commit as the M1 Pro native baseline (`native/2026/09/m1-pro/`), run on the same five GGUF files the browser lanes load, with the browser cells' workload shapes. Two local builds from the same source: CPU-only and Vulkan (Mesa ANV on the integrated Arc GPU).

**Read the thread sweep (section 4a) first.** This CPU has three kinds of core (performance, efficiency and low-power efficiency), and the sweep across 22, 16, 11, 6 and 4 threads, plus six threads pinned one per performance core, is the most informative result here.

> **Driver-stack difference from the browser runs.** The browser runs on this machine used Mesa 26.0.6. Before this session (2026-09-28, per `/var/log/pacman.log`) `mesa` and `vulkan-intel` were upgraded to 26.2.3 and `vulkan-icd-loader` from 1.4.341.0 to 1.4.357.0. Nothing was downgraded, so **the Vulkan rows ran on Mesa 26.2.3**, not 26.0.6. The `linux-cachyos` package was also upgraded (to 7.2.8-1), but the machine had not been rebooted, so the running kernel was 7.0.3-1-cachyos, the same as the browser runs. The CPU rows do not depend on Mesa.

## Files

| file | bytes | contents |
|---|---:|---|
| `README.md` | n/a | this file |
| `llama-bench.json` | 189856 | every result object from every invocation (145 objects from 33 invocations), concatenated in run order, all fields as emitted; `model_filename` is the bare file name |
| `llama-bench.md` | 14290 | per-model tables (`mean ± sd` tokens/s, `*` where sd > 10% of mean), resolved defaults, invocation status with throttle counters, parse notes |
| `environment.json` | 22268 | machine, core topology, OS, kernel, scheduler, power profile before/during/after, toolchain, both builds, Vulkan device list |
| `environment.txt` | 23660 | raw output of every environment command, one `### <command>` header each |
| `models.json` | 4408 | the five GGUF files: URL, expected and actual bytes and SHA-256, match flags, download time |

Redactions: the home-directory prefix of every path was replaced by `~` or removed (the build-cache `grep` excludes lines containing it, and the assert path in the failed bge invocations is given from `llama.cpp/`), the `USER` column of `top` and the local clock time on its first line (it gives the time zone) were removed, the `deviceUUID` and `driverUUID` lines of `vulkaninfo` were removed, and firewall log lines carrying network addresses were dropped before the kernel-log check. No host name, user name, serial number, MAC or IP address appears in any file. No other recorded output was altered.

## Wall clock (UTC)

| event | time |
|---|---|
| session start | 2026-10-01T01:00:26Z |
| environment capture | 2026-10-01T01:02:05Z |
| measurement start | 2026-10-01T01:15:31Z |
| Vulkan section (4b) | 2026-10-01T03:02:59Z – 03:13:58Z |
| measurement end | 2026-10-01T03:20:01Z |
| session end | 2026-10-01T03:23:51Z |

## Machine and software

- **Laptop:** Dell XPS 13 9340, 16 GB RAM (16179822592 bytes, as `free -b` reports it), plus 16 GB swap.
- **CPU:** Intel Core Ultra 7 165H (Meteor Lake, family 6 model 170 stepping 4, microcode 0x28): 16 cores, 22 logical CPUs. No AVX-512; it has AVX2, FMA, F16C and AVX-VNNI.
- **Core topology, from `lscpu -e`** (matches the expected 6 P + 8 E + 2 LP-E):

  | kind | cores | logical CPUs | max MHz |
  |---|---:|---|---:|
  | performance (2 threads each) | 6 (core ids 0–5) | (0,5), (1,2), (3,4), (6,7), (8,9), (10,11) | 5000 on CPUs 1–4, 4700 on the rest |
  | efficiency | 8 (core ids 6–13) | 12–19 | 3800 |
  | low-power efficiency | 2 (core ids 14–15) | 20, 21 | 2500 |

  Note that P-core 0 owns logical CPUs 0 **and 5**.
- **iGPU:** Intel Arc Graphics (Meteor Lake-P, PCI 8086:7d55).
- **OS:** CachyOS (rolling), running kernel `Linux 7.0.3-1-cachyos x86_64`. Installed packages: `linux-cachyos` 7.2.8-1 (not booted), `mesa` 3:26.2.3-1, `vulkan-intel` (ANV) 3:26.2.3-1, `vulkan-icd-loader` 1.4.357.0-1.1.
- **Scheduler:** `sched_ext` state `disabled`, so the kernel's default scheduler ran (no `scx` scheduler); it was not changed.
- **Frequency driver:** `intel_pstate` (HWP); `no_turbo` = 0.
- **Power profile:**

  | | `powerprofilesctl` | governor | EPP |
  |---|---|---|---|
  | before | power-saver | powersave ×22 | power ×22 |
  | during (`powerprofilesctl set performance`) | performance | powersave ×22 | performance ×22 |
  | after (`powerprofilesctl set power-saver`) | power-saver | powersave ×22 | power ×22 |

  Under HWP, `intel_pstate` reports the governor as `powersave` in every profile; the profile acts through EPP. Turbo and power limits were not touched.
- **llama.cpp:** `https://github.com/ggml-org/llama.cpp`, full clone, `git checkout b29c606e2` → `b29c606e28a01b1bc8c1351026a0fa6e616bf6c4`, `git describe` `v0.4.1`, `git rev-list --count HEAD` 10964. `llama-bench` prints `build: b29c606e2 (10964)`. No fallback was needed, and no distribution llama.cpp package is installed.
  - **CPU-only build:** `cmake -B build-cpu -DCMAKE_BUILD_TYPE=Release`, then `cmake --build build-cpu --config Release -j 16 --target llama-bench`. Compiler GNU 16.2.1 (C and C++); the configure log reports `Adding CPU backend variant ggml-cpu: -march=native`. `GGML_NATIVE=ON`, `GGML_AVX512=OFF`, `GGML_VULKAN=OFF`, `GGML_BLAS=OFF`; every `GGML_*`/`LLAMA_*` entry is at its default. `LLAMA_CURL=OFF` was not needed (this commit configures with OpenSSL and has no CURL requirement).
  - **Vulkan build:** the same plus `-DGGML_VULKAN=ON`. The only cache difference is `GGML_VULKAN=ON`. Vulkan loader 1.4.357; `glslc` from shaderc 2026.3.
- **Vulkan device:** `vulkaninfo --summary` lists one device, `Intel(R) Arc(tm) Graphics (MTL)`, `PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU`, driver `Intel open-source Mesa driver`, `Mesa 26.2.3-arch3.1`, apiVersion 1.4.354, driverVersion 26.2.3. No `llvmpipe` is present. llama.cpp picked the Arc:

  ```
  ggml_vulkan: Found 1 Vulkan devices:
  ggml_vulkan: 0 = Intel(R) Arc(tm) Graphics (MTL) (Intel open-source Mesa driver) | uma: 1 | fp16: 1 | bf16: 0 | fp4: 0 | warp size: 32 | shared memory: 49152 | int dot: 1 | matrix cores: none
  ```

  `gpu_info` in every Vulkan result is `Intel(R) Arc(tm) Graphics (MTL)`. `GGML_VK_VISIBLE_DEVICES` was not set.
- **Toolchain:** git 2.55.0, cmake 4.4.3, gcc 16.2.1 20260810, Python 3.14.7. `sudo pacman -S --needed base-devel git cmake python vulkan-headers vulkan-icd-loader vulkan-intel vulkan-tools shaderc spirv-headers lm_sensors` newly installed `cmake`, `vulkan-headers`, `vulkan-tools` and `spirv-headers` (plus `cppdap`, `jsoncpp` and `rhash`) and upgraded nothing. Every version is in `environment.json`.

## Ambient conditions

- **Power and placement:** on AC (`/sys/class/power_supply/AC/online` = 1 at capture), lid open, flat on a hard surface with the vents clear, kept awake by `systemd-inhibit --what=idle:sleep:handle-lid-switch`.
- **Browsers:** Chrome 144 was running at session start, with one renderer at about 285% CPU that exited on its own within a minute. Chrome was then closed with SIGTERM. Its open tabs could not be inspected from the command line, so the absence of a `localmode.ai/bench/run` tab rests on the closure itself. Firefox was not running. `pgrep -a chrome; pgrep -a firefox` printed nothing before the first measurement.
- **Hung process:** a `pacman -Q codex-desktop` process started by the `codex-update-manager` daemon had been spinning at 100% of one core for 2 days 9 hours. It was killed before the builds and did not reappear.
- **At measurement start (`top`):** 98.6% idle; the busiest processes were the desktop shell (9.6%), `tailscaled`, the Wayland compositor, a terminal and the agent session running the benchmark (4.8% each). Memory available was 13.2 GB.

## Model files

Expected sizes come from the browser harness catalog; expected SHA-256 values are the ones the M1 Pro baseline recorded for the same URLs. All five files downloaded with `curl -L --fail` on the first attempt, and **all match both**.

| bench model id | file | bytes | sha256 | size matches | sha256 matches |
|---|---|---:|---|---|---|
| smollm2-135m | `SmolLM2-135M-Instruct-Q4_K_M.gguf` | 105454432 | `2e8040ceae7815abe0dcb3540b9995eaa1fa0d2ca9e797d0a635ae4433c68c2d` | yes | yes |
| qwen3-0.6b | `Qwen3-0.6B-Q4_K_M.gguf` | 396705472 | `ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a` | yes | yes |
| llama-3.2-1b | `Llama-3.2-1B-Instruct-Q4_K_M.gguf` | 807694464 | `6f85a640a97cf2bf5b8e764087b1e83da0fdb51d7c9fab7d0fece9385611df83` | yes | yes |
| gemma-4-e2b | `google_gemma-4-E2B-it-Q4_K_M.gguf` | 3462680032 | `923c4c86177d2ee173a7f5b4fa3d0ac65f5962ab15e6d6a5bc250aec4fd7bf7e` | yes | yes |
| bge-small-en | `bge-small-en-v1.5-q8_0.gguf` | 36806944 | `ec38e8da142596baa913124ae50550de284b6916bf59577ef2f0cb9660c2f514` | yes | yes |

## Method

- **Why a local build:** a distribution package ships its packager's commit, not `b29c606e2`, and a GPU-enabled package can send large prompt batches to the GPU even with `-ngl 0`, which would contaminate the CPU rows. Two local builds from one source avoid both.
- **Paths:** every invocation ran from inside the models directory with a relative model path, so `model_filename` is the bare file name.
- **Output flags:** `-o json -oe md` only, with stdout to `<id>.json` and stderr (markdown table plus `build:` line) to `<id>.log`.
- **Shapes:** `-p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5` for the language models; `-embd 1 -p 48,1536 -n 0 -r 5` and `-embd 1 -p 512 -n 0 -r 5` for bge-small. `llama-bench` does its own warmup.
- **Context size:** `llama-bench --help` at this commit has **no `-c` / `--ctx-size` option**, and its JSON has no `n_ctx` field. It sizes each test's context to the test (at most 640 tokens, for `pg512+128`). Nothing was added. The browser loads language models with `n_ctx` 2048 and bge with 512.
- **Defaults left alone:** apart from the pinned invocations, no `-b`, `-ub`, `-fa`, `-ctk`, `-ctv`, `-mmp`, CPU mask or priority was set. They resolved to `n_batch` 2048, `n_ubatch` 512, `flash_attn` -1 (auto), `type_k`/`type_v` f16, `load_mode`/`lazy_mode` auto, `poll` 50 and `n_depth` 0, the same `n_batch`/`n_ubatch` as on the M1 Pro. The browser lanes also run the library defaults, but their run files do not record them. (Full list: "Resolved defaults" in `llama-bench.md`.)
- **Order:**
  - 4a: CPU-only build; per model, in the order SmolLM2, Qwen3, Llama 3.2, Gemma 4, `-ngl 0` at `-t` 22, 16, 11, 6, 4, then the pinned invocation.
  - 4b: Vulkan build, `-ngl 99 -t 11`, same model order.
  - 4c: bge-small.
- **Thread counts:** 22 = every logical thread (Chrome's `hardwareConcurrency`, the browser lane under protocol v4); 16 = physical cores; 11 = protocol v5 rule `max(2, ceil(22/2))`; 6 = P-core count; 4 = the low end. Unpinned, so the kernel scheduler placed the threads, as it does for the browser.
- **Pinned invocation:** `-t 6 -C 0x54B --cpu-strict 1`. Mask `0x54B` selects logical CPUs 0, 1, 3, 6, 8, 10, the lowest-numbered logical CPU of each of the six P-cores in the topology above. (It is not `0x555`, because P-core 0 is CPUs 0 and 5.)
- **Waits:** 60 s between invocations, and 120 s between models and between sections.
- **Timeouts:** each invocation ran as `timeout 1200 …`. None reached the limit.
- **Thermal log:** before and after each model in each section: coretemp package and core temperatures, cpu0 `package_throttle_count`/`core_throttle_count`, and mean `/proc/cpuinfo` MHz. The two throttle counters were also read before and after every invocation (`llama-bench.md`, Invocation status).
- **Smoke tests (not results):** `llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -p 16 -n 8 -r 1` with the CPU build, and the same with the Vulkan build and `-ngl 99`. Both exited 0, and Vulkan selected the Arc.

## Results (tokens/s, `mean ± sd` over 5 repetitions; `*` = sd > 10% of mean)

### smollm2-135m

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 561.55 ± 12.24 | 611.88 ± 22.50 | 33.29 ± 5.39* | 44.78 ± 1.36 | 92.06 ± 4.99 |
| cpu t=16 | 673.91 ± 27.67 | 638.70 ± 16.32 | 72.73 ± 1.16 | 90.24 ± 15.45* | 127.93 ± 15.62* |
| cpu t=11 | 696.09 ± 60.53 | 618.77 ± 12.56 | 101.09 ± 7.52 | 129.46 ± 12.46 | 159.62 ± 9.49 |
| cpu t=6 | 507.23 ± 39.05 | 491.56 ± 43.76 | 110.53 ± 3.78 | 125.10 ± 12.23 | 154.95 ± 9.03 |
| cpu t=4 | 445.92 ± 89.34* | 391.15 ± 18.67 | 106.73 ± 3.50 | 137.82 ± 8.40 | 160.21 ± 8.30 |
| cpu t=6 p-cores | 764.28 ± 3.30 | 554.86 ± 120.97* | 126.47 ± 6.99 | 177.67 ± 6.61 | 171.79 ± 9.07 |
| vulkan | 3204.52 ± 632.82* | 3469.64 ± 128.30 | 101.21 ± 15.51* | 148.56 ± 7.34 | 275.67 ± 15.19 |

### qwen3-0.6b

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 315.72 ± 4.39 | 289.65 ± 4.85 | 18.85 ± 4.67* † | 28.44 ± 1.75 | 55.27 ± 0.77 |
| cpu t=16 | 356.50 ± 4.19 | 296.09 ± 36.91* | 34.87 ± 5.71* | 42.46 ± 0.97 | 73.91 ± 0.86 |
| cpu t=11 | 319.22 ± 6.44 | 225.84 ± 52.80* | 38.69 ± 4.93* | 49.80 ± 1.04 | 74.99 ± 1.15 |
| cpu t=6 | 251.82 ± 10.60 | 167.68 ± 24.20* | 34.57 ± 2.47 | 46.19 ± 0.49 | 63.79 ± 2.73 |
| cpu t=4 | 218.59 ± 15.20 | 148.54 ± 6.98 | 34.82 ± 5.95* | 42.44 ± 0.74 | 62.73 ± 3.08 |
| cpu t=6 p-cores | 315.75 ± 5.78 | 189.06 ± 9.78 | 53.72 ± 2.91 | 51.10 ± 2.06 | 75.99 ± 11.92* |
| vulkan | 596.20 ± 23.94 | 879.51 ± 94.85* | 41.19 ± 4.33* | 106.90 ± 23.37* | 240.60 ± 10.23 |

† One of the five `tg128` samples of `4a_qwen3-0.6b_cpu_t22` is invalid: its `samples_ns` value is 18446744071171093742, that is 2^64 - 2538457874, a duration of -2.538 s stored as an unsigned 64-bit integer, so the clock `llama-bench` timed it with went backwards during that repetition. `llama-bench` reported 15.08 ± 9.35 for this cell, counting that sample as about 0 tokens/s; the cell above is the mean ± sd of the other four samples (25.69, 17.90, 16.38 and 15.44 tokens/s). `llama-bench.json` keeps the object exactly as emitted. No other sample in the file is negative or wrapped.

### llama-3.2-1b

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 171.99 ± 2.19 | 125.59 ± 23.03* | 17.18 ± 2.98* | 27.23 ± 0.60 | 46.47 ± 1.11 |
| cpu t=16 | 175.47 ± 1.00 | 115.48 ± 7.99 | 24.91 ± 4.90* | 33.44 ± 1.16 | 54.56 ± 1.54 |
| cpu t=11 | 165.10 ± 4.51 | 101.66 ± 6.40 | 26.98 ± 2.45 | 35.25 ± 0.47 | 53.16 ± 1.05 |
| cpu t=6 | 115.23 ± 23.54* | 74.83 ± 3.74 | 22.64 ± 1.92 | 30.66 ± 0.38 | 43.77 ± 1.05 |
| cpu t=4 | 94.02 ± 8.80 | 68.76 ± 4.72 | 19.25 ± 2.52* | 25.34 ± 0.51 | 38.11 ± 0.61 |
| cpu t=6 p-cores | 124.25 ± 27.94* | 81.35 ± 5.28 | 25.24 ± 1.91 | 34.04 ± 2.20 | 48.51 ± 3.40 |
| vulkan | 516.97 ± 80.65* | 606.07 ± 21.68 | 59.50 ± 0.97 | 73.04 ± 12.73* | 201.56 ± 5.46 |

### gemma-4-e2b

| config | pp128 | pp512 | tg128 | pg128+128 | pg512+128 |
|---|---:|---:|---:|---:|---:|
| cpu t=22 | 64.77 ± 7.18* | 41.77 ± 1.34 | 7.16 ± 0.54 | 11.89 ± 0.29 | 20.16 ± 0.62 |
| cpu t=16 | 65.91 ± 10.79* | 44.03 ± 1.33 | 9.55 ± 1.09* | 14.82 ± 0.18 | 24.03 ± 0.77 |
| cpu t=11 | 56.90 ± 11.84* | 40.07 ± 0.57 | 10.75 ± 0.72 | 15.91 ± 0.16 | 23.78 ± 0.49 |
| cpu t=6 | 39.30 ± 4.72* | 31.63 ± 0.33 | 10.07 ± 0.59 | 14.68 ± 0.08 | 20.50 ± 0.45 |
| cpu t=4 | 35.71 ± 2.59 | 27.89 ± 0.60 | 8.94 ± 0.74 | 12.51 ± 0.15 | 18.17 ± 0.62 |
| cpu t=6 p-cores | 47.62 ± 7.23* | 35.03 ± 0.32 | 11.88 ± 0.15 | 16.46 ± 0.42 | 23.69 ± 0.62 |
| vulkan | 164.03 ± 4.86 | 158.08 ± 4.21 | 18.29 ± 3.84* | 36.31 ± 0.48 | 60.78 ± 7.13* |

### bge-small-en

`pp48` and `pp1536` come from the `-p 48,1536` invocations; `pp512` from the supplementary `-p 512` invocations (none at t=22).

| config | pp48 | pp1536 | pp512 |
|---|---:|---:|---:|
| cpu t=22 | 1781.43 ± 115.48 | failed | not run |
| cpu t=11 | 3001.78 ± 478.88* | failed | 3142.29 ± 44.85 |
| vulkan | 2520.48 ± 72.29 | failed | 6507.54 ± 457.76 |

## Every invocation, in run order

| # | id | status | wall s | command (binary: `../llama.cpp/<build>/bin/llama-bench`, wrapped in `timeout 1200`) |
|---:|---|---|---:|---|
| 1 | `4a_smollm2-135m_cpu_t22` | OK | 92 | `build-cpu/bin/llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 2 | `4a_smollm2-135m_cpu_t16` | OK | 56 | `build-cpu/bin/llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 3 | `4a_smollm2-135m_cpu_t11` | OK | 44 | `build-cpu/bin/llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 4 | `4a_smollm2-135m_cpu_t6` | OK | 46 | `build-cpu/bin/llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 5 | `4a_smollm2-135m_cpu_t4` | OK | 47 | `build-cpu/bin/llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 6 | `4a_smollm2-135m_cpu_t6_pcores` | OK | 40 | `build-cpu/bin/llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 7 | `4a_qwen3-0.6b_cpu_t22` | OK | 147 | `build-cpu/bin/llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 8 | `4a_qwen3-0.6b_cpu_t16` | OK | 109 | `build-cpu/bin/llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 9 | `4a_qwen3-0.6b_cpu_t11` | OK | 106 | `build-cpu/bin/llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 10 | `4a_qwen3-0.6b_cpu_t6` | OK | 124 | `build-cpu/bin/llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 11 | `4a_qwen3-0.6b_cpu_t4` | OK | 132 | `build-cpu/bin/llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 12 | `4a_qwen3-0.6b_cpu_t6_pcores` | OK | 105 | `build-cpu/bin/llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 13 | `4a_llama-3.2-1b_cpu_t22` | OK | 191 | `build-cpu/bin/llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 14 | `4a_llama-3.2-1b_cpu_t16` | OK | 163 | `build-cpu/bin/llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 15 | `4a_llama-3.2-1b_cpu_t11` | OK | 164 | `build-cpu/bin/llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 16 | `4a_llama-3.2-1b_cpu_t6` | OK | 202 | `build-cpu/bin/llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 17 | `4a_llama-3.2-1b_cpu_t4` | OK | 233 | `build-cpu/bin/llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 18 | `4a_llama-3.2-1b_cpu_t6_pcores` | OK | 184 | `build-cpu/bin/llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 19 | `4a_gemma-4-e2b_cpu_t22` | OK | 461 | `build-cpu/bin/llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 22 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 20 | `4a_gemma-4-e2b_cpu_t16` | OK | 386 | `build-cpu/bin/llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 16 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 21 | `4a_gemma-4-e2b_cpu_t11` | OK | 385 | `build-cpu/bin/llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 22 | `4a_gemma-4-e2b_cpu_t6` | OK | 448 | `build-cpu/bin/llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 6 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 23 | `4a_gemma-4-e2b_cpu_t4` | OK | 510 | `build-cpu/bin/llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 4 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 24 | `4a_gemma-4-e2b_cpu_t6_pcores` | OK | 392 | `build-cpu/bin/llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 0 -t 6 -C 0x54B --cpu-strict 1 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 25 | `4b_smollm2-135m_vulkan` | OK | 29 | `build-vulkan/bin/llama-bench -m SmolLM2-135M-Instruct-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 26 | `4b_qwen3-0.6b_vulkan` | OK | 50 | `build-vulkan/bin/llama-bench -m Qwen3-0.6B-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 27 | `4b_llama-3.2-1b_vulkan` | OK | 53 | `build-vulkan/bin/llama-bench -m Llama-3.2-1B-Instruct-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 28 | `4b_gemma-4-e2b_vulkan` | OK | 167 | `build-vulkan/bin/llama-bench -m google_gemma-4-E2B-it-Q4_K_M.gguf -ngl 99 -t 11 -p 128,512 -n 128 -pg 128,128 -pg 512,128 -r 5 -o json -oe md` |
| 29 | `4c_bge-small-en_cpu_t22` | FAILED(rc=134) | 0 | `build-cpu/bin/llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 22 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 30 | `4c_bge-small-en_cpu_t11` | FAILED(rc=134) | 1 | `build-cpu/bin/llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 11 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 31 | `4c_bge-small-en_vulkan` | FAILED(rc=134) | 1 | `build-vulkan/bin/llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 11 -p 48,1536 -n 0 -r 5 -o json -oe md` |
| 32 | `4c_bge-small-en_cpu_t11_p512` | OK | 1 | `build-cpu/bin/llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 0 -t 11 -p 512 -n 0 -r 5 -o json -oe md` |
| 33 | `4c_bge-small-en_vulkan_p512` | OK | 0 | `build-vulkan/bin/llama-bench -m bge-small-en-v1.5-q8_0.gguf -embd 1 -ngl 99 -t 11 -p 512 -n 0 -r 5 -o json -oe md` |

## Failed or skipped invocations

`4c_bge-small-en_cpu_t22`, `4c_bge-small-en_cpu_t11` and `4c_bge-small-en_vulkan` aborted (exit 134, SIGABRT) on the `pp1536` test, after `pp48` had completed and been written, exactly as on the M1 Pro:

```
llama.cpp/src/llama-context.cpp:1437: GGML_ASSERT(cparams.n_ubatch >= n_tokens && "encoder requires n_ubatch >= n_tokens") failed
```

bge-small is an encoder, and the default micro-batch is 512 tokens. As instructed, they were not re-run with a larger `-ub`. The completed `pp48` objects are kept; the repair of the truncated JSON is described in `llama-bench.md` (Parse notes). The supplementary `-p 512` invocations (`4c_bge-small-en_cpu_t11_p512`, `4c_bge-small-en_vulkan_p512`) completed. Nothing was skipped.

## Thermal log

| UTC | point | package | hottest core | throttle pkg/core | avg MHz |
|---|---|---:|---:|---:|---:|
| 2026-10-01T01:15:31Z | start | +61.0°C | 60 °C | 6038/98 | 1642 |
| 2026-10-01T01:15:31Z | 4a smollm2-135m before | +61.0°C | 60 °C | 6038/98 | 1902 |
| 2026-10-01T01:25:57Z | 4a smollm2-135m after | +66.0°C | 63 °C | 6691/166 | 1204 |
| 2026-10-01T01:27:57Z | 4a qwen3-0.6b before | +52.0°C | 50 °C | 6741/172 | 1105 |
| 2026-10-01T01:45:00Z | 4a qwen3-0.6b after | +67.0°C | 65 °C | 7613/239 | 977 |
| 2026-10-01T01:47:00Z | 4a llama-3.2-1b before | +51.0°C | 50 °C | 7684/253 | 1290 |
| 2026-10-01T02:10:57Z | 4a llama-3.2-1b after | +69.0°C | 65 °C | 11821/336 | 814 |
| 2026-10-01T02:12:57Z | 4a gemma-4-e2b before | +51.0°C | 50 °C | 11876/338 | 1260 |
| 2026-10-01T03:00:59Z | 4a gemma-4-e2b after | +68.0°C | 65 °C | 17097/433 | 872 |
| 2026-10-01T03:02:59Z | 4b smollm2-135m before | +51.0°C | 51 °C | 17149/439 | 1600 |
| 2026-10-01T03:03:28Z | 4b smollm2-135m after | +66.0°C | 64 °C | 18308/455 | 1788 |
| 2026-10-01T03:05:28Z | 4b qwen3-0.6b before | +51.0°C | 49 °C | 18390/472 | 1422 |
| 2026-10-01T03:06:18Z | 4b qwen3-0.6b after | +72.0°C | 68 °C | 19043/474 | 1569 |
| 2026-10-01T03:08:18Z | 4b llama-3.2-1b before | +50.0°C | 49 °C | 19120/494 | 1135 |
| 2026-10-01T03:09:11Z | 4b llama-3.2-1b after | +75.0°C | 69 °C | 19867/495 | 1668 |
| 2026-10-01T03:11:11Z | 4b gemma-4-e2b before | +51.0°C | 51 °C | 19939/508 | 1218 |
| 2026-10-01T03:13:58Z | 4b gemma-4-e2b after | +75.0°C | 71 °C | 20634/522 | 2009 |
| 2026-10-01T03:15:58Z | 4c bge-small-en before | +51.0°C | 50 °C | 20720/534 | 1218 |
| 2026-10-01T03:20:01Z | 4c bge-small-en after | +55.0°C | 65 °C | 20865/557 | 1641 |
| 2026-10-01T03:20:31Z | final | +51.0°C | 51 °C | 20890/557 | 1441 |

- **Peak temperatures:** never above 75 °C (limit 110 °C), and the fans had not been running at capture.
- **Throttle counters rose throughout:** the package throttle counter of cpu0 rose from 5885 at environment capture (6038 at measurement start; the builds ran in between) to 20890 at the end, and the core counter from 63 to 557. Both rose during **every** invocation and also during the idle waits.
- **Largest package-counter rises:** `4a_llama-3.2-1b_cpu_t22` (+1800), `4a_llama-3.2-1b_cpu_t16` (+1952), `4a_gemma-4-e2b_cpu_t22` (+2194), `4a_gemma-4-e2b_cpu_t16` (+2342), `4b_smollm2-135m_vulkan` (+1159).

Per-invocation counts are in `llama-bench.md`. The mean frequency read just after each 4a model (814–1204 MHz) was lower than just before (1105–1902 MHz); these are single instantaneous readings.

## Kernel-log check

`journalctl -k --since "2026-10-01 01:15:31 UTC" | grep -Ei 'i915|xe|gpu hang|reset'` returned **none** (firewall `UFW BLOCK` lines were removed before the grep because they carry network addresses). There was no allocation failure, device loss or GPU reset during the run.

## Reading the numbers against the browser lanes

- **`tg128` generates from an empty context.** The browser decodes after a real prompt, so the `pg128+128` / `pg512+128` rows are the closer analogue. Note that `llama-bench` reports `pg` as (prompt + generated tokens) / total time, so it is not a pure decode rate. The browser's language-model figures are characters per second of decode, not tokens per second, so they are not directly comparable to any column here.
- **Prefill:** `pp128` / `pp512` correspond to the browser's prefill.
- **bge-small:** `pp48 / 48` gives texts per second for one ~48-token text; 48 / `pp48` is seconds per text. The browser's 32-text batch (~1536 tokens) has no native result, because `pp1536` aborts (above); `pp512` is the largest batch inside the default micro-batch.
- **Instruction set:** the native CPU build uses this CPU's native vector instructions (`-march=native`: AVX2, FMA, AVX-VNNI), while the browser lane runs WebAssembly SIMD (128-bit).
- **Threads:** the browser llama.cpp lanes ran 11 threads under protocol `localmode-bench/5` and 22 under v4. Compare the `cpu t=11` and `cpu t=22` rows respectively.
- **GPU:** the browser has no llama.cpp WebGPU language-model result on this machine (the WebGPU lane aborts in `create_webgpu_device`), so there is nothing to compare the Vulkan language-model rows with. The Vulkan rows show what the Arc iGPU does with llama.cpp natively, and they ran on Mesa 26.2.3, not the browser runs' 26.0.6 (see the top of this file).
