
module riscv_core(
    input clk,
    input reset
);

// ===============================
// 1. INSTRUCTION FETCH
// ===============================

reg [31:0] pc;
wire [31:0] instruction;

instruction_memory imem(
    .address(pc),
    .instruction(instruction)
);

wire [31:0] if_id_pc;
wire [31:0] if_id_instruction;
wire stall;
wire branch_taken;
wire [31:0] branch_target;

always @(posedge clk) begin
    if (reset)
        pc <= 0;
    else if (branch_taken)
        pc <= branch_target;
    else if (!stall)
        pc <= pc + 4;
end

if_id_register ifid(
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .flush(branch_taken),
    .pc_in(pc),
    .instruction_in(instruction),
    .pc_out(if_id_pc),
    .instruction_out(if_id_instruction)
);

// ===============================
// 2. INSTRUCTION DECODE
// ===============================

wire [6:0] opcode = if_id_instruction[6:0];
wire [4:0] rs1 = if_id_instruction[19:15];
wire [4:0] rs2 = if_id_instruction[24:20];
wire [4:0] rd  = if_id_instruction[11:7];

wire reg_write, mem_read, mem_write;
wire mem_to_reg, alu_src, branch;
wire [1:0] alu_op;

control_unit ctrl(
    .opcode(opcode),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .alu_src(alu_src),
    .branch(branch),
    .alu_op(alu_op)
);

wire [31:0] immediate;

immediate_generator immgen(
    .instruction(if_id_instruction),
    .immediate(immediate)
);

wire [2:0] alu_sel;

alu_control aluctrl(
    .alu_op(alu_op),
    .funct3(if_id_instruction[14:12]),
    .funct7(if_id_instruction[31:25]),
    .alu_sel(alu_sel)
);

wire [31:0] read_data1, read_data2;
wire [31:0] wb_data;
wire [4:0] mem_wb_rd;
wire mem_wb_regwrite;

register_file regfile(
    .clk(clk),
    .reg_write(mem_wb_regwrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(mem_wb_rd),
    .write_data(wb_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// ===============================
// 3. ID/EX PIPELINE REGISTER
// ===============================

wire [31:0] id_ex_pc;
wire [31:0] id_ex_rs1_data;
wire [31:0] id_ex_rs2_data;
wire [31:0] id_ex_immediate;
wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
wire [2:0] id_ex_alu_sel;
wire id_ex_regwrite, id_ex_memread;
wire id_ex_memwrite, id_ex_memtoreg;
wire id_ex_alusrc, id_ex_branch;

hazard_detection hazard(
    .id_ex_memread(id_ex_memread),
    .id_ex_rd(id_ex_rd),
    .if_id_instruction(if_id_instruction),
    .stall(stall)
);

id_ex_register idex(
    .clk(clk),
    .reset(reset),
    .flush(stall || branch_taken),
    .pc_in(if_id_pc),
    .rs1_data_in(read_data1),
    .rs2_data_in(read_data2),
    .immediate_in(immediate),
    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),
    .alu_sel_in(alu_sel),
    .reg_write_in(reg_write),
    .mem_read_in(mem_read),
    .mem_write_in(mem_write),
    .mem_to_reg_in(mem_to_reg),
    .alu_src_in(alu_src),
    .branch_in(branch),
    .pc_out(id_ex_pc),
    .rs1_data_out(id_ex_rs1_data),
    .rs2_data_out(id_ex_rs2_data),
    .immediate_out(id_ex_immediate),
    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .rd_out(id_ex_rd),
    .alu_sel_out(id_ex_alu_sel),
    .reg_write_out(id_ex_regwrite),
    .mem_read_out(id_ex_memread),
    .mem_write_out(id_ex_memwrite),
    .mem_to_reg_out(id_ex_memtoreg),
    .alu_src_out(id_ex_alusrc),
    .branch_out(id_ex_branch)
);

// ===============================
// 4. EXECUTE STAGE
// ===============================

wire [31:0] ex_mem_alu_result;
wire [4:0] ex_mem_rd;
wire ex_mem_regwrite, ex_mem_memread;
wire [1:0] forward_a, forward_b;

forwarding_unit forwarding(
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_rd(ex_mem_rd),
    .mem_wb_rd(mem_wb_rd),
    .ex_mem_regwrite(ex_mem_regwrite && !ex_mem_memread),
    .mem_wb_regwrite(mem_wb_regwrite),
    .forward_a(forward_a),
    .forward_b(forward_b)
);

reg [31:0] operand_a, operand_b;

always @(*) begin
    case (forward_a)
        2'b10: operand_a = ex_mem_alu_result;
        2'b01: operand_a = wb_data;
        default: operand_a = id_ex_rs1_data;
    endcase

    case (forward_b)
        2'b10: operand_b = ex_mem_alu_result;
        2'b01: operand_b = wb_data;
        default: operand_b = id_ex_rs2_data;
    endcase
end

wire [31:0] alu_input_b =
    id_ex_alusrc ? id_ex_immediate : operand_b;

wire [31:0] alu_result;

alu alu_inst(
    .a(operand_a),
    .b(alu_input_b),
    .alu_op(id_ex_alu_sel),
    .result(alu_result)
);

assign branch_taken =
    id_ex_branch && (operand_a == operand_b);

assign branch_target =
    id_ex_pc + id_ex_immediate;

// ===============================
// 5. EX/MEM PIPELINE REGISTER
// ===============================

wire [31:0] ex_mem_write_data;
wire ex_mem_memwrite, ex_mem_memtoreg;

ex_mem_register exmem(
    .clk(clk),
    .reset(reset),
    .alu_result_in(alu_result),
    .write_data_in(operand_b),
    .rd_in(id_ex_rd),
    .reg_write_in(id_ex_regwrite),
    .mem_read_in(id_ex_memread),
    .mem_write_in(id_ex_memwrite),
    .mem_to_reg_in(id_ex_memtoreg),
    .alu_result_out(ex_mem_alu_result),
    .write_data_out(ex_mem_write_data),
    .rd_out(ex_mem_rd),
    .reg_write_out(ex_mem_regwrite),
    .mem_read_out(ex_mem_memread),
    .mem_write_out(ex_mem_memwrite),
    .mem_to_reg_out(ex_mem_memtoreg)
);

// ===============================
// 6. MEMORY STAGE
// ===============================

wire [31:0] memory_read_data;

data_memory dmem(
    .clk(clk),
    .mem_read(ex_mem_memread),
    .mem_write(ex_mem_memwrite),
    .address(ex_mem_alu_result),
    .write_data(ex_mem_write_data),
    .read_data(memory_read_data)
);

// ===============================
// 7. MEM/WB PIPELINE REGISTER
// ===============================

wire [31:0] mem_wb_alu_result;
wire [31:0] mem_wb_memory_data;
wire mem_wb_memtoreg;

mem_wb_register memwb(
    .clk(clk),
    .reset(reset),
    .alu_result_in(ex_mem_alu_result),
    .memory_data_in(memory_read_data),
    .rd_in(ex_mem_rd),
    .reg_write_in(ex_mem_regwrite),
    .mem_to_reg_in(ex_mem_memtoreg),
    .alu_result_out(mem_wb_alu_result),
    .memory_data_out(mem_wb_memory_data),
    .rd_out(mem_wb_rd),
    .reg_write_out(mem_wb_regwrite),
    .mem_to_reg_out(mem_wb_memtoreg)
);

assign wb_data =
    mem_wb_memtoreg ? mem_wb_memory_data
                    : mem_wb_alu_result;

endmodule
