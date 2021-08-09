module instruction_fetch
(
    input clk,

    // control lines
    input wire stall_if_i, // stall instruction fetch
    input wire flush_if_i, // flush ( set = 0 ) instruction fetch registers
    // Instruction memory interface
    input wire [31:0] IMEM_data_i, // instruction memory data in
    output wire [31:0] IMEM_addr_o, // instruction memory address out
    output wire IMEM_read_n_o, // instruction memory read enable n

    // reset lines
    input reset_n,
    input wire [31:0] start_addr_i, // address to start fetching from post reset

    // IF/ID pipeline registers
    output reg [31:0] PIP_insruction_o, // instruction
    output reg [31:0] PIP_pc_o, // program counter

    // for branch and jump
    input wire PIP_pc_load_i, // load target address
    input wire [31:0] PIP_target_address_i // address to jump to
);

assign IMEM_read_n_o = stall_if_i; // do not read on the next cycle, keep IMEM_data_o the same
assign IMEM_addr_o = current_pc;
// next program counter
reg [31:0] current_pc , next_pc;

// logic to compute next address to fetch from
//TODO: what happends if stall and load at the same time ???? 
always@ (*)
begin
    if ( stall_if_i )
        next_pc = current_pc; // hold pc since memory will not be read on this cycle ( read_mem_n = 1 )( 1 cycle stall )
    else if ( PIP_pc_load_i )
        next_pc = PIP_target_address_i ; // load branch or jump address
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
        PIP_pc_o <= ( stall_if_i ) ? PIP_pc_o : current_pc ;
    end
end

// update pipeline registers

always@(*)
begin
    if ( flush_if_i )
        PIP_insruction_o = 0; // NOP, no need to change PC i guess ( check assumption again )
    else
        PIP_insruction_o = IMEM_data_i;
end

endmodule