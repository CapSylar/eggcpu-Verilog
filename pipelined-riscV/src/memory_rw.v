`include "definitions.vh"

module memory_rw
(
    input clk,
    input reset_n,

    // Data memory interface
    output wire [31:0] DMEM_addr_o,
    output reg [31:0] DMEM_data_o,
    output wire DMEM_read_o,
    output wire [3:0] DMEM_write_byte_o, // 4 possible bytes to write
    input wire [31:0] DMEM_data_i,

    // from EX/MEM Pipeline registers ****************
    input wire [31:0] PIP_write_data_i,
    input wire [31:0] PIP_alu_result_i,
    input wire [4:0] PIP_rd_i,
    input wire [4:0] PIP_memOper_i,

    // for WB stage
    input wire PIP_use_mem_i,
    input wire PIP_write_reg_i,

    // MEM/WB Pipeline registers ****************
    output reg PIP_use_mem_o,
    output reg PIP_write_reg_o,
    output reg [4:0] PIP_rd_o,
    output reg [31:0] PIP_DMEM_data_o ,
    output reg [31:0] PIP_alu_result_o,

    // for TRAPS
    input wire PIP_TRAP_i,
    output reg PIP_TRAP_o
);

// forward
assign DMEM_addr_o = PIP_alu_result_i;
assign DMEM_read_o = PIP_memOper_i[3] ; // indicates if loads

reg [3:0] write_en;
assign DMEM_write_byte_o = write_en ;

wire [7:0] byte = PIP_write_data_i[7:0];
wire [15:0] half_word = PIP_write_data_i[15:0];

// STORES
//TODO: detect and handle misaligned stores
always@(*)
begin
    write_en = 0;
    DMEM_data_o = 0;

    case(PIP_memOper_i)
    `MEM_SW:
    begin
        // write all 4 bytes => full word
        write_en = 4'b1111;
        DMEM_data_o = PIP_write_data_i; // as is 
    end

    `MEM_SH:
    begin
        // depends on bit before LSB, if 1 upper half if 0 lower half
        if (  DMEM_addr_o[1] ) // upper HW
        begin
            DMEM_data_o = half_word << 16 ;
            write_en = 4'b1100;
        end
        else // lower HW
        begin
            DMEM_data_o = half_word ;
            write_en = 4'b0011;
        end
    end

    `MEM_SB:
    begin
        /// depends on the lower two bits in the address
        case ( DMEM_addr_o[1:0] )
        2'b00: // word = 0x00 0x00 0x00 data
        begin
            DMEM_data_o = byte;
            write_en = 4'b0001;
        end
        2'b01: // word = 0x00 0x00 data 0x00
        begin
            DMEM_data_o = byte << 8 ;
            write_en = 4'b0010;
        end
        2'b10: // word = 0x00 data 0x00 0x00
        begin
            DMEM_data_o = byte << 16 ;
            write_en = 4'b0100;
        end
        2'b11: // word = data 0x00 0x00 0x00
        begin
            DMEM_data_o = byte << 24 ;
            write_en = 4'b1000;
        end
        endcase
    end
    endcase
end


// loads have one clock cycle latency, so current address used to fetch this data must be saved
// and memOper must also be saved

reg [31:0] sav_addr;
reg [4:0] sav_memOper;
always@(posedge clk)
begin
    if ( !reset_n )
    begin
        sav_addr <= 0;
        sav_memOper <= 0;
    end
    else
    begin
        sav_addr <= DMEM_addr_o;
        sav_memOper <= PIP_memOper_i;
    end
end


// LOADS
//TODO: detect and handle misaligned loads
always@(*)
begin

    PIP_DMEM_data_o = 0;
    case (sav_memOper)
    `MEM_LB:
    begin
        case ( sav_addr[1:0] )
            2'b00: PIP_DMEM_data_o = $signed(DMEM_data_i[7:0]);
            2'b01: PIP_DMEM_data_o = $signed(DMEM_data_i[15:8]);
            2'b10: PIP_DMEM_data_o = $signed(DMEM_data_i[23:16]);
            2'b11: PIP_DMEM_data_o = $signed(DMEM_data_i[31:24]);
        endcase
    end
    
    `MEM_LBU:
    begin
        case ( sav_addr[1:0] )
            2'b00: PIP_DMEM_data_o = (DMEM_data_i[7:0]);
            2'b01: PIP_DMEM_data_o = (DMEM_data_i[15:8]);
            2'b10: PIP_DMEM_data_o = (DMEM_data_i[23:16]);
            2'b11: PIP_DMEM_data_o = (DMEM_data_i[31:24]);
        endcase
    end
    `MEM_LH:
    begin
        case ( sav_addr[1] )
            0: PIP_DMEM_data_o = $signed(DMEM_data_i[15:0]); // lower half
            1: PIP_DMEM_data_o = $signed(DMEM_data_i[31:16]); // upper half
        endcase
    end
    `MEM_LHU:
    begin
        case ( sav_addr[1] )
            0: PIP_DMEM_data_o = (DMEM_data_i[15:0]); // lower half
            1: PIP_DMEM_data_o = (DMEM_data_i[31:16]); // upper half
        endcase 
    end
    `MEM_LW:
    begin
        PIP_DMEM_data_o = DMEM_data_i; // as is
    end
    endcase
end



always @(posedge clk)
begin
    if ( !reset_n )
    begin
        PIP_use_mem_o <= 0;
        PIP_write_reg_o <= 0;
        PIP_alu_result_o <= 0 ;
        PIP_rd_o <= 0 ;

        PIP_TRAP_o <= 0;
    end 
    else // just forward some lines 
    begin
        PIP_use_mem_o <= PIP_use_mem_i;
        PIP_write_reg_o <= PIP_write_reg_i;
        PIP_alu_result_o <= PIP_alu_result_i;
        PIP_rd_o <= PIP_rd_i; 

        PIP_TRAP_o <= PIP_TRAP_i;
    end   
end

endmodule