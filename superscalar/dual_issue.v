
`timescale 1ns/1ps

module dual_issue #(
    parameter N = 8,
    parameter WIDTH = 2
)(
    input clk,
    input reset,
    output reg done,
    output reg [31:0] cycles,
    output reg [31:0] instructions_issued,
    output reg [31:0] dependency_stalls
);

    // Instruction dependency metadata.
    // Each instruction has up to two source registers
    // and one destination register.

    reg [4:0] rs1 [0:N-1];
    reg [4:0] rs2 [0:N-1];
    reg [4:0] rd  [0:N-1];

    reg uses_rs1 [0:N-1];
    reg uses_rs2 [0:N-1];
    reg writes_rd [0:N-1];

    integer ready_cycle [0:31];
    integer pc_index;
    integer i;
    integer slot;
    integer issued_now;
    reg can_issue;

    // Program metadata is supplied by testbench.

    always @(posedge clk) begin
        if (reset) begin
            done <= 0;
            cycles <= 0;
            instructions_issued <= 0;
            dependency_stalls <= 0;
            pc_index = 0;

            for (i = 0; i < 32; i = i + 1)
                ready_cycle[i] = 0;
        end
        else if (!done) begin
            issued_now = 0;
            can_issue = 1;

            // In-order issue, maximum WIDTH per cycle.
            for (slot = 0; slot < WIDTH; slot = slot + 1) begin
                if (pc_index < N && can_issue) begin

                    if (uses_rs1[pc_index] &&
                        rs1[pc_index] != 0 &&
                        ready_cycle[rs1[pc_index]] > cycles)
                        can_issue = 0;

                    if (uses_rs2[pc_index] &&
                        rs2[pc_index] != 0 &&
                        ready_cycle[rs2[pc_index]] > cycles)
                        can_issue = 0;

                    if (can_issue) begin
                        $display(
                            "Cycle %0d Slot %0d: instruction %0d",
                            cycles + 1, slot, pc_index
                        );

                        if (writes_rd[pc_index] &&
                            rd[pc_index] != 0)
                            ready_cycle[rd[pc_index]] = cycles + 1;

                        pc_index = pc_index + 1;
                        issued_now = issued_now + 1;
                    end
                end
            end

            if (issued_now == 0 && pc_index < N)
                dependency_stalls <= dependency_stalls + 1;

            instructions_issued <=
                instructions_issued + issued_now;

            cycles <= cycles + 1;

            if (pc_index == N)
                done <= 1;
        end
    end

endmodule
