`timescale 1ns/1ps

module data_memory_tb;

reg clk = 0;
reg mem_read = 0;
reg mem_write = 0;
reg [31:0] address = 0;
reg [31:0] write_data = 0;

wire [31:0] read_data;
integer failures = 0;

data_memory dut (
    .clk(clk),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)
);

always #5 clk = ~clk;

task check;
    input [31:0] expected;
    begin
        #1;
        if (read_data !== expected) begin
            $display("FAIL: got=%d expected=%d",
                     read_data, expected);
            failures = failures + 1;
        end else begin
            $display("PASS: read_data=%d", read_data);
        end
    end
endtask

initial begin
    $dumpfile("results/data_memory.vcd");
    $dumpvars(0, data_memory_tb);

    // Write 100 at byte address 0
    @(negedge clk);
    address = 0;
    write_data = 100;
    mem_write = 1;

    @(negedge clk);
    mem_write = 0;
    mem_read = 1;
    check(100);

    // Write 200 at byte address 4
    @(negedge clk);
    mem_read = 0;
    address = 4;
    write_data = 200;
    mem_write = 1;

    @(negedge clk);
    mem_write = 0;
    mem_read = 1;
    check(200);

    // Read address 0 again
    @(negedge clk);
    address = 0;
    check(100);

    // Disable reading
    mem_read = 0;
    check(0);

    if (failures == 0)
        $display("ALL DATA MEMORY TESTS PASSED");
    else
        $fatal(1, "%0d tests failed", failures);

    $finish;
end

endmodule
