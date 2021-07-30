module top_tb
#
(
    parameter PROGRAM_FILE = "test-programs/test-program.mem"
)
(
    input wire clk,
    input wire reset_n
);

wire [31:0] ram_addr , ram_data_in , ram_data_out , rom_data_out , pc ;
wire ram_read , ram_write ;    

riscV eggcpu  ( .clk(clk) , .reset_n(reset_n) , .instructionW(rom_data_out) , .data_mem_read_data(ram_data_out) , .pc(pc) , .data_mem_address(ram_addr) , .data_mem_data_write(ram_data_in) , .data_mem_read(ram_read) , .data_mem_write(ram_write) );
data_memory inst_data_memory ( .clk(clk) , .read_mem(ram_read) , .write_mem(ram_write) , .addr(ram_addr) , .in_data(ram_data_in) , .out_data(ram_data_out)  );
instruction_memory #( .MEM_FILE(PROGRAM_FILE) ) inst_instruction_memory ( .addr(pc) , .data_out(rom_data_out) );

endmodule