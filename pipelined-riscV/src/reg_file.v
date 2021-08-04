// implementation of the riscV register file
// 32 general purpose registers each with 32 bits

module reg_file  #(parameter address_width = 5, parameter register_size = 32 ) 
        ( clk , reset_n , reg1_addr_i , reg2_addr_i , writereg_addr_i , data_i , data_write_i , data1_o , data2_o );

input clk , reset_n , data_write_i;
input [address_width-1:0] reg1_addr_i , reg2_addr_i , writereg_addr_i ; // select the registers we want 
input [register_size-1:0] data_i;

output reg [register_size-1:0] data1_o , data2_o ;

reg [register_size-1:0]  registerFile  [2**address_width-1:0];

integer  i;
always @( posedge clk )
begin
    // reading happends at every posedge
    data1_o = registerFile[reg1_addr_i];
    data2_o = registerFile[reg2_addr_i];

    if ( !reset_n )
    begin
        for ( i = 0 ; i < 2**address_width ; i=i+1)
        begin
            registerFile[i] = 0;
        end
    end

    else if ( data_write_i )  // write needed data
    begin
        if ( writereg_addr_i != 0 ) // never write to x0, thus it stays = 0, not the cleanest way to do it
            registerFile[writereg_addr_i] <= data_i;
    end
end

endmodule
