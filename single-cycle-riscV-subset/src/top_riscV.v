module top_riscV ( clk , reset_n , instructionW , data_mem_read_data ,  pc , data_mem_address ,
     data_mem_read , data_mem_write );

input clk , reset_n ;
input wire [31:0] instructionW , data_mem_read_data ;
output wire [31:0] pc , data_mem_address ;
output wire data_mem_read , data_mem_write ;

assign data_mem_address = arithResult ;

wire [31:0] dataRead1 , dataRead2 , arithResult ; 
wire aluSrc , isBranch , readMem , memToReg , writeMem , aluSrc , writeReg , isZero ;
wire [31:0] extendedImmediate ;
wire [1:0] aluOper ;

updatePC instance_pc ( .clk(clk) , .reset_n(reset_n) , .isZero(isZero) , .isBranch(isBranch) , .immediate(extendedImmediate) , .pc(pc) );

complete_alu instance_alu ( .clk(clk) , .aluSrc(aluSrc) , .aluOper(aluOper) , .instructionw(instructionW) , .readRegister1(dataRead1) ,
 .readregister2(dataRead2) , .isZero(isZero) , .arithResult(arithResult) , .extendedImmediate(extendedImmediate)  );

reg_file instance_reg_file ( .clk(clk) , .reset_n(reset_n) , .readReg1(instructionW[19:15]) , .readReg2(instructionW[24:20]),
 .writeReg1(instructionW[11:7]) , .writeRegData( memToReg ? data_mem_read_data : arithResult ) , .writeData(writeReg) , .dataRead1(dataRead1) , .dataRead2(dataRead2) );

controller instance_controller ( .clk(clk) , .reset_n(reset_n) , .opcode(instructionW[6:0] ) , .isBranch(isBranch) ,
 .readMem(readMem) , .memToReg(memToReg) , .writeMem(writeMem) , .aluSrc(aluSrc) , .writeReg(writeReg) 
 , .aluOper(aluOper) );

endmodule