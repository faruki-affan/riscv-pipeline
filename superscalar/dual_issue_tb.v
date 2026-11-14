`timescale 1ns/1ps


module dual_issue_tb;

reg clk = 0;
reg reset = 1;

wire done;
wire [31:0] cycles;
wire [31:0] instructions_issued;
wire [31:0] dependency_stalls;

integer i;

always #5 clk = ~clk;

dual_issue #(
.N(8),
.WIDTH(2)
) dut (
.clk(clk),
.reset(reset),
.done(done),
.cycles(cycles),
.instructions_issued(instructions_issued),
.dependency_stalls(dependency_stalls)
);

initial begin
$dumpfile("results/dual_issue.vcd");
$dumpvars(0, dual_issue_tb);

// Default: no source/destination usage
for (i = 0; i < 8; i = i + 1) begin
dut.rs1[i] = 0;
dut.rs2[i] = 0;
dut.rd[i] = 0;
dut.uses_rs1[i] = 0;
dut.uses_rs2[i] = 0;
dut.writes_rd[i] = 0;
end

// Instruction 0: ADDI x1, x0, 10
    dut.rd[0] = 1;
    dut.writes_rd[0] = 1;

// Instruction 1: ADDI x2, x0, 20
    dut.rd[1] = 2;
    dut.writes_rd[1] = 1;

// Instruction 2: ADD x3, x1, x2
    dut.rs1[2] = 1;
    dut.rs2[2] = 2;
    dut.rd[2] = 3;
    dut.uses_rs1[2] = 1;
    dut.uses_rs2[2] = 1;
    dut.writes_rd[2] = 1;

// Instruction 3: ADDI x4, x0, 5
    dut.rd[3] = 4;
    dut.writes_rd[3] = 1;

// Instruction 4: ADD x5, x3, x4
    dut.rs1[4] = 3;
    dut.rs2[4] = 4;
    dut.rd[4] = 5;
    dut.uses_rs1[4] = 1;
    dut.uses_rs2[4] = 1;
    dut.writes_rd[4] = 1;

// Instruction 5: ADDI x6, x0, 7
    dut.rd[5] = 6;
    dut.writes_rd[5] = 1;

// Instruction 6: ADD x7, x5, x6
    dut.rs1[6] = 5;
    dut.rs2[6] = 6;
    dut.rd[6] = 7;
    dut.uses_rs1[6] = 1;
    dut.uses_rs2[6] = 1;
    dut.writes_rd[6] = 1;

// Instruction 7: ADDI x8, x0, 9
    dut.rd[7] = 8;
    dut.writes_rd[7] = 1;

repeat (2) @(negedge clk);
    reset = 0;

wait(done == 1);
    #1;

$display("==============================");
    $display("DUAL ISSUE RESULTS");
    $display("==============================");
    $display("Instructions = %0d", instructions_issued);
    $display("Cycles = %0d", cycles);
    $display("Dependency stall cycles = %0d",
             dependency_stalls);
    $display("IPC = %f",
             $itor(instructions_issued) / $itor(cycles));
    $display("CPI = %f",
             $itor(cycles) / $itor(instructions_issued));

if (instructions_issued !== 8 ||
        cycles !== 4 ||
        dependency_stalls !== 0)
        $fatal(1, "DUAL ISSUE TEST FAILED");

    $display("DUAL ISSUE TEST PASSED");

$finish;
end

endmodule
