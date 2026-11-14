
`timescale 1ns/1ps

module comparison_tb;

reg clk = 0;
reg reset = 1;

wire done_single, done_dual;
wire [31:0] cycles_single, cycles_dual;
wire [31:0] issued_single, issued_dual;
wire [31:0] stalls_single, stalls_dual;

integer i;

always #5 clk = ~clk;

dual_issue #(.N(8), .WIDTH(1)) single_core (
    .clk(clk), .reset(reset),
    .done(done_single),
    .cycles(cycles_single),
    .instructions_issued(issued_single),
    .dependency_stalls(stalls_single)
);

dual_issue #(.N(8), .WIDTH(2)) dual_core (
    .clk(clk), .reset(reset),
    .done(done_dual),
    .cycles(cycles_dual),
    .instructions_issued(issued_dual),
    .dependency_stalls(stalls_dual)
);

initial begin
    $dumpfile("results/comparison.vcd");
    $dumpvars(0, comparison_tb);

    // Identical eight-instruction workload
    for (i = 0; i < 8; i = i + 1) begin
        single_core.rs1[i] = 0;
        single_core.rs2[i] = 0;
        single_core.rd[i] = 0;
        single_core.uses_rs1[i] = 0;
        single_core.uses_rs2[i] = 0;
        single_core.writes_rd[i] = 0;

        dual_core.rs1[i] = 0;
        dual_core.rs2[i] = 0;
        dual_core.rd[i] = 0;
        dual_core.uses_rs1[i] = 0;
        dual_core.uses_rs2[i] = 0;
        dual_core.writes_rd[i] = 0;
    end

    // Independent instructions for baseline comparison
    for (i = 0; i < 8; i = i + 1) begin
        single_core.rd[i] = i + 1;
        dual_core.rd[i] = i + 1;
        single_core.writes_rd[i] = 1;
        dual_core.writes_rd[i] = 1;
    end

    repeat (2) @(negedge clk);
    reset = 0;

    wait(done_single && done_dual);
    #1;

    $display("\n================================");
    $display("PERFORMANCE COMPARISON");
    $display("================================");
    $display("Single issue cycles = %0d", cycles_single);
    $display("Dual issue cycles   = %0d", cycles_dual);

    $display("Single IPC = %f",
        $itor(issued_single) / $itor(cycles_single));

    $display("Dual IPC   = %f",
        $itor(issued_dual) / $itor(cycles_dual));

    $display("Speedup    = %f",
        $itor(cycles_single) / $itor(cycles_dual));

    if (cycles_single !== 8 ||
        cycles_dual !== 4 ||
        issued_single !== 8 ||
        issued_dual !== 8)
        $fatal(1, "COMPARISON FAILED");

    $display("COMPARISON TEST PASSED");
    $finish;
end

initial begin
    #1000;
    $fatal(1, "Simulation timeout");
end

endmodule
