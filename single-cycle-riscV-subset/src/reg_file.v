// implementation of the riscV register file
// 32 general purpose registers each with 32 bits

module reg_file ( clk , reset_n , readReg1 , readReg2 , writeReg1 , writeRegData , writeData , dataRead1 , dataRead2 );

input clk , reset_n , writeData;
input [4:0] readReg1 , readReg2 , writeReg1 ; // select the registers we want 
input [31:0] writeRegData;

output reg [31:0] dataRead1 , dataRead2 ;

reg [31:0] registerFile [31:0];

integer  i;
always @( posedge clk or negedge reset_n )
begin
    if ( !reset_n )
    begin
        dataRead1 = 0;
        dataRead2 = 0;

        for ( i = 0 ; i < 32 ; i=i+1)
        begin
            registerFile[i] = 32'b0;
        end
    end

    else
    begin
        // read registers
        dataRead1 = registerFile[readReg1];
        dataRead2 = registerFile[readReg2];

        if ( writeData ) // write needed data
            registerFile[writeReg1] <= writeRegData;
    end
end


endmodule
