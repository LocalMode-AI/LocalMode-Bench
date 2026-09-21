#!/usr/bin/env node
// Rewrite every run file under runs/ and quarantine/ to the publication rule
// of @localmode/bench (schema 3): remove the fields a public file must not
// carry, raise the schema version, recompute the digest, stamp scrubbedAt.
// Files that already conform are left byte-identical. Idempotent.
//
// Usage:  node tools/scrub-publication.mjs [--dry-run] [--bench <path to @localmode/bench dist/index.js>]
// Needs:  @localmode/bench >= 0.7.0 resolvable from this directory (npm i --no-save @localmode/bench),
//         or --bench pointing at a built checkout.
import { readdir, readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const benchArg = args.indexOf('--bench');
const benchSpec = benchArg >= 0 ? pathToFileURL(args[benchArg + 1]).href : '@localmode/bench';
const { scrubRunForPublication, computeRunDigest, verifyRunDigest } = await import(benchSpec);

async function* jsonFiles(dir) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) yield* jsonFiles(path);
    else if (entry.name.endsWith('.json')) yield path;
  }
}

let seen = 0;
let rewritten = 0;
const removedCounts = new Map();
for (const root of ['runs', 'quarantine']) {
  for await (const path of jsonFiles(root)) {
    seen += 1;
    const original = await readFile(path, 'utf8');
    const run = JSON.parse(original);
    if (!(await verifyRunDigest(run))) {
      console.error(`SKIP ${path}: digest does not verify under either rule; not touching it`);
      continue;
    }
    const { run: scrubbed, changed, removed } = scrubRunForPublication(run);
    if (!changed && !removed.includes('nonce')) continue;
    for (const field of removed) removedCounts.set(field, (removedCounts.get(field) ?? 0) + 1);
    let published = scrubbed;
    if (changed) {
      published = { ...scrubbed, scrubbedAt: new Date().toISOString() };
      published.digest = await computeRunDigest(published);
    }
    if (!(await verifyRunDigest(published))) throw new Error(`digest failed to verify after scrub: ${path}`);
    rewritten += 1;
    console.log(`${dryRun ? 'would rewrite' : 'rewrote'} ${path}: ${removed.join(', ')}`);
    if (!dryRun) await writeFile(path, JSON.stringify(published));
  }
}
console.log(`${seen} files, ${rewritten} ${dryRun ? 'to rewrite' : 'rewritten'}`);
for (const [field, n] of [...removedCounts].sort()) console.log(`  ${field}: ${n}`);
