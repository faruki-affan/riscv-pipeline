`timescale 1ns/1ps

module pipeline_registers_tb;

reg clk = 0;
reg reset = 1;
reg stall = 0;
reg flush = 0;

reg [31:0] pc_in = 0;
reg [31:0] instruction_in = 32'h00000013;

wire [31:0] pc_out;
wire [31:0] instruction_out;

integer failures = 0;

always #5 clk = ~clk;

if_id_register dut (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(flush),
    .pc_in(pc_in),
    .instruction_in(instruction_in),
    .pc_out(pc_out),
    .instruction_out(instruction_out)
);

task check;
    input [31:0] expected_pc;
    input [31:0] expected_instruction;
    begin
        #1;
        if (pc_out !== expected_pc ||
            instruction_out !== expected_instruction) begin

            $display("FAIL PC=%h INST=%h expected PC=%h INST=%h",
                pc_out, instruction_out,
                expected_pc, expected_instruction);

            failures = failures + 1;
        end
        else begin
            $display("PASS PC=%h INST=%h",
                pc_out, instruction_out);
        end
    end
endtask

initial begin
    $dumpfile("results/pipeline_registers.vcd");
    $dumpvars(0, pipeline_registers_tb);

    // Test 1: Reset
    @(negedge clk);
    check(0, 32'h00000013);

    // Test 2: Normal pipeline update
    reset = 0;
    pc_in = 32'h00000004;
    instruction_in = 32'h00A00093;

    @(negedge clk);
    check(32'h00000004, 32'h00A00093);

    // Test 3: Stall holds previous instruction
    stall = 1;
    pc_in = 32'h00000008;
    instruction_in = 32'h00508113;

    @(negedge clk);
    check(32'h00000004, 32'h00A00093);

    // Test 4: Release stall
    stall = 0;

    @(negedge clk);
    check(32'h00000008, 32'h00508113);

    // Test 5: Flush inserts NOP
    flush = 1;

    @(negedge clk);
    check(0, 32'h00000013);

    // Test 6: Normal execution resumes
    flush = 0;
    pc_in = 32'h0000000C;
    instruction_in = 32'h002081B3;

    @(negedge clk);
    check(32'h0000000C, 32'h002081B3);

    if (failures == 0)
        $display("ALL PIPELINE REGISTER TESTS PASSED");
    else
        $fatal(1, "%0d pipeline tests failed", failures);

    $finish;
end

endmodule
