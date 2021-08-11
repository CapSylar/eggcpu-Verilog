`include "definitions.vh"

module execute
(
    input clk,
    input reset_n,

    // from ID/EX pipeline registers

    input wire [31:0] PIP_pc_i,
    input wire [31:0] PIP_operand1_i, // rs1
    input wire [31:0] PIP_operand2_i, // rs2
    input wire [4:0] PIP_rd_i, // rd, just forward
    input wire [31:0] PIP_immediate_i, // extended immediate
    input wire [3:0] PIP_aluOper_i, // need to be decoded further
    input wire PIP_use_imm_i, // use immediate as operand instead of rs2
    input wire PIP_use_pc_i, // use PC as first operand1 instread of rs1
    input wire PIP_use_zero, // use zero instead of rs1

    // for branches and jumps

    input wire [1:0] PIP_bnj_oper_i, // bit 0 is bypass and bit 1 is pc-relative or reg-relative
    input wire PIP_is_bnj_i,
    input wire PIP_bnj_neg_i,

    // these below are for the Memory stage
    input wire [4:0] PIP_memOper_i, // just forward

    // these below are for the Write Back stage
    input wire PIP_use_mem_i,
    input wire PIP_write_reg_i,

    // EX/MEM pipeline registers***************************
    
    // these below are for the Memory stage
    output reg [4:0] PIP_memOper_o,
    output reg [31:0] PIP_alu_result_o,
    output reg [31:0] PIP_second_operand_o, // if data mem write is on, this will be written

    // these below are for the Write Back stage
    output reg PIP_use_mem_o,
    output reg PIP_write_reg_o,
    output reg [4:0] PIP_rd_o,
    
    // forwarding unit controls to select correct operand

    input wire use_EX_MEM_rs1_i, // use rs1 from EX/MEM
    input wire use_EX_MEM_rs2_i, // use rs2 from EX/MEM
    input wire use_MEM_WB_rs1_i, // use rs1 from MEM/WB
    input wire use_MEM_WB_rs2_i,  // use rs2 from MEM/WB

    input wire [31:0] EX_MEM_operand_i, // rd from EX/MEM
    input wire [31:0] MEM_WB_operand_i, // rd from MEM/WB

    // to PC, for branches and jumps
    output wire PC_load_target_o,
    output reg [31:0] PC_target_address_o,

    // for TRAPS
    input wire PIP_TRAP_i, // just forward this
    output reg PIP_TRAP_o
);

// forward pipeline registers

always@( posedge clk )
begin
    if ( !reset_n )
    begin
        PIP_memOper_o <= 0;
        PIP_alu_result_o <= 0;
        PIP_second_operand_o <= 0;

        PIP_use_mem_o <= 0;
        PIP_write_reg_o <= 0;
        PIP_rd_o <= 0 ;

        PIP_TRAP_o <= 0;
    end

    else // just forward
    begin
        PIP_memOper_o <= PIP_memOper_i;
        PIP_alu_result_o <= (PIP_is_bnj_i && PIP_bnj_oper_i[1]) ? PIP_pc_i+4 : alu_result; // if branch or jump and bypass is required forward pc+4 instead of alu_result
        PIP_second_operand_o <= new_rs2;

        PIP_use_mem_o <= PIP_use_mem_i;
        PIP_write_reg_o <= PIP_write_reg_i;
        PIP_rd_o <= PIP_rd_i;

        PIP_TRAP_o <= PIP_TRAP_i;
    end
end

// determine what operation we need to do

reg [31:0] alu_result;
reg [31:0] operand1 , operand2;


// updated rs2, if we have no forwarding happening then its the same rs2
reg [31:0] new_rs2;

// determine what operands the ALU should use
// 1-directly from ID/EX registers, or in the case of forwarding from EX/MEM or MEM/WB

always @(*) // calculate operand1
begin
    if ( PIP_use_zero ) // for LUI
        operand1 = 0 ;
    else if ( PIP_use_pc_i )
        operand1 = PIP_pc_i; // use pc as first operand, ALUIPC instruction
    else if ( use_EX_MEM_rs1_i )
        operand1 = EX_MEM_operand_i;
    else if ( use_MEM_WB_rs1_i )
        operand1 = MEM_WB_operand_i;
    else
        operand1 = PIP_operand1_i;
end

always@(*)
begin
    if ( use_EX_MEM_rs2_i )
        new_rs2 = EX_MEM_operand_i;
    else if ( use_MEM_WB_rs2_i )
        new_rs2 = MEM_WB_operand_i;
    else
        new_rs2 = PIP_operand2_i; // stays the same
end

always@(*) // calculate operand2 
begin
    if ( PIP_use_imm_i )
        operand2 = PIP_immediate_i;
    else
        operand2 = new_rs2;
end

wire [4:0] shift_amount = operand2[4:0];

always@(*)
begin
    alu_result = 0;

    case(PIP_aluOper_i)
    `ALU_ADD: // add operation
        alu_result = operand1 + operand2;
    `ALU_SUB: // sub operation
        alu_result = operand1 - operand2;
    `ALU_AND:
        alu_result = operand1 & operand2;
    `ALU_XOR:
        alu_result = operand1 ^ operand2;
    `ALU_OR:
        alu_result = operand1 | operand2;
    `ALU_SLT:
        begin
            if ( $signed(operand1) < $signed(operand2) )
                alu_result = 1;
        end
    `ALU_SLTU:
        begin
            if ( operand1 < operand2 )
                 alu_result = 1;
        end
    `ALU_SEQ:
        begin
            if ( operand1 == operand2 )
                alu_result = 1;
        end
    `ALU_SLL:
        alu_result = operand1 << shift_amount;
    `ALU_SRA:
        alu_result = $signed(operand1) >>> shift_amount; // converve sign bit
    `ALU_SRL:
        alu_result = operand1 >> shift_amount;

    endcase
end

// branch or jump handling
// if it needs a bypass then its a jump instruction thus load unconditionally
assign PC_load_target_o = PIP_is_bnj_i && (PIP_bnj_oper_i[1] || ( alu_result && !PIP_bnj_neg_i ) || ( !alu_result && PIP_bnj_neg_i )) ;

always@(*)
begin
    if ( PIP_bnj_oper_i[0] ) // if 1 register relative => add rs1 and immediate
        PC_target_address_o = operand1 + PIP_immediate_i;
    else // else 0 pc relative , add immediate to PC
        PC_target_address_o = PIP_pc_i + PIP_immediate_i;
end



endmodule