module write_back
(
    input clk,
    input reset_n,

    // from MEM/WB pipeline registers

    input wire PIP_use_mem_i,
    input wire PIP_write_reg_i,
    input wire [31:0] PIP_DMEM_data_i ,
    input wire [31:0] PIP_alu_result_i,
    input wire [4:0] PIP_rd_i,

    // to reg file
    output wire REG_write_o,
    output wire [31:0] REG_data_o, // data to write to register file
    output wire [4:0] REG_addr_o, // register number to write to

    // for TRAPS
    input wire PIP_TRAP_i,
    output wire PIP_TRAP_o
);

assign REG_write_o = PIP_write_reg_i;
assign REG_data_o = PIP_use_mem_i ? PIP_DMEM_data_i : PIP_alu_result_i ;
assign REG_addr_o = PIP_rd_i;

assign PIP_TRAP_o = PIP_TRAP_i;

endmodule