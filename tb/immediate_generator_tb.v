`timescale 1ns/1ps

module immediate_generator_tb;

reg [31:0] instruction;
wire [31:0] immediate;

integer failures = 0;

immediate_generator dut (
    .instruction(instruction),
    .immediate(immediate)
);

task check;
    input [31:0] inst;
    input [31:0] expected;
    begin
        instruction = inst;
        #10;

        if (immediate !== expected) begin
            $display("FAIL inst=%h got=%h expected=%h",
                     inst, immediate, expected);
            failures = failures + 1;
        end else begin
            $display("PASS inst=%h immediate=%0d",
                     inst, $signed(immediate));
        end
    end
endtask

initial begin
    $dumpfile("results/immediate_generator.vcd");
    $dumpvars(0, immediate_generator_tb);

    // ADDI x1, x0, 10
    check(32'h00A00093, 32'd10);

    // ADDI x1, x0, -5
    check(32'hFFB00093, -32'sd5);

    // LW x2, 8(x1)
    check(32'h0080A103, 32'd8);

    // SW x2, 12(x1)
    check(32'h0020A623, 32'd12);

    // BEQ x1, x2, +8
    check(32'h00208463, 32'd8);

    // Unsupported opcode
    check(32'h0000007F, 32'd0);

    if (failures == 0)
        $display("ALL IMMEDIATE GENERATOR TESTS PASSED");
    else
        $fatal(1, "%0d tests failed", failures);

    $finish;
end

endmodule
