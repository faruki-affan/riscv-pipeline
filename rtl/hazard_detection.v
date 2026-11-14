module hazard_detection(
    input id_ex_memread,
    input [4:0] id_ex_rd,
    input [31:0] if_id_instruction,
    output reg stall
);

wire [6:0] opcode = if_id_instruction[6:0];
wire [4:0] rs1 = if_id_instruction[19:15];
wire [4:0] rs2 = if_id_instruction[24:20];

reg uses_rs1, uses_rs2;

always @(*) begin
    uses_rs1 = 0;
    uses_rs2 = 0;

    case (opcode)
        7'b0110011: begin // R-type
            uses_rs1 = 1;
            uses_rs2 = 1;
        end

        7'b0010011, // I-type
        7'b0000011: begin // LW
            uses_rs1 = 1;
        end

        7'b0100011, // SW
        7'b1100011: begin // BEQ
            uses_rs1 = 1;
            uses_rs2 = 1;
        end
    endcase

    stall = id_ex_memread &&
            (id_ex_rd != 0) &&
            ((uses_rs1 && id_ex_rd == rs1) ||
             (uses_rs2 && id_ex_rd == rs2));
end

endmodule
