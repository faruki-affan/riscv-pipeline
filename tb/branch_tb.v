
`timescale 1ns/1ps

module branch_tb;

reg clk = 0;
reg reset = 1;

integer failures = 0;
integer branch_count = 0;
integer stall_count = 0;
integer i;

always #5 clk = ~clk;

riscv_core dut (
    .clk(clk),
    .reset(reset)
);

// Count taken branches and stalls
always @(posedge clk) begin
    if (!reset) begin
        if (dut.branch_taken === 1'b1)
            branch_count = branch_count + 1;

        if (dut.stall === 1'b1)
            stall_count = stall_count + 1;
    end
end

initial begin
    $dumpfile("results/branch.vcd");
    $dumpvars(0, branch_tb);

    // Initialize registers
    for (i = 0; i < 32; i = i + 1)
        dut.regfile.registers[i] = 0;

    // Load branch program into instruction memory
    // The core's initial block loads the original
    // test program at startup; overwrite it here.
    #1;
    for (i = 0; i < 256; i = i + 1)
        dut.imem.memory[i] = 32'h00000013;

    $readmemh("programs/branch_test.hex",
              dut.imem.memory, 0, 5);

    // Release reset on falling clock edge
    repeat (2) @(negedge clk);
    reset = 0;

    // Allow pipeline to complete
    repeat (20) @(negedge clk);

    $display("=================================");
    $display("BRANCH TEST RESULTS");
    $display("=================================");

    $display("x1 = %0d", dut.regfile.registers[1]);
    $display("x2 = %0d", dut.regfile.registers[2]);
    $display("x3 = %0d", dut.regfile.registers[3]);
    $display("x4 = %0d", dut.regfile.registers[4]);
    $display("x5 = %0d", dut.regfile.registers[5]);
    $display("Branches taken = %0d", branch_count);
    $display("Stall cycles = %0d", stall_count);

    if (dut.regfile.registers[1] !== 10)
        failures = failures + 1;

    if (dut.regfile.registers[2] !== 10)
        failures = failures + 1;

    if (dut.regfile.registers[3] !== 0)
        failures = failures + 1;

    if (dut.regfile.registers[4] !== 0)
        failures = failures + 1;

    if (dut.regfile.registers[5] !== 42)
        failures = failures + 1;

    if (branch_count !== 1)
        failures = failures + 1;

    if (failures == 0)
        $display("ALL BRANCH TESTS PASSED");
    else
        $fatal(1, "%0d BRANCH TESTS FAILED",
               failures);

    $finish;
end

endmodule
