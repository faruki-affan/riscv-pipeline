
module instruction_memory(
    input [31:0] address,
    output [31:0] instruction
);

reg [31:0] memory [0:255];

integer i;

initial begin
    // Initialize all memory locations with NOP
    for (i = 0; i < 256; i = i + 1)
        memory[i] = 32'h00000013;

    // Load RISC-V test program
    $readmemh("programs/test_program.hex", memory);
end

assign instruction = memory[address[9:2]];

endmodule
