// implementation of the riscV register file
// 32 general purpose registers each with 32 bits

module reg_file  #(parameter address_width = 5, parameter register_size = 32 ) 
        ( clk , reset_n , readReg1 , readReg2 , writeReg1 , writeRegData , writeData , dataRead1 , dataRead2 );

input clk , reset_n , writeData;
input [address_width-1:0] readReg1 , readReg2 , writeReg1 ; // select the registers we want 
input [register_size-1:0] writeRegData;

output reg [register_size-1:0] dataRead1 , dataRead2 ;

reg [register_size-1:0]  registerFile  [2**address_width-1:0] /*verilator public*/;

integer  i;
always @( posedge clk or negedge reset_n )
begin
    if ( !reset_n )
    begin
        dataRead1 = 0;
        dataRead2 = 0;

        for ( i = 0 ; i < 2**address_width ; i=i+1)
        begin
            registerFile[i] = 0;
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
