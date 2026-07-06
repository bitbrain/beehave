# Beehave Benchmarks

A lightweight, self-contained benchmark suite for Beehave. It treats the
addon as a black box: every measurement goes through the public
`BeehaveTree.tick()` API using the real, unmodified Beehave nodes.

Latest results: [results/results.md](results/results.md)

## How to run

Headless (recommended for publishable numbers):

```bash
godot --headless --path . res://benchmark/benchmark.tscn
```

Or open `benchmark/benchmark.tscn` in the editor and run the scene.

Results are written to `benchmark/results/`:

- `results.json` — raw statistics per case, for further processing
- `results.md` — markdown tables embedded in reports
- `<suite>.svg` — one bar chart per suite, embedded in the main README

## What is measured

Each suite lives in `benchmark/suites/` and extends
[`bench.gd`](bench.gd). Methods prefixed with `benchmark_` are discovered
and executed automatically by [`runner.gd`](runner.gd), following the same
convention as [godot-benchmarks](https://github.com/godotengine/godot-benchmarks).

| Suite | What it measures |
|---|---|
| `baseline_overhead` | The canonical community benchmark tree (selector → failing condition + sequence of two actions) against the identical logic hand-written as GDScript if/else. The resulting ratio expresses pure framework overhead and is largely machine-independent. |
| `blackboard_access` | Read-heavy, write-heavy and mixed trees built from the shipped expression-based blackboard leaves (`BlackboardSetAction`, `BlackboardCompareCondition`, `BlackboardHasCondition`, `BlackboardEraseAction`). |
| `macro_agents` | A 13-node patrol/chase/attack tree — the de-facto industry benchmark scenario for behavior trees — instantiated on 1 to 1000 agents, all ticked once per frame. Reported as milliseconds of AI time per frame. Agents deterministically cycle through all three branches. |
| `micro_nodes` | Per-tick cost of every composite and decorator type, configured for full traversal (sequences succeed, selectors fall through all children). |

## Statistical protocol

- Trees are ticked via `BeehaveTree.ProcessThread.MANUAL` and explicit
  `tick()` calls, timed with `Time.get_ticks_usec()`. This excludes engine
  `_physics_process` dispatch and isolates Beehave cost.
- Every case runs a warm-up phase first (discarded), which absorbs
  first-tick lazy initialization and cache warming.
- Micro benchmarks collect 50 batches of 200 ticks each; a sample is the
  mean tick time of one batch. Macro benchmarks collect 240 per-frame
  samples across real frames.
- All randomized composites run with a fixed seed (`1234`).
- Reported statistics per case: median, mean, p95, p99, min/max, standard
  deviation and coefficient of variation (CoV). Prefer the median when
  comparing runs; p95/p99 expose worst-case ticks that averages hide.
- The CoV is a run-quality signal: micro suites should stay in the low
  single digits on an idle machine. The macro suite is intentionally
  bimodal (cheap patrol frames vs. expensive branch-switch frames), so a
  high CoV there is expected — read its percentiles instead.

## Caveats

- `BeehaveTree.tick()` internally performs one blackboard write and a
  debugger fast-path check per tick. These are included in all
  measurements, since every real game pays that cost too.
- The runner disables error printing while sampling because Beehave's
  debugger integration logs errors on every tree registration when no
  debugger is attached (editor builds only); printing thousands of
  backtraces would distort results. Flip `VERBOSE_ERRORS` in
  [`runner.gd`](runner.gd) when debugging a suite.
- Results measured with an editor (debug) build of Godot are not
  comparable to export-template builds, and results from different
  machines are not comparable to each other. The environment line in
  `results.md` records date, Beehave and Godot versions, build type, OS
  and CPU for full disclosure.

## Guidelines for publishable numbers

1. Run on an idle machine on AC power; close other applications.
2. Run headless to avoid rendering interference.
3. Run at least 3 times and check that medians agree within a few
   percent; investigate any case whose CoV jumped.
4. Commit the regenerated `benchmark/results/` files together with the
   environment they were measured on (already embedded in `results.md`).
