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

// reg_file inst_reg_file ( .clk(clk) , .reset_n(reset_n) , .readReg1() , .readReg2() ,
//         .writeReg1() , .writeRegData() , .writeData() , .dataRead1() , .dataRead2()  );


endmodule