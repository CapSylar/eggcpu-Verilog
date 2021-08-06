// implementation of a forwarding unit
// for now only forward to the EX stage
module forward
(
    // from ID/EX pipeline registers *******
    input wire [4:0] ID_EX_rs1_i,
    input wire [4:0] ID_EX_rs2_i,

    // from EX/MEM pipeline registers ******
    input wire [31:0] EX_MEM_alu_result_i,
    input wire [4:0] EX_MEM_rd_i,
    input wire EX_MEM_write_reg_i,

    // from MEM/WB pipeline registers *******
    input wire [4:0] MEM_WB_rd_i,
    input wire MEM_WB_write_reg_i,

    // output

    // forward from EX_MEM stage
    output wire forward_EX_MEM_rs1_o,
    output wire forward_EX_MEM_rs2_o,
    // forward from MEM_WB stage
    output wire forward_MEM_WB_rs1_o,
    output wire forward_MEM_WB_rs2_o
);

// forward from the EX/MEM registers when
//1- we are writing something to the register file and not to x0
//2- the destination register we are writing to happens to be one of the operands of an upcoming instruction

wire EX_MEM_possible_forward = EX_MEM_write_reg_i && ( EX_MEM_rd_i ) ; 
assign forward_EX_MEM_rs1_o =  EX_MEM_possible_forward && ( EX_MEM_rd_i == ID_EX_rs1_i ) ;
assign forward_EX_MEM_rs2_o = EX_MEM_possible_forward && ( EX_MEM_rd_i == ID_EX_rs2_i ) ;

// forward from MEM/WB registers, same conditions as before
// we have to pay attention to a case where there is a possible forwarding from both stages at the same time
// like for example for the following code chunk
// add x3,x3,x4
// add x3,x3,x5
// add x3,x3,x4

// in this case all Rd is the same for the 3 instructions
// we must forward from the most recent stage which is EX/MEM since it contains the most up-to-date version of Rd
// which is x3 in the example

wire MEM_WB_possible_forward = MEM_WB_write_reg_i && ( MEM_WB_write_reg_i ) ;
assign forward_MEM_WB_rs1_o = MEM_WB_possible_forward && !forward_EX_MEM_rs1_o && ( MEM_WB_rd_i == ID_EX_rs1_i );
assign forward_MEM_WB_rs2_o = MEM_WB_possible_forward && !forward_EX_MEM_rs2_o && ( MEM_WB_rd_i == ID_EX_rs2_i );

endmodule