module hazard
(
    input clk,
    input reset_n,

    // IF_ID control lines
    output wire IF_ID_stall_o,
    output reg IF_ID_flush_o = 0 , // for now

    // ID_EX control lines
    output wire ID_EX_stall_o ,
    output wire ID_EX_flush_o,

    // ID/EX pipeline inputs
    input wire ID_EX_read_mem_i,
    input wire [4:0] ID_EX_rd_i,

    // directly from back of ID
    input wire [31:0] IF_instruction_i,

    input wire EX_pc_load_i // branch or jump is taken, flush for 2 cycles
);

wire [4:0] rs1 = IF_instruction_i[19:15];
wire [4:0] rs2 = IF_instruction_i[24:20];


// Solves LOAD-USE Hazard

// this type of hazard involves a dependecy between 2 instructions
// than unfortunately can't be solved using forwarding. if for example we load in one instruction
// and then use the loaded-to register as an operand in the next instruction, the loaded-to operand will not be ready in time
// even if we use forwarding since we need it in the EX stage but the preceding instruction is only in the MEM stage whereas its results will be ready in the WB stage,
// thus we need to wait 1 clock cycle, this is done by pausing or stalling the pipeline

// stall condition is : 1- is the instruction ahead of us reading from memory ( load ) ? 
// 2- is it loading to a register that we will be using as a an operand ?
// is all are yes then we stall in the iF stage and flush the ID stage to insert a bubble, on the next clock cycle the instruction is re-decoded

assign IF_ID_stall_o  = ID_EX_read_mem_i && 
    (( ID_EX_rd_i == rs1 ) || ( ID_EX_rd_i == rs2 ));

assign ID_EX_stall_o = 0 ; // for now 

// Solves Control or Branch Hazards
// this type of hazard is cause by the presence of branches and the case where we mispredicted its outcome

reg reg2;
wire ID_EX_flush = IF_ID_stall_o || EX_pc_load_i ; 

always@( posedge clk ) // needed for 2 cycle flush
begin
    if ( !reset_n )
        reg2 <= 0;
    else
        reg2 <= EX_pc_load_i ;
end

assign ID_EX_flush_o = ID_EX_flush || reg2 ;

endmodule