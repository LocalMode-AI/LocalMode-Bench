# LocalMode Bench - Open Data

Community-submitted [LocalMode Bench](https://localmode.ai/bench) runs: LLM
and embedding inference measured across browser AI runtimes (WebLLM, wllama,
Transformers.js, LiteRT-LM, Chrome Built-in AI, MediaPipe) on real consumer
devices. Every run file carries its raw timing traces, so every published
number can be recomputed. Background, integrity model and known limitations:
[NOTES.md](./NOTES.md).

## Layout

```
runs/YYYY/MM/<runId>.json          verified submissions
quarantine/YYYY/MM/<runId>.json    submissions flagged by the integrity rules (public, off the leaderboard)
index/summary.json                 one light entry per run, written by the submission API (do not edit)
index/errata.json                  published cells excluded from every aggregate, each with a reason
controls/<kind>/<YYYY-MM-DD>/      control runs for the methodology, never indexed
native/YYYY/MM/<device>/           native llama-bench baselines on lab machines, not on the leaderboard
tools/                             run-llama-bench.sh (native baselines), scrub-publication.mjs
```

Run files are written by the submission API only; documentation PRs are welcome.

## Reading a run

Each file is one `BenchRunResult` JSON object, for example
`runs/2026/10/04c78ea8-c2bc-4652-b93f-9b01a601a727.json`. Start with:

- `protocol`: the protocol version it was measured under (`localmode-bench/5` is current)
- `environment`: browser, OS, GPU, device type and the rest of the capture
- `cells[]`: one per runtime, model and workload: `cellId`, `status`, raw `iterations`

Every field is documented in [SCHEMA.md](./SCHEMA.md).

## How the leaderboard is derived

The submission API appends one entry per run to `index/summary.json`
(rebuildable from the run files with
[`rebuild-bench-index.ts`](https://github.com/LocalMode-AI/LocalMode/blob/main/apps/ui/scripts/rebuild-bench-index.ts)).
The [leaderboard](https://localmode.ai/bench) aggregates the verified entries
of the current and the previous protocol version, in separate rows that never
mix, as medians of per-device medians; a row needs 3 or more concordant
submissions to leave provisional status. Cells listed in `index/errata.json`
are excluded and counted, never re-scored. Full rules:
[methodology](https://localmode.ai/bench/methodology).

To recompute everything from a clone:

```bash
git clone https://github.com/LocalMode-AI/LocalMode-Bench
git clone https://github.com/LocalMode-AI/LocalMode
cd LocalMode && pnpm install
npx tsx packages/bench/scripts/analyze.ts ../LocalMode-Bench/runs ./analysis
# -> leaderboard.csv, iterations.csv, cells.csv, runs.csv, validation.txt, errata.txt
#    (index/errata.json is applied to leaderboard.csv only; --no-errata applies none)
```

## Contributing a run

Open [localmode.ai/bench/run](https://localmode.ai/bench/run) on your
device, run a suite, and press "Submit to leaderboard". What gets published
is the run file: per-chunk traces, the generated text for the fixed public
prompts, the environment capture and a SHA-256 digest, under CC0. It
describes a device, never a person: no time zone, language list, exact
battery level, submission nonce or network address.

## Controls

`controls/` holds control runs: the same suite in another runtime order or
with the Transformers.js WASM lane configured differently, recorded to test
the methodology. They are never submitted, indexed or shown on the
leaderboard. Kinds and filing: [NOTES.md, Control runs](./NOTES.md#control-runs).

## Errata

A published cell that turns out not to measure what the protocol describes
is listed in `index/errata.json` with its reason and left out of every
aggregate; the run file is never changed and nothing is re-scored. The
full record is in [NOTES.md, Errata](./NOTES.md#errata).

- **Erratum, LiteRT Qwen3 model file (12 and 13 October 2026)**: 12 cells
  of 11 v5 Thorough runs from one RTX 3080 Ti that loaded a replaced
  `Qwen3-0.6B.litertlm`. Evidence and the run table:
  [NOTES.md](./NOTES.md#erratum-litert-qwen3-model-file-12-and-13-october-2026).

<details><summary>The 11 affected runs</summary>

`514bf170-30be-4dcc-ad42-1207ba9ceb10`, `8f7f6b49-724a-4799-8ae0-7a3672ffb889`,
`eafd4448-d0de-48e4-8f64-da8f481f5edf`, `42a9f6ba-0977-4438-9b9d-9cf5b6427f20`,
`1b5e99ab-780f-432c-a80b-01dbcf75fd37`, `094063b8-8251-40e1-9978-e069bb764a66`,
`3b06e45a-a7ad-4b8c-8d5a-97a725018c41`, `40aaa83a-0a6f-4949-9341-45320ba1d92a`,
`651a18d7-b3de-4bbd-afd4-403dba6165e2`, `39f75908-0676-4959-b499-fc532a110ca2`,
`febbece7-76a1-4088-bb17-aa03d1c10708`

</details>

## License and citation

Data: [CC0 1.0](./LICENSE) (public domain); submitters agree at submission
time. The reference implementation is the MIT-licensed
[`@localmode/bench`](https://github.com/LocalMode-AI/LocalMode/tree/main/packages/bench).

To cite, see [CITATION.cff](./CITATION.cff), and name the protocol
version(s) of the runs you used (each run file records its `protocol`).
