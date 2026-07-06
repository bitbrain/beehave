# Beehave Benchmark Results

`2026-07-06` | Beehave `2.9.3-dev` | Godot `4.7-stable (official)` (debug build) | Linux 44.20260629.0 (Kinoite) | AMD Ryzen 7 9800X3D 8-Core Processor (16 threads)

All values are per workload invocation. Lower is better. See
[the methodology](../README.md) for details on how these are measured.

## Framework overhead vs raw GDScript

| Case | Median | Mean | P95 | P99 | CoV | Overhead |
|---|---:|---:|---:|---:|---:|---:|
| gdscript_equivalent | 0.175 µs/call | 0.179 µs/call | 0.213 µs/call | 0.230 µs/call | 7.6% | — |
| beehave_tree | 7.38 µs/tick | 7.41 µs/tick | 7.50 µs/tick | 7.56 µs/tick | 0.7% | 42.2× |

## Blackboard access patterns

| Case | Median | Mean | P95 | P99 | CoV |
|---|---:|---:|---:|---:|---:|
| write_heavy | 8.00 µs/tick | 8.05 µs/tick | 8.21 µs/tick | 8.74 µs/tick | 2.0% |
| read_heavy | 11.2 µs/tick | 11.3 µs/tick | 11.5 µs/tick | 11.7 µs/tick | 1.2% |
| mixed | 10.0 µs/tick | 10.0 µs/tick | 10.3 µs/tick | 10.3 µs/tick | 1.1% |

## Agent scaling (patrol/chase/attack)

| Case | Median | Mean | P95 | P99 | CoV |
|---|---:|---:|---:|---:|---:|
| 1 agent | 0.015 ms/frame | 0.017 ms/frame | 0.028 ms/frame | 0.072 ms/frame | 75.1% |
| 10 agents | 0.065 ms/frame | 0.079 ms/frame | 0.193 ms/frame | 0.264 ms/frame | 56.9% |
| 100 agents | 0.573 ms/frame | 0.674 ms/frame | 1.16 ms/frame | 3.28 ms/frame | 66.2% |
| 500 agents | 2.62 ms/frame | 3.15 ms/frame | 5.85 ms/frame | 9.98 ms/frame | 46.3% |
| 1000 agents | 5.05 ms/frame | 6.22 ms/frame | 12.2 ms/frame | 19.4 ms/frame | 46.9% |

## Per-node tick cost

| Case | Median | Mean | P95 | P99 | CoV |
|---|---:|---:|---:|---:|---:|
| tree_with_single_action | 1.42 µs/tick | 1.42 µs/tick | 1.45 µs/tick | 1.50 µs/tick | 1.5% |
| sequence | 6.21 µs/tick | 6.22 µs/tick | 6.27 µs/tick | 6.30 µs/tick | 0.5% |
| sequence_star | 6.26 µs/tick | 6.27 µs/tick | 6.32 µs/tick | 6.34 µs/tick | 0.5% |
| sequence_reactive | 6.00 µs/tick | 6.01 µs/tick | 6.06 µs/tick | 6.09 µs/tick | 0.5% |
| sequence_random | 7.00 µs/tick | 7.00 µs/tick | 7.08 µs/tick | 7.14 µs/tick | 0.7% |
| selector | 8.62 µs/tick | 8.63 µs/tick | 8.74 µs/tick | 8.84 µs/tick | 0.7% |
| selector_reactive | 8.30 µs/tick | 8.31 µs/tick | 8.34 µs/tick | 8.45 µs/tick | 0.5% |
| selector_random | 9.21 µs/tick | 9.22 µs/tick | 9.24 µs/tick | 9.60 µs/tick | 1.0% |
| simple_parallel | 2.71 µs/tick | 2.71 µs/tick | 2.73 µs/tick | 2.74 µs/tick | 0.4% |
| inverter | 2.64 µs/tick | 2.66 µs/tick | 2.68 µs/tick | 3.06 µs/tick | 3.5% |
| succeeder | 2.54 µs/tick | 2.56 µs/tick | 2.74 µs/tick | 2.94 µs/tick | 3.5% |
| failer | 2.56 µs/tick | 2.56 µs/tick | 2.58 µs/tick | 2.59 µs/tick | 0.6% |
| repeater | 2.46 µs/tick | 2.46 µs/tick | 2.48 µs/tick | 2.48 µs/tick | 0.5% |
| until_fail | 2.54 µs/tick | 2.55 µs/tick | 2.56 µs/tick | 2.81 µs/tick | 2.8% |
| limiter | 4.01 µs/tick | 4.03 µs/tick | 4.13 µs/tick | 4.21 µs/tick | 1.1% |
| cooldown | 3.35 µs/tick | 3.35 µs/tick | 3.37 µs/tick | 3.40 µs/tick | 0.5% |
| delayer | 3.25 µs/tick | 3.26 µs/tick | 3.27 µs/tick | 3.51 µs/tick | 2.1% |
| time_limiter | 3.65 µs/tick | 3.64 µs/tick | 3.66 µs/tick | 3.69 µs/tick | 0.4% |
