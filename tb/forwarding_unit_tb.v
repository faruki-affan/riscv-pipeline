`timescale 1ns/1ps

module forwarding_unit_tb;

reg [4:0] id_ex_rs1, id_ex_rs2;
reg [4:0] ex_mem_rd, mem_wb_rd;
reg ex_mem_regwrite, mem_wb_regwrite;

wire [1:0] forward_a, forward_b;

integer failures = 0;

forwarding_unit dut (
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_rd(ex_mem_rd),
    .mem_wb_rd(mem_wb_rd),
    .ex_mem_regwrite(ex_mem_regwrite),
    .mem_wb_regwrite(mem_wb_regwrite),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

task check;
    input [1:0] expected_a, expected_b;
    begin
        #10;
        if (forward_a !== expected_a ||
            forward_b !== expected_b) begin
            $display("FAIL: A=%b B=%b expected A=%b B=%b",
                forward_a, forward_b,
                expected_a, expected_b);
            failures = failures + 1;
        end else
            $display("PASS: A=%b B=%b",
                forward_a, forward_b);
    end
endtask

initial begin
    $dumpfile("results/forwarding_unit.vcd");
    $dumpvars(0, forwarding_unit_tb);

    // No forwarding
    id_ex_rs1 = 1;
    id_ex_rs2 = 2;
    ex_mem_rd = 3;
    mem_wb_rd = 4;
    ex_mem_regwrite = 0;
    mem_wb_regwrite = 0;
    check(2'b00, 2'b00);

    // Forward operand A from EX/MEM
    ex_mem_rd = 1;
    ex_mem_regwrite = 1;
    check(2'b10, 2'b00);

    // Forward operand B from MEM/WB
    ex_mem_regwrite = 0;
    mem_wb_rd = 2;
    mem_wb_regwrite = 1;
    check(2'b00, 2'b01);

    // Both operands forwarded
    ex_mem_rd = 1;
    ex_mem_regwrite = 1;
    check(2'b10, 2'b01);

    // EX/MEM must take priority
    mem_wb_rd = 1;
    check(2'b10, 2'b00);

    // x0 must never be forwarded
    id_ex_rs1 = 0;
    id_ex_rs2 = 0;
    ex_mem_rd = 0;
    mem_wb_rd = 0;
    check(2'b00, 2'b00);

    if (failures == 0)
        $display("ALL FORWARDING TESTS PASSED");
    else
        $fatal(1, "%0d forwarding tests failed", failures);

    $finish;
end

endmodule
