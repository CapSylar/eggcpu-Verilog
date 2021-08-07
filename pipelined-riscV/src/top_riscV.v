module top_riscV 
(
    input clk,
    input reset_n,

    // Instruction memory interface 
    output wire [31:0] IMEM_addr_o,
    input wire [31:0] IMEM_data_i,
    output wire IMEM_read_n_o, // 0 read 1 do not read, hold all lines

    // Data memory interface

    output wire DMEM_write_o,
    output wire DMEM_read_o,
    input wire [31:0] DMEM_data_i,
    output wire [31:0] DMEM_addr_o,
    output wire [31:0] DMEM_data_o    
    // *** 
);

// internals *********
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
wire ID_EX_use_imm;
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
wire MEM_WB_write_reg;
wire MEM_WB_use_mem;
wire [31:0] MEM_WB_DMEM_data;
wire [4:0] MEM_WB_rd;


// Forwarding unit *******************
wire forw_EX_MEM_rs1 ;
wire forw_EX_MEM_rs2 ;
wire forw_MEM_WB_rs1 ;
wire forw_MEM_WB_rs2 ;

// Hazard detection unit ************

wire hzrd_IF_ID_stall;
wire hzrd_IF_ID_flush;
wire hzrd_ID_EX_stall;
wire hzrd_ID_EX_flush;

// ************************
// INSTRUCTION FETCH STAGE

instruction_fetch inst_instruction_fetch
(
    .clk(clk),
    .stall_if_i(hzrd_IF_ID_stall),
    .flush_if_i(hzrd_IF_ID_flush),

    .IMEM_data_i(IMEM_data_i),
    .IMEM_addr_o(IMEM_addr_o),
    .IMEM_read_n_o(IMEM_read_n_o),
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
    .id_stall_i(hzrd_ID_EX_stall), // stall the current instruction
    .id_flush_i(hzrd_ID_EX_flush), // flush the local pipeline registers

    // ID/EX pipeline registers ***********************************
    // these below are for the EX stage
    .PIP_operand1_o(ID_EX_operand1), // rs1
    .PIP_operand2_o(ID_EX_operand2), // rs2
    .PIP_immediate_o(ID_EX_immediate), // extended immediate, TODO: maybe we can get away with not saving it ?
    .PIP_aluOper_o(ID_EX_aluOper), // to determine what operation to use
    .PIP_use_imm_o(ID_EX_use_imm), // for execute stage only

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
    .PIP_use_imm_i(ID_EX_use_imm), // use immediate as operand instead of rs2


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
    .PIP_rd_o(EX_MEM_rd),

    // forwarding unit controls to select correct operand

    .use_EX_MEM_rs1_i(forw_EX_MEM_rs1), // use rs1 from EX/MEM
    .use_EX_MEM_rs2_i(forw_EX_MEM_rs2), // use rs2 from EX/MEM
    .use_MEM_WB_rs1_i(forw_MEM_WB_rs1), // use rs1 from MEM/WB
    .use_MEM_WB_rs2_i(forw_MEM_WB_rs2),  // use rs2 from MEM/WB

    .EX_MEM_operand_i(EX_MEM_alu_result), // rd from EX/MEM
    .MEM_WB_operand_i(WB_reg_data) // rd from MEM/WB
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
    .PIP_write_reg_o(MEM_WB_write_reg),
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
    .PIP_write_reg_i(MEM_WB_write_reg),
    .PIP_DMEM_data_i(MEM_WB_DMEM_data),
    .PIP_alu_result_i(MEM_WB_alu_result),
    .PIP_rd_i(MEM_WB_rd),

    // to reg file
    .REG_write_o(WB_reg_write),
    .REG_data_o(WB_reg_data),
    .REG_addr_o(WB_reg_addr) // register number to write to
);

// forwarding unit

forward inst_forward
(
    // from ID/EX pipeline registers *******
    .ID_EX_rs1_i( ID_EX_rs1 ),
    .ID_EX_rs2_i( ID_EX_rs2),

    // from EX/MEM pipeline registers ******
    .EX_MEM_alu_result_i( EX_MEM_alu_result ),
    .EX_MEM_rd_i( EX_MEM_rd ),
    .EX_MEM_write_reg_i( EX_MEM_write_reg ),

    // from MEM/WB pipeline registers *******
    .MEM_WB_rd_i( MEM_WB_rd ),
    .MEM_WB_write_reg_i( MEM_WB_write_reg ),
    // output

    // forward from EX_MEM stage
    .forward_EX_MEM_rs1_o( forw_EX_MEM_rs1 ),
    .forward_EX_MEM_rs2_o( forw_EX_MEM_rs2 ),
    // forward from MEM_WB stage
    .forward_MEM_WB_rs1_o( forw_MEM_WB_rs1 ),
    .forward_MEM_WB_rs2_o( forw_MEM_WB_rs2 )
);

// hazard detection unit

hazard inst_hazard
(
    .clk(clk),
    .reset_n(reset_n),

    // IF_ID control lines
    .IF_ID_stall_o(hzrd_IF_ID_stall),
    .IF_ID_flush_o(hzrd_IF_ID_flush),

    // ID_EX control lines
    .ID_EX_stall_o(hzrd_ID_EX_stall),
    .ID_EX_flush_o(hzrd_ID_EX_flush),

    // ID/EX pipeline inputs
    .ID_EX_read_mem_i(ID_EX_read_mem),
    .ID_EX_rd_i(ID_EX_rd),

    // directly from back of ID
    .IF_instruction_i(IF_ID_instruction)
);


endmodule