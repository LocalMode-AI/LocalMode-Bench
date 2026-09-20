#!/usr/bin/env bash
# Native llama.cpp baseline for the browser-tax analysis.
#
# Runs llama-bench on the SAME GGUF files the wllama browser lane uses, with
# the protocol-matched workload shape: pp128 + pp512 prefill, tg128 decode,
# 5 repetitions (thorough-suite parity). Two backend arms on Apple Silicon:
# Metal (default, -ngl 99) and CPU-only (-ngl 0, the wllama-WASM comparator).
#
# NEVER run this concurrently with a browser benchmark run on the same
# machine - the two contaminate each other's timings.
#
# Usage:   ./run-llama-bench.sh [outdir]
# Output:  <outdir>/llama-bench-<host>-<utc-date>-{metal,cpu}.json
#          plus llama-bench-version.txt (exact build, for the methods record)

set -euo pipefail

OUTDIR="${1:-$(cd "$(dirname "$0")" && pwd)}"
MODELDIR="${MODELDIR:-$HOME/.cache/localmode-bench-gguf}"
mkdir -p "$OUTDIR" "$MODELDIR"

if ! command -v llama-bench >/dev/null 2>&1; then
  echo "llama-bench not found. Install with: brew install llama.cpp" >&2
  exit 1
fi

# Record the exact build (llama-bench prints build info on stderr of --help).
llama-bench --version > "$OUTDIR/llama-bench-version.txt" 2>&1 || true

# The four wllama browser-lane GGUFs (URLs mirror apps/ui/src/lib/bench/catalog.ts).
MODELS=(
  "SmolLM2-135M-Instruct-Q4_K_M|https://huggingface.co/bartowski/SmolLM2-135M-Instruct-GGUF/resolve/main/SmolLM2-135M-Instruct-Q4_K_M.gguf"
  "Qwen3-0.6B-Q4_K_M|https://huggingface.co/unsloth/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_K_M.gguf"
  "Llama-3.2-1B-Instruct-Q4_K_M|https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf"
  "google_gemma-4-E2B-it-Q4_K_M|https://huggingface.co/bartowski/google_gemma-4-E2B-it-GGUF/resolve/main/google_gemma-4-E2B-it-Q4_K_M.gguf"
)

FILES=()
for entry in "${MODELS[@]}"; do
  name="${entry%%|*}"
  url="${entry#*|}"
  file="$MODELDIR/$name.gguf"
  if [ ! -f "$file" ]; then
    echo "Downloading $name ..."
    curl -L --fail --retry 3 -o "$file.part" "$url"
    mv "$file.part" "$file"
  fi
  FILES+=("$file")
done

HOST="$(hostname -s)"
DATE="$(date -u +%Y%m%d)"

# CPU arm thread count: the browser's wllama lane uses every hardware thread it
# is given (navigator.hardwareConcurrency when cross-origin isolated), so the
# native comparator uses the performance cores (Apple Silicon) or all cores.
CPU_THREADS="${CPU_THREADS:-$(sysctl -n hw.perflevel0.logicalcpu 2>/dev/null || sysctl -n hw.ncpu)}"
echo "cpu arm threads: $CPU_THREADS" | tee -a "$OUTDIR/llama-bench-version.txt"

run_arm() {
  local arm="$1" ngl="$2"
  local out="$OUTDIR/llama-bench-$HOST-$DATE-$arm.json"
  echo "== $arm arm (-ngl $ngl, -t $CPU_THREADS) -> $out"
  llama-bench \
    -m "$(IFS=,; echo "${FILES[*]}")" \
    -p 128,512 -n 128 -r 5 -ngl "$ngl" -t "$CPU_THREADS" \
    -o json > "$out"
}

for arm in ${ARMS:-metal cpu}; do
  case "$arm" in
    metal) run_arm metal 99 ;;
    cpu) run_arm cpu 0 ;;
  esac
done

echo "Done. Results in $OUTDIR"
