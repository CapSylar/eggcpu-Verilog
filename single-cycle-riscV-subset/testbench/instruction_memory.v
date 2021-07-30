module instruction_memory
#
(
    parameter ADDR_WIDTH = 32 , parameter DATA_WIDTH = 32 , MEM_FILE
)
(
    input [ADDR_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] rom [300:0] /*verilator public*/ ; // 300 enough for now 

wire [31:0] actual_addr = { 2'b0 , addr[31:2] }; // shift right 2 

initial
begin
    $readmemh( MEM_FILE , rom );
end

// read combinationally
always @(*)
begin
    data_out = rom[actual_addr];
end 



endmodule