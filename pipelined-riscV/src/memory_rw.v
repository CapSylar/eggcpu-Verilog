module memory_rw
(
    input clk,
    input reset_n,

    // Data memory interface
    output wire [31:0] DMEM_addr_o,
    output wire [31:0] DMEM_data_o,
    output wire DMEM_read_o,
    output wire DMEM_write_o,
    input wire [31:0] DMEM_data_i,    

    // from EX/MEM Pipeline registers ****************
    input wire [31:0] PIP_second_operand_i,
    input wire [31:0] PIP_alu_result_i,
    input wire [4:0] PIP_rd_i,
    input wire PIP_read_mem_i,
    input wire PIP_write_mem_i,

    // for WB stage
    input wire PIP_use_mem_i,
    input wire PIP_write_reg_i,

    // MEM/WB Pipeline registers ****************
    output reg PIP_use_mem_o,
    output reg PIP_write_reg_o,
    output reg [4:0] PIP_rd_o,
    output wire [31:0] PIP_DMEM_data_o ,
    output reg [31:0] PIP_alu_result_o
);

// forward
assign PIP_DMEM_data_o =  DMEM_data_i ; // no reset for this line for now
assign DMEM_addr_o = PIP_alu_result_i;
assign DMEM_data_o = PIP_second_operand_i;
assign DMEM_read_o = PIP_read_mem_i;
assign DMEM_write_o = PIP_write_mem_i;

always @(posedge clk)
begin
    if ( !reset_n )
    begin
        PIP_use_mem_o <= 0;
        PIP_write_reg_o <= 0;
        PIP_alu_result_o <= 0 ;
        PIP_rd_o <= 0 ;
    end 
    else // just forward some lines 
    begin
        PIP_use_mem_o <= PIP_use_mem_i;
        PIP_write_reg_o <= PIP_write_reg_i;
        PIP_alu_result_o <= PIP_alu_result_i;
        PIP_rd_o <= PIP_rd_i; 
    end   
end

endmodule