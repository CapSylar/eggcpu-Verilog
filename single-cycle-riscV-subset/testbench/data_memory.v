module data_memory
#
(
    parameter ADDR_WIDTH = 32 , DATA_WIDTH = 32
)
(
    input clk,
    input read_mem,
    input write_mem,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] in_data,
    output reg [DATA_WIDTH-1:0] out_data
);

reg [DATA_WIDTH-1:0] mem  [300 :0] /*verilator public*/ ; // 300 is enough

wire [31:0] actual_addr = { 2'b0 , addr[31:2] } ;// shift left by 2
 
initial
begin
    integer i;
    for ( i = 0 ; i < 2**ADDR_WIDTH ; i=i+1 )
        mem[i] = 0;    
end

// only write on rising edge

always @( posedge clk )
begin
    if ( write_mem )
    begin
        mem[actual_addr] <= in_data ;
    end    
end

// read mem combinationally

always@(*)
begin
    out_data = 0; 

   if ( read_mem )
   begin
       out_data = mem[actual_addr];
   end
end


endmodule