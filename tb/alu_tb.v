`timescale 1ns/1ps

module alu_tb;

reg [31:0] a, b;
reg [2:0] alu_op;
wire [31:0] result;

integer failures = 0;

alu dut (
    .a(a),
    .b(b),
    .alu_op(alu_op),
    .result(result)
);

task check;
    input [31:0] expected;
    begin
        #10;
        if (result !== expected) begin
            $display("FAIL: op=%b result=%d expected=%d",
                     alu_op, result, expected);
            failures = failures + 1;
        end else begin
            $display("PASS: op=%b result=%d", alu_op, result);
        end
    end
endtask

initial begin
    $dumpfile("results/alu.vcd");
    $dumpvars(0, alu_tb);

    a = 10; b = 5;

    alu_op = 3'b000; check(15);
    alu_op = 3'b001; check(5);
    alu_op = 3'b010; check(0);
    alu_op = 3'b011; check(15);
    alu_op = 3'b100; check(15);
    alu_op = 3'b101; check(0);

    a = 3; b = 8;
    alu_op = 3'b101; check(1);

    if (failures == 0)
        $display("ALL ALU TESTS PASSED");
    else
        $fatal(1, "%0d ALU tests failed", failures);

    $finish;
end

endmodule
