// implementation of the riscV register file
// 32 general purpose registers each with 32 bits

module reg_file  #(parameter address_width = 5, parameter register_size = 32 ) 
(
    input clk,
    input reset_n,
    input [address_width-1:0] reg1_addr_i,
    input [address_width-1:0] reg2_addr_i,
    input [address_width-1:0] writereg_addr_i,
    input [register_size-1:0] data_i,
    input data_write_i,
    output wire [register_size-1:0] data1_o,
    output wire [register_size-1:0] data2_o
);

reg [register_size-1:0]  registerFile  [(2<<address_width)-1:0];

//TODO: consider moving to this to the forwarding logic for better organisation
// do forwarding fro MEM/WB inside the register file to ID/EX
// if we WB wants to write while ID wants to read form the reg file, forward what WB wants to write directly
// to solve the hazard

wire is_write = data_write_i && writereg_addr_i ;

reg [register_size-1:0] data1 , data2; 
assign data1_o = data1; // assign these to the output 
assign data2_o = data2;

// reading from register file
// always@(*)
// begin
//     // read to data_o1
//     if ( is_write && writereg_addr_i == reg1_addr_i ) // forward result form WB
//         data1 = data_i;
//     else
//         data1 = registerFile[reg1_addr_i]; // read normally

//     // read to data_o2
//     if ( is_write && writereg_addr_i == reg2_addr_i ) // forward result form WB
//         data2 = data_i;
//     else
//         data2 = registerFile[reg2_addr_i]; // read normally   
// end


// read from register file
always@(*)
begin
    data1 = registerFile[reg1_addr_i];
    data2 = registerFile[reg2_addr_i];
end


// writing to register file
integer  i;
always @( negedge clk ) // write at falling edge, read at rising
begin
    if ( !reset_n ) //  TODO: consider removing this, save LUTs
    begin
        for ( i = 0 ; i < 2**address_width ; i = i + 1  )
        begin
            registerFile[i] <= 0;
        end
    end

    else if ( is_write )  // write needed data
    begin
        registerFile[writereg_addr_i] <= data_i;
        // $display("register %d is now %d" , writereg_addr_i , data_i );
    end
end

endmodule
