
`timescale 1ns/1ps

module dependency_tb;

reg clk = 0;
reg reset = 1;

wire done_single, done_dual;
wire [31:0] cycles_single, cycles_dual;
wire [31:0] issued_single, issued_dual;
wire [31:0] stalls_single, stalls_dual;

integer i;
integer test_number;
integer failures = 0;

always #5 clk = ~clk;

dual_issue #(.N(8), .WIDTH(1)) single_core (
    .clk(clk),
    .reset(reset),
    .done(done_single),
    .cycles(cycles_single),
    .instructions_issued(issued_single),
    .dependency_stalls(stalls_single)
);

dual_issue #(.N(8), .WIDTH(2)) dual_core (
    .clk(clk),
    .reset(reset),
    .done(done_dual),
    .cycles(cycles_dual),
    .instructions_issued(issued_dual),
    .dependency_stalls(stalls_dual)
);

// Configure the same instruction for both schedulers
task set_instruction;
    input integer idx;
    input [4:0] source1;
    input [4:0] source2;
    input [4:0] destination;
    input use1;
    input use2;
    begin
        single_core.rs1[idx] = source1;
        single_core.rs2[idx] = source2;
        single_core.rd[idx] = destination;
        single_core.uses_rs1[idx] = use1;
        single_core.uses_rs2[idx] = use2;
        single_core.writes_rd[idx] = 1;

        dual_core.rs1[idx] = source1;
        dual_core.rs2[idx] = source2;
        dual_core.rd[idx] = destination;
        dual_core.uses_rs1[idx] = use1;
        dual_core.uses_rs2[idx] = use2;
        dual_core.writes_rd[idx] = 1;
    end
endtask

task configure_workload;
    input integer workload;
    begin
        for (i = 0; i < 8; i = i + 1)
            set_instruction(i, 0, 0, i+1, 0, 0);

        if (workload == 1) begin
            // Full dependency chain
            for (i = 1; i < 8; i = i + 1)
                set_instruction(i, i, 0, i+1, 1, 0);
        end

        if (workload == 2) begin
            // Independent pairs followed by dependent pairs
            set_instruction(2, 1, 2, 3, 1, 1);
            set_instruction(4, 3, 4, 5, 1, 1);
            set_instruction(6, 5, 6, 7, 1, 1);
        end
    end
endtask

task run_workload;
    input integer workload;
    begin
        reset = 1;
        configure_workload(workload);

        repeat (2) @(negedge clk);
        reset = 0;

        wait(done_single && done_dual);
        #1;

        $display("--------------------------------");
        case (workload)
            0: $display("INDEPENDENT WORKLOAD");
            1: $display("DEPENDENCY-HEAVY WORKLOAD");
            2: $display("MIXED WORKLOAD");
        endcase

        $display("Single cycles = %0d", cycles_single);
        $display("Dual cycles   = %0d", cycles_dual);
        $display("Single IPC    = %f",
            $itor(issued_single)/$itor(cycles_single));
        $display("Dual IPC      = %f",
            $itor(issued_dual)/$itor(cycles_dual));
        $display("Speedup       = %f",
            $itor(cycles_single)/$itor(cycles_dual));
        $display("Single stalls = %0d", stalls_single);
        $display("Dual stalls   = %0d", stalls_dual);

        if (issued_single !== 8 || issued_dual !== 8) begin
            failures = failures + 1;
            $display("FAIL: incorrect instruction count");
        end

        // Advance to a falling edge before changing reset
        @(negedge clk);
        reset = 1;
        @(negedge clk);
    end
endtask

initial begin
    $dumpfile("results/dependency.vcd");
    $dumpvars(0, dependency_tb);

    run_workload(0);
    run_workload(1);
    run_workload(2);

    if (failures == 0)
        $display("ALL DEPENDENCY TESTS PASSED");
    else
        $fatal(1, "%0d DEPENDENCY TESTS FAILED", failures);

    $finish;
end

initial begin
    #2000;
    $fatal(1, "Simulation timeout");
end

endmodule
