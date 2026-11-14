`timescale 1ns/1ps

module control_unit_tb;

reg [6:0] opcode;

wire reg_write;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire alu_src;
wire branch;
wire [1:0] alu_op;

integer failures = 0;

control_unit dut (
    .opcode(opcode),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .alu_op(alu_op)
);

task check;
    input [6:0] test_opcode;
    input [7:0] expected;
    reg [7:0] actual;
    begin
        opcode = test_opcode;
        #10;

        actual = {
            reg_write,
            mem_read,
            mem_write,
            mem_to_reg,
            alu_src,
            branch,
            alu_op
        };

        if (actual !== expected) begin
            $display("FAIL opcode=%b actual=%b expected=%b",
                     opcode, actual, expected);
            failures = failures + 1;
        end else begin
            $display("PASS opcode=%b controls=%b",
                     opcode, actual);
        end
    end
endtask

initial begin
    $dumpfile("results/control_unit.vcd");
    $dumpvars(0, control_unit_tb);

    // R-type
    check(7'b0110011, 8'b10000010);

    // ADDI
    check(7'b0010011, 8'b10001000);

    // LW
    check(7'b0000011, 8'b11011000);

    // SW
    check(7'b0100011, 8'b00101000);

    // BEQ
    check(7'b1100011, 8'b00000101);

    // Unsupported opcode
    check(7'b1111111, 8'b00000000);

    if (failures == 0)
        $display("ALL CONTROL UNIT TESTS PASSED");
    else
        $fatal(1, "%0d CONTROL UNIT TESTS FAILED", failures);

    $finish;
end

endmodule
