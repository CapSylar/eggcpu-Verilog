module tb_top_riscV;
parameter TEST_MEMORY_ADDR_WIDTH = 1024 ;

reg clk;
reg reset_n;

// Internal wire definitions *****

wire [31:0] IMEM_addr_o ;
reg [31:0] IMEM_data_i ;
reg [31:0] DMEM_data_i ;
wire [31:0] DMEM_addr_o ;
wire [31:0]  DMEM_data_o ;

wire DMEM_write_o ;
wire DMEM_read_o ;

// ********************************

top_riscV uut
(
    .clk(clk),
    .reset_n(reset_n),
    .IMEM_addr_o(IMEM_addr_o),
    .IMEM_data_i(IMEM_data_i),
    .DMEM_write_o(DMEM_write_o),
    .DMEM_read_o(DMEM_read_o),
    .DMEM_data_i(DMEM_data_i),
    .DMEM_addr_o(DMEM_addr_o),
    .DMEM_data_o(DMEM_data_o)
);

// Instruction and Data mmemory
reg [31:0] ram [0:2**TEST_MEMORY_ADDR_WIDTH-1];

// initial begin
//     $readmemh( "hello.txt" , ram );
// end

// essentially a two port ram module
always@( posedge clk )
begin
    if ( !reset_n )
    begin
        IMEM_data_i <= 0;
        DMEM_data_i <= 0 ;
    end
    else
    begin
        IMEM_data_i <= ram[IMEM_addr_o[TEST_MEMORY_ADDR_WIDTH-1:0]]; // always read

        if ( DMEM_write_o ) // write to ram 
            ram[DMEM_addr_o[TEST_MEMORY_ADDR_WIDTH-1:0]] <= DMEM_data_o;
        else if ( DMEM_read_o ) // read from ram
            DMEM_data_i <= ram[DMEM_addr_o[TEST_MEMORY_ADDR_WIDTH-1:0]]; 
    end
end


localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
    if ($test$plusargs("trace"))
    begin
            $dumpfile("tb_top_riscV.vcd");
        $dumpvars(0, tb_top_riscV);
    end
end

initial begin
    #1 reset_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) reset_n<=1;
    #(CLK_PERIOD*3) reset_n<=0;clk<=0;
    repeat(5) @(posedge clk);
    reset_n<=1;
    @(posedge clk);
    repeat(2) @(posedge clk);

    $display("Simulation Complete!");
    $finish(2);
end

endmodule
