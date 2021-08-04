module top_riscV 
(
    input clk,
    input reset_n,

    // Instruction memory interface 
    output wire [31:0] IMEM_addr_o,
    input wire [31:0] IMEM_data_i,

    // Data memory interface

    output wire DMEM_write_o,
    output wire DMEM_read_o,
    input wire [31:0] DMEM_data_i,
    output wire [31:0] DMEM_addr_o,
    output wire [31:0] DMEM_data_o    
    // *** 
);

// internals *********

reg stall_if;
wire WB_reg_write;
wire [31:0] WB_reg_data;
wire [4:0] WB_reg_addr;

// IF/ID pipeline registers***********
wire [31:0] IF_ID_instruction;
wire [31:0] IF_ID_pc;

//ID/EX pipeline registers************
wire [31:0] ID_EX_operand1;
wire [31:0] ID_EX_operand2;
wire [31:0] ID_EX_immediate;
wire [3:0] ID_EX_aluOper;
wire ID_EX_read_mem;
wire ID_EX_write_mem;
wire ID_EX_use_mem;
wire ID_EX_write_reg;
wire [4:0] ID_EX_rs1;
wire [4:0] ID_EX_rs2;
wire [4:0] ID_EX_rd;

// EX/MEM pipeline registers**********
wire [31:0] EX_MEM_alu_result;
wire [31:0] EX_MEM_second_op;
wire [4:0] EX_MEM_rd;
wire EX_MEM_read_mem;
wire EX_MEM_write_mem;
wire EX_MEM_use_mem;
wire EX_MEM_write_reg;


// MEM/WB pipeline registers**********
wire [31:0] MEM_WB_alu_result;
wire [4:0] MEM_WB_reg_addr;
wire MEM_WB_reg_write;
wire MEM_WB_use_mem;
wire [31:0] MEM_WB_DMEM_data;
wire [4:0] MEM_WB_rd;

// ************************
// INSTRUCTION FETCH STAGE

instruction_fetch inst_instruction_fetch
(
    .clk(clk),
    .stall_if_i(stall_if),
    .IMEM_data_i(IMEM_data_i),
    .IMEM_addr_o(IMEM_addr_o),
    .reset_n(reset_n),
    .start_addr_i(0),
    .PIP_insruction_o(IF_ID_instruction),
    .PIP_pc_o(IF_ID_pc)
);

// ********************
// INSTRUCTION DECODE STAGE

instruction_decode inst_instruction_decode
(
    .clk(clk),
    .reset_n(reset_n),

    // from WB stage 
    .PIP_rd_addr_i(WB_reg_addr), // register file address to write to
    .PIP_rd_data_i(WB_reg_data), // data to write to
    .PIP_rd_write_i(WB_reg_write), // control line for register file writes

    // from IF stage
    .PIP_instr_i(IF_ID_instruction), // instruction
    .PIP_pc_i(IF_ID_pc), // PC of the instruction in the pipeline

    // control
    .id_stall_i(1'b0), // stall the current instruction

    // ID/EX pipeline registers ***********************************
    // these below are for the EX stage
    .PIP_operand1_o(ID_EX_operand1), // rs1
    .PIP_operand2_o(ID_EX_operand2), // rs2
    .PIP_immediate_o(ID_EX_immediate), // extended immediate, TODO: maybe we can get away with not saving it ?
    .PIP_aluOper_o(ID_EX_aluOper), // to determine what operation to use

    // these below are for the Memory stage
    .PIP_write_mem_o(ID_EX_write_mem),
    .PIP_read_mem_o(ID_EX_read_mem),

    // these below are for the Write Back stage
    .PIP_use_mem_o(ID_EX_use_mem),
    .PIP_write_reg_o(ID_EX_write_reg), 

    // these below are used are for the forwarding unit
    .PIP_rs1_o(ID_EX_rs1), // address of first register operand
    .PIP_rs2_o(ID_EX_rs2), // address of second register operand
    .PIP_rd_o(ID_EX_rd) // address of destination register
);

// ********************
// EXECUTE STAGE

execute inst_execute
(
    .clk(clk),
    .reset_n(reset_n),

    // from ID/EX pipeline registers
    .PIP_operand1_i(ID_EX_operand1), // rs1
    .PIP_operand2_i(ID_EX_operand2), // rs2
    .PIP_rd_i(ID_EX_rd), // rd, just forward
    .PIP_immediate_i(ID_EX_immediate), // extended immediate
.PIP_aluOper_i(ID_EX_aluOper), // need to be decoded further

    // these below are for the Memory stage
    .PIP_write_mem_i(ID_EX_write_mem),
    .PIP_read_mem_i(ID_EX_read_mem),

    // these below are for the Write Back stage
    .PIP_use_mem_i(ID_EX_use_mem),
    .PIP_write_reg_i(ID_EX_write_reg),

    // EX/MEM pipeline registers***************************
    
    // these below are for the Memory stage
    .PIP_write_mem_o(EX_MEM_write_mem),
    .PIP_read_mem_o(EX_MEM_read_mem),
    .PIP_alu_alu_result_o(EX_MEM_alu_result),
    .PIP_second_operand_o(EX_MEM_second_op), // if data mem write is on, this will be written

    // these below are for the Write Back stage
    .PIP_use_mem_o(EX_MEM_use_mem),
    .PIP_write_reg_o(EX_MEM_write_reg),
    .PIP_rd_o(EX_MEM_rd)
);

// ********************
// MEMORY STAGE

memory_rw inst_memory_rw
(
    .clk(clk),
    .reset_n(reset_n),

     // Data memory interface
    .DMEM_addr_o(DMEM_addr_o),
    .DMEM_data_o(DMEM_data_o),
    .DMEM_read_o(DMEM_read_o),
    .DMEM_write_o(DMEM_write_o),
    .DMEM_data_i(DMEM_data_i),    

    // from EX/MEM Pipeline registers ****************
    .PIP_second_operand_i(EX_MEM_second_op),
    .PIP_alu_result_i(EX_MEM_alu_result),
    .PIP_rd_i(EX_MEM_rd),
    .PIP_read_mem_i(EX_MEM_read_mem),
    .PIP_write_mem_i(EX_MEM_write_mem),

    // for WB stage
    .PIP_use_mem_i(EX_MEM_use_mem),
    .PIP_write_reg_i(EX_MEM_write_reg),

    // MEM/WB Pipeline registers ****************
    .PIP_use_mem_o(MEM_WB_use_mem),
    .PIP_write_reg_o(MEM_WB_reg_write),
    .PIP_rd_o(MEM_WB_rd),
    .PIP_DMEM_data_o(MEM_WB_DMEM_data),
    .PIP_alu_result_o(MEM_WB_alu_result)
);

// ********************
// WRITE BACK STAGE

write_back inst_write_back
(
    .clk(clk),
    .reset_n(reset_n),

    // from MEM/WB pipeline registers
    .PIP_use_mem_i(MEM_WB_use_mem),
    .PIP_write_reg_i(MEM_WB_reg_write),
    .PIP_DMEM_data_i(MEM_WB_DMEM_data),
    .PIP_alu_result_i(MEM_WB_alu_result),
    .PIP_rd_i(MEM_WB_rd),

    // to reg file
    .REG_write_o(WB_reg_write),
    .REG_data_o(WB_reg_data),
    .REG_addr_o(WB_reg_addr) // register number to write to
);

endmodule