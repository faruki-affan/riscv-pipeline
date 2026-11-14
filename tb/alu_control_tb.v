`timescale 1ns/1ps

module alu_control_tb;

reg [1:0] alu_op;
reg [2:0] funct3;
reg [6:0] funct7;
wire [2:0] alu_sel;

integer failures = 0;

alu_control dut (
    .alu_op(alu_op),
    .funct3(funct3),
    .funct7(funct7),
    .alu_sel(alu_sel)
);

task check;
    input [1:0] op;
    input [2:0] f3;
    input [6:0] f7;
    input [2:0] expected;
    begin
        alu_op = op;
        funct3 = f3;
        funct7 = f7;
        #10;

        if (alu_sel !== expected) begin
            $display("FAIL: expected=%b got=%b",
                     expected, alu_sel);
            failures = failures + 1;
        end else
            $display("PASS: alu_sel=%b", alu_sel);
    end
endtask

initial begin
    $dumpfile("results/alu_control.vcd");
    $dumpvars(0, alu_control_tb);

    check(2'b00, 3'b000, 7'b0000000, 3'b000); // ADD
    check(2'b01, 3'b000, 7'b0000000, 3'b001); // BEQ
    check(2'b10, 3'b000, 7'b0000000, 3'b000); // ADD
    check(2'b10, 3'b000, 7'b0100000, 3'b001); // SUB
    check(2'b10, 3'b111, 7'b0000000, 3'b010); // AND
    check(2'b10, 3'b110, 7'b0000000, 3'b011); // OR
    check(2'b10, 3'b100, 7'b0000000, 3'b100); // XOR
    check(2'b10, 3'b010, 7'b0000000, 3'b101); // SLT

    if (failures == 0)
        $display("ALL ALU CONTROL TESTS PASSED");
    else
        $fatal(1, "%0d ALU control tests failed", failures);

    $finish;
end

endmodule
