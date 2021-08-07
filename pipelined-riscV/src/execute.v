`include "definitions.vh"

module execute
(
    input clk,
    input reset_n,

    // from ID/EX pipeline registers

    input wire [31:0] PIP_operand1_i, // rs1
    input wire [31:0] PIP_operand2_i, // rs2
    input wire [4:0] PIP_rd_i, // rd, just forward
    input wire [31:0] PIP_immediate_i, // extended immediate
    input wire [3:0] PIP_aluOper_i, // need to be decoded further
    input wire PIP_use_imm_i, // use immediate as operand instead of rs2

    // these below are for the Memory stage
    input wire PIP_write_mem_i,
    input wire PIP_read_mem_i,

    // these below are for the Write Back stage
    input wire PIP_use_mem_i,
    input wire PIP_write_reg_i,

    // EX/MEM pipeline registers***************************
    
    // these below are for the Memory stage
    output reg PIP_write_mem_o,
    output reg PIP_read_mem_o,
    output reg [31:0] PIP_alu_alu_result_o,
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
    input wire [31:0] MEM_WB_operand_i // rd from MEM/WB
);

// forward pipeline registers

always@( posedge clk )
begin
    if ( !reset_n )
    begin
        PIP_write_mem_o <= 0;
        PIP_read_mem_o <= 0;
        PIP_alu_alu_result_o <= 0;
        PIP_second_operand_o <= 0;

        PIP_use_mem_o <= 0;
        PIP_write_reg_o <= 0;
        PIP_rd_o <= 0 ;
    end

    else // just forward
    begin
        PIP_write_mem_o <= PIP_write_mem_i;
        PIP_read_mem_o <= PIP_read_mem_i;
        PIP_alu_alu_result_o <= alu_result;
        PIP_second_operand_o <= PIP_operand2_i; // TODO: write this!!!!!

        PIP_use_mem_o <= PIP_use_mem_i;
        PIP_write_reg_o <= PIP_write_reg_i;
        PIP_rd_o <= PIP_rd_i;
    end
end

// determine what operation we need to do

reg [31:0] alu_result;
reg [31:0] operand1 , operand2;

// determine what operands the ALU should use
// 1-directly from ID/EX registers, or in the case of forwarding from EX/MEM or MEM/WB

always @(*)
begin
    if ( use_EX_MEM_rs1_i )
        operand1 = EX_MEM_operand_i;
    else if ( use_MEM_WB_rs1_i )
        operand1 = MEM_WB_operand_i;
    else
        operand1 = PIP_operand1_i;
end

always @(*)
begin
    if ( use_EX_MEM_rs2_i )
        operand2 = EX_MEM_operand_i;
    else if ( use_MEM_WB_rs2_i )
        operand2 = MEM_WB_operand_i;
    else
        operand2 = PIP_operand2_i;   
end

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
    `ALU_SLL:
        alu_result = operand1 << operand2;
    `ALU_SRA:
        alu_result = operand1 >>> operand2; // converve sign bit
    `ALU_SRL:
        alu_result = operand1 >> operand2;

    endcase
end






endmodule