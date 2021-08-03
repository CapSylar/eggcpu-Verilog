module instruction_fetch
(
    input clk,

    // control lines
    input wire stall_if_i, // stall instruction fetch
    // Instruction memory interface
    input wire [31:0] IMEM_data_i, // instruction memory data in
    output wire [31:0] IMEM_addr_o, // instruction memory address out

    // reset lines
    input reset_n,
    input wire [31:0] start_addr_i, // address to start fetching from post reset

    // IF/ID pipeline registers
    output reg [31:0] PIP_insruction_o, // instruction
    output reg [31:0] PIP_pc_o // program counter
);

assign IMEM_addr_o = current_pc;
// next program counter
reg [31:0] current_pc , next_pc;

// logic to compute next address to fetch from
always@ (*)
begin
    if ( stall_if_i )
        next_pc = current_pc - 4; //TODO: explain this???
    else
        next_pc = current_pc + 4;
end

// update current program counter
always@( posedge clk )
begin
    if ( !reset_n )
    begin
        current_pc <= start_addr_i; // start from boot address
        PIP_pc_o <= 0; // clear pipeline register, no instruction yet
    end
    else
    begin
        current_pc <= next_pc;
        PIP_pc_o <= current_pc ;
    end
end

// update pipeline registers

always@(*)
begin
    if ( stall_if_i )
        PIP_insruction_o = 0; // NOP
    else
        PIP_insruction_o = IMEM_data_i;
end

endmodule