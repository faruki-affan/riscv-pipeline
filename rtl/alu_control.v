module alu_control(
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [2:0] alu_sel
);

always @(*) begin
    alu_sel = 3'b000;

    case (alu_op)
        2'b00: alu_sel = 3'b000; // ADD
        2'b01: alu_sel = 3'b001; // SUB for BEQ

        2'b10: begin
            case (funct3)
                3'b000:
                    alu_sel = (funct7 == 7'b0100000)
                              ? 3'b001 : 3'b000;
                3'b111: alu_sel = 3'b010; // AND
                3'b110: alu_sel = 3'b011; // OR
                3'b100: alu_sel = 3'b100; // XOR
                3'b010: alu_sel = 3'b101; // SLT
                default: alu_sel = 3'b000;
            endcase
        end
    endcase
end

endmodule
