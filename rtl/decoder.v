
module decoder(
    input [31:0] instruction,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg ALUSrc,
    output reg Branch,
    output reg [2:0] ALUOp
);

wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];
wire [6:0] funct7 = instruction[31:25];

always @(*) begin
    RegWrite = 0;
    MemRead = 0;
    MemWrite = 0;
    MemToReg = 0;
    ALUSrc = 0;
    Branch = 0;
    ALUOp = 3'b000;

    case (opcode)

        // R-Type: ADD, SUB, AND, OR, XOR
        7'b0110011: begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0000000) begin
                        RegWrite = 1;
                        ALUOp = 3'b000; // ADD
                    end
                    else if (funct7 == 7'b0100000) begin
                        RegWrite = 1;
                        ALUOp = 3'b001; // SUB
                    end
                end
                3'b111: begin
                    if (funct7 == 7'b0000000) begin
                        RegWrite = 1;
                        ALUOp = 3'b010; // AND
                    end
                end
                3'b110: begin
                    if (funct7 == 7'b0000000) begin
                        RegWrite = 1;
                        ALUOp = 3'b011; // OR
                    end
                end
                3'b100: begin
                    if (funct7 == 7'b0000000) begin
                        RegWrite = 1;
                        ALUOp = 3'b100; // XOR
                    end
                end
                default: ;
            endcase
        end

        // ADDI
        7'b0010011: begin
            if (funct3 == 3'b000) begin
                RegWrite = 1;
                ALUSrc = 1;
                ALUOp = 3'b000;
            end
        end

        // LW
        7'b0000011: begin
            if (funct3 == 3'b010) begin
                RegWrite = 1;
                MemRead = 1;
                MemToReg = 1;
                ALUSrc = 1;
                ALUOp = 3'b000;
            end
        end

        // SW
        7'b0100011: begin
            if (funct3 == 3'b010) begin
                MemWrite = 1;
                ALUSrc = 1;
                ALUOp = 3'b000;
            end
        end

        // BEQ
        7'b1100011: begin
            if (funct3 == 3'b000) begin
                Branch = 1;
                ALUOp = 3'b001; // SUB
            end
        end

        default: ;
    endcase
end

endmodule
