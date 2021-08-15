module eggSoC
(
    input wire clk,
    input wire btnC,

    output wire [0:0] led
);

wire TRAP;
assign led[0] = TRAP;

reg [31:0] DMEM_data_i = 0 ;
reg [31:0] IMEM_data_i = 0 ;

wire reset_n = !btnC; 
wire [31:0] IMEM_addr_o ;
wire IMEM_read_n_o;
wire [31:0] DMEM_addr_o ;
wire [31:0]  DMEM_data_o ;

wire [3:0] DMEM_byte_en ;
wire DMEM_read_o ;

parameter TEST_MEMORY_WIDTH = 12 ;

// Instruction and Data mmemory
reg [31:0] data_ram [0:2<<TEST_MEMORY_WIDTH-1];
reg [31:0] instr_ram [0:2<<TEST_MEMORY_WIDTH-1];

initial
begin
    $readmemh( "/home/robin/Desktop/eggcpu/pipelined-riscV/testing/build-files/add.S.hex" , data_ram );
    $readmemh( "/home/robin/Desktop/eggcpu/pipelined-riscV/testing/build-files/add.S.hex" , instr_ram );
end

wire [31:0] DMEM_addr = DMEM_addr_o[TEST_MEMORY_WIDTH-1:0] >> 2;
wire [31:0] IMEM_addr = IMEM_addr_o[TEST_MEMORY_WIDTH-1:0] >> 2;


always@(posedge clk)
begin
    if ( !reset_n )
    begin
        IMEM_data_i <= 0;
    end
    else
    begin
        if ( !IMEM_read_n_o ) // read instruction from ram
            IMEM_data_i <= instr_ram[IMEM_addr];
    end
end


always@(posedge clk)
begin
    if (!reset_n)
    begin
        DMEM_data_i <= 0 ;
    end
    else
    begin
        if( DMEM_read_o ) // read data from ram
            DMEM_data_i <= data_ram[DMEM_addr]; 

        if (DMEM_byte_en[0])
            data_ram[DMEM_addr][7:0] <= DMEM_data_o[7:0];
        if ( DMEM_byte_en[1] )
            data_ram[DMEM_addr][15:8] <= DMEM_data_o[15:8];
        if (DMEM_byte_en[2])
            data_ram[DMEM_addr][23:16] <= DMEM_data_o[23:16];
        if ( DMEM_byte_en[3] )
            data_ram[DMEM_addr][31:24] <= DMEM_data_o[31:24];
    end
end


// // essentially a two port ram module
// always@( posedge clk )
// begin
//     if ( !reset_n )
//     begin
//         IMEM_data_i <= 0;
//     end
//     else
//     begin
//     end
// end
    
top_riscV eggcpu
(
    .clk(clk),
    .reset_n(reset_n),
    .IMEM_addr_o(IMEM_addr_o),
    .IMEM_data_i(IMEM_data_i),
    .IMEM_read_n_o(IMEM_read_n_o),
    .DMEM_write_byte_o(DMEM_byte_en),
    .DMEM_read_o(DMEM_read_o),
    .DMEM_data_i(DMEM_data_i),
    .DMEM_addr_o(DMEM_addr_o),
    .DMEM_data_o(DMEM_data_o),

    // exception lines
    .TRAP_o(TRAP) // signals an exception 
);



endmodule