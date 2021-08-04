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
    output reg [4:0] PIP_rd_o
    // *****************************************************
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
        PIP_second_operand_o <= 0; // TODO: write this!!!!!

        PIP_use_mem_o <= PIP_use_mem_i;
        PIP_write_reg_o <= PIP_write_reg_i;
        PIP_rd_o <= PIP_rd_i;
    end
end

// determine what operation we need to do

reg [31:0] alu_result;

always@(*)
begin
    case(PIP_aluOper_i)
    `ALU_ADD: // add operation
        alu_result = PIP_operand1_i + PIP_operand2_i;
    `ALU_SUB: // sub operation
        alu_result = PIP_operand1_i - PIP_operand2_i;
    `ALU_AND:
        alu_result = PIP_operand1_i & PIP_operand2_i;
    `ALU_XOR:
        alu_result = PIP_operand1_i ^ PIP_operand2_i;
    `ALU_OR:
        alu_result = PIP_operand1_i | PIP_operand2_i;

    default:
        alu_result =31'b0 ; 
    endcase
end






endmodule