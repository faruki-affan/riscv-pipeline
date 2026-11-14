`timescale 1ns/1ps

module hazard_tb;

reg id_ex_memread;
reg [4:0] id_ex_rd;
reg [31:0] if_id_instruction;

wire stall;
integer failures = 0;

hazard_detection dut (
    .id_ex_memread(id_ex_memread),
    .id_ex_rd(id_ex_rd),
    .if_id_instruction(if_id_instruction),
    .stall(stall)
);

task check;
    input expected;
    begin
        #10;
        if (stall !== expected) begin
            $display("FAIL: stall=%b expected=%b",
                     stall, expected);
            failures = failures + 1;
        end else
            $display("PASS: stall=%b", stall);
    end
endtask

initial begin
    $dumpfile("results/hazard.vcd");
    $dumpvars(0, hazard_tb);

    // LW x5 followed by ADD using x5
    id_ex_memread = 1;
    id_ex_rd = 5;
    if_id_instruction = 32'h00228333;
    check(1);

    // No dependency
    id_ex_rd = 7;
    check(0);

    // Previous instruction is not a load
    id_ex_memread = 0;
    id_ex_rd = 5;
    check(0);

    // Dependency through rs2
    id_ex_memread = 1;
    if_id_instruction = 32'h00510333;
    check(1);

    // x0 must not trigger a stall
    id_ex_rd = 0;
    check(0);

    // ADDI x6, x5, 5: dependency through rs1
    id_ex_rd = 5;
    if_id_instruction = 32'h00528313;
    check(1);

    // ADDI x6, x2, 5: no dependency
    if_id_instruction = 32'h00510313;
    check(0);

    if (failures == 0)
        $display("ALL HAZARD DETECTION TESTS PASSED");
    else
        $fatal(1, "%0d hazard tests failed", failures);

    $finish;
end

endmodule
