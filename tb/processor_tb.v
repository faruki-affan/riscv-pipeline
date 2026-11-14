
`timescale 1ns/1ps

module processor_tb;

reg clk = 0;
reg reset = 1;

integer failures = 0;

always #5 clk = ~clk;

riscv_core dut(
    .clk(clk),
    .reset(reset)
);

initial begin
    $dumpfile("results/processor.vcd");
    $dumpvars(0, processor_tb);

    // Initialize unused registers to zero
    for (integer i = 0; i < 32; i = i + 1)
        dut.regfile.registers[i] = 0;

    #20;
    reset = 0;

    // Allow instructions to traverse the pipeline
    repeat (20) @(negedge clk);

    if (dut.regfile.registers[1] !== 10) begin
        $display("FAIL x1");
        failures = failures + 1;
    end

    if (dut.regfile.registers[2] !== 5) begin
        $display("FAIL x2");
        failures = failures + 1;
    end

    if (dut.regfile.registers[3] !== 15) begin
        $display("FAIL x3");
        failures = failures + 1;
    end

    if (dut.regfile.registers[4] !== 10) begin
        $display("FAIL x4");
        failures = failures + 1;
    end

    if (dut.dmem.memory[0] !== 15) begin
        $display("FAIL memory[0]");
        failures = failures + 1;
    end

    if (dut.regfile.registers[5] !== 15) begin
        $display("FAIL x5");
        failures = failures + 1;
    end

    if (dut.regfile.registers[6] !== 16) begin
        $display("FAIL x6");
        failures = failures + 1;
    end

    if (failures == 0)
        $display("ALL PROCESSOR TESTS PASSED");
    else
        $fatal(1, "%0d PROCESSOR TESTS FAILED", failures);

    $finish;
end

endmodule
