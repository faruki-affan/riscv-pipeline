# 5-Stage Pipelined RISC-V Processor with Superscalar Performance Analysis

An educational Verilog RTL project that simulates a five-stage RISC-V processor datapath and separately evaluates **single-issue versus dual-issue instruction scheduling** under different dependency patterns.

> **Scope:** The five-stage processor and the configurable dual-issue scheduler are separate simulations. This project does **not** implement a fully integrated dual-issue CPU or claim complete RISC-V ISA compliance.

## Overview

The five pipeline stages are:

1. **IF** — Instruction fetch
2. **ID** — Instruction decode and register reads
3. **EX** — ALU execution and branch evaluation
4. **MEM** — Data memory access
5. **WB** — Register writeback

The RTL/test environment covers ALU operations, register file, instruction decoding, immediate generation, instruction and data memories, pipeline registers, forwarding, load-use hazard detection, and branch handling.

A separate issue scheduler evaluates whether up to two instructions can be issued per cycle based on simplified register-dependency metadata.

## Tools

- Verilog HDL
- Icarus Verilog (`iverilog`, `vvp`)
- GTKWave and VCD waveform files
- Ubuntu/Linux
- Python and Matplotlib (for performance plots)

## Results

Results from the documented eight-instruction issue-scheduling experiments:

| Workload | Single-issue cycles | Dual-issue cycles | Single IPC | Dual IPC | Speedup |
|---|---:|---:|---:|---:|---:|
| Independent | 8 | 4 | 1.00 | 2.00 | 2.00× |
| Dependency-heavy | 8 | 8 | 1.00 | 1.00 | 1.00× |
| Mixed (tested pattern) | 8 | 4 | 1.00 | 2.00 | 2.00× |

**Interpretation:** Wider issue improves throughput only when enough independent instructions can be paired. IPC and CPI here measure **scheduler issue behavior**, not full processor retirement or end-to-end program execution. The mixed result depends on the specific test pattern.

## Verification

The report describes component-level Verilog testbenches, integrated processor tests, branch tests, and issue-scheduler simulations. Reported testbench outputs include `ALL PROCESSOR TESTS PASSED`, `ALL BRANCH TESTS PASSED`, and issue-scheduling test passes. These results are limited to the provided test cases.

## Running the simulations

From the project directory, the report documents running already-compiled simulation binaries:

```bash
vvp results/processor_sim
vvp results/branch_sim
vvp results/dual_issue_sim
vvp results/comparison_sim
vvp results/dependency_sim
```

To inspect a generated waveform:

```bash
gtkwave results/dependency.vcd
```

To regenerate performance plots, if the script exists in the repository:

```bash
python3 scripts/performance_graphs.py
```

**Before publishing:** Add a reproducible `run.sh` or `Makefile` with the `iverilog` compilation commands for each testbench. The commands above require simulation binaries to have already been generated.

## Limitations and future work

- The dual-issue scheduler is separate from the five-stage processor datapath.
- Verification covers the included test programs, not the full RISC-V ISA.
- No out-of-order execution, register renaming, reorder buffer, or realistic cache hierarchy is modeled.
- Future improvements: integrated second issue lane, latency-aware hazard handling, broader RV32I tests, and automated regression testing.

## Documentation

See the accompanying project report for the architecture diagrams, GTKWave screenshots, testbench observations, and performance plots. Add the report only if you have permission to publish it.
