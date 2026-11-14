`timescale 1ns/1ps

module register_file_tb;

reg clk = 0;
reg reg_write = 0;
reg [4:0] rs1 = 0, rs2 = 0, rd = 0;
reg [31:0] write_data = 0;

wire [31:0] read_data1, read_data2;

integer failures = 0;

register_file dut (
    .clk(clk),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

always #5 clk = ~clk;

task check;
    input [31:0] expected1, expected2;
    begin
        #1;
        if (read_data1 !== expected1 ||
            read_data2 !== expected2) begin
            $display("FAIL: read1=%d read2=%d",
                     read_data1, read_data2);
            failures = failures + 1;
        end else begin
            $display("PASS: read1=%d read2=%d",
                     read_data1, read_data2);
        end
    end
endtask

initial begin
    $dumpfile("results/register_file.vcd");
    $dumpvars(0, register_file_tb);

    // Write 100 to register x1
    @(negedge clk);
    reg_write = 1;
    rd = 1;
    write_data = 100;

    @(negedge clk);
    reg_write = 0;
    rs1 = 1;
    rs2 = 0;
    check(100, 0);

    // Write 200 to register x2
    @(negedge clk);
    reg_write = 1;
    rd = 2;
    write_data = 200;

    @(negedge clk);
    reg_write = 0;
    rs1 = 1;
    rs2 = 2;
    check(100, 200);

    // Attempt to write to x0 (must remain zero)
    @(negedge clk);
    reg_write = 1;
    rd = 0;
    write_data = 999;

    @(negedge clk);
    reg_write = 0;
    rs1 = 0;
    rs2 = 2;
    check(0, 200);

    if (failures == 0)
        $display("ALL REGISTER FILE TESTS PASSED");
    else
        $fatal(1, "%0d tests failed", failures);

    $finish;
end

endmodule
