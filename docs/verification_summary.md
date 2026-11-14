
# RISC-V Pipeline and Superscalar Simulation

## Objective
Design and simulate a five-stage pipelined RISC-V
processor and analyze instruction issue performance
using single-issue and dual-issue schedulers.

## Tools
- Verilog
- Icarus Verilog
- GTKWave
- Python / Matplotlib

## Processor Components
- Arithmetic Logic Unit
- Register File
- Control Unit
- Immediate Generator
- Instruction and Data Memory
- Pipeline Registers
- Forwarding Unit
- Hazard Detection Unit

## Verified Simulations
- ALU operations
- Register file operations
- Control signal generation
- Immediate generation
- Data memory
- Forwarding
- Hazard detection
- Pipeline registers
- Processor test program
- Branch handling
- Dual-issue scheduling
- Dependency workload comparison

## Performance Results

| Workload | Single IPC | Dual IPC | Speedup |
|---|---:|---:|---:|
| Independent | 1.0 | 2.0 | 2.0x |
| Dependency-heavy | 1.0 | 1.0 | 1.0x |
| Mixed | 1.0 | 2.0 | 2.0x |

## Conclusion
Dual-issue scheduling improves issue throughput
when independent instructions are available.

Register dependencies limit instruction-level
parallelism and reduce potential speedup.

## Limitations
- Superscalar scheduler is separate from the core.
- Issue IPC is not full processor retirement IPC.
- Simplified instruction dependency timing.
- No physical FPGA validation.
- No complete cache or memory hierarchy model.
