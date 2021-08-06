`include "definitions.vh"

module instruction_decode
(
    input clk,
    input reset_n,

    // from WB stage 
    input wire [4:0]  PIP_rd_addr_i, // register file address to write to
    input wire [31:0] PIP_rd_data_i, // data to write to
    input wire PIP_rd_write_i, // control line for register file writes

    // from IF stage
    input wire [31:0] PIP_instr_i , // instruction
    input wire [31:0] PIP_pc_i, // PC of the instruction in the pipeline

    // control
    input wire id_stall_i, // stall the current instruction

    // ID/EX pipeline registers ***********************************
    // these below are for the EX stage
    output reg [31:0] PIP_operand1_o, // rs1
    output reg [31:0] PIP_operand2_o, // rs2
    output reg [31:0] PIP_immediate_o, // extended immediate, TODO: maybe we can get away with not saving it ?
    output reg [3:0] PIP_aluOper_o, // to determine what operation to use

    // these below are for the Memory stage
    output reg PIP_write_mem_o,
    output reg PIP_read_mem_o,

    // these below are for the Write Back stage
    output reg PIP_use_mem_o,
    output reg PIP_write_reg_o, 

    // these below are used are for the forwarding unit and WB stage
    output reg[4:0] PIP_rs1_o, // address of first register operand
    output reg[4:0] PIP_rs2_o, // address of second register operand
    output reg[4:0] PIP_rd_o // address of destination register

    // *************************************************************
);

wire [31:0] regf_o1, regf_o2 ; 
wire [31:0] instruction = PIP_instr_i; // TODO: rename and remove this

// decode the fields
wire [6:0] opcode = instruction[6:0];
wire [4:0] rs1 = instruction[19:15];
wire [4:0] rs2 = instruction[24:20];
wire [4:0] rd = instruction[11:7];
wire [2:0] func3 = instruction[14:12];
wire [6:0] func7 = instruction[31:25];

// instantiate register file
reg_file inst_reg_file
(
    .clk(clk),
    .reset_n(reset_n),

    //register file read interface
    .reg1_addr_i(rs1),
    .reg2_addr_i(rs2),
    .data1_o(regf_o1),
    .data2_o (regf_o2),

    // regsiter file write interface
    .writereg_addr_i(PIP_rd_addr_i),
    .data_i(PIP_rd_data_i),
    .data_write_i(PIP_rd_write_i)
);

// generate immediate
wire [31:0] imm_i = $signed(instruction[31:20]) ;
wire [31:0] imm_s = $signed({instruction[31:25] , instruction[11:7]});
wire [31:0] imm_b = $signed({instruction[31], instruction[7], instruction[30:25] , instruction[11:8]});
wire [31:0] imm_u = {instruction[31:12] , 12'b0}; 
wire [31:0] imm_j = $signed({instruction[31] , instruction[19:12] , instruction[20] , instruction[30:21]});

reg [31:0] current_imm ; // is equal to one of the above according to the current instruction
// decode opcodes


// control signals
reg is_imm ; // if = 1 then use immediate instead of rs2 else use rs2
reg isBranch = 0; // if = 1 then the current instruction is a branch
reg readMem = 0; // if = 1 we need to read from data memory
reg memToReg = 0; //
reg writeMem = 0;
reg aluSrc = 0;
reg writeReg = 0;
reg wb_use_mem = 0; // use memory data out in to write back 
reg [3:0] aluOper = 0;

// set control lines

always@(*)
begin
    is_imm = 0;
    current_imm = 0;
    writeReg = 0;

    case( opcode )
        `LUI: // load upper immediate
        begin
            current_imm = imm_u;
            is_imm = 1;
            writeReg = 1;
        end

        `AUIPC: 
        begin
            current_imm = imm_u;
            $display("unimplemented instruction used");
        end

        `JAL: // jump and link
        begin
            current_imm = imm_j; 
            $display("unimplemented instruction used");
        end

        `JALR: // jump and link register
        begin
            current_imm = imm_i; 
            $display("unimplemented instruction used");
        end

        `LOAD:
        begin
            current_imm = imm_i;
            is_imm = 1;
            writeReg = 1;
        end
        `STORE:
        begin
            current_imm = imm_s;
            is_imm = 1;
        end

        `ARITH:
        begin
            writeReg = 1;
        end

        `ARITH_IMM:
        begin
            current_imm = imm_i ;
            is_imm = 1;
            writeReg = 1;
        end
        `BRANCH:
        begin
            current_imm = imm_b;
        end

        default:
            $display("unsupported instruction used! %d" , opcode );
    endcase
end


// decode for ALU operations from opcodes, could be merged with block above

always@(*)
begin
    aluOper = 0; // does not really matter

    case ( opcode )

        `LOAD:
            aluOper = `ALU_ADD;
        `STORE:
            aluOper = `ALU_ADD;
        `BRANCH:
            aluOper = `ALU_SUB;
        `ARITH,
        `ARITH_IMM:
        begin
            case (func3)
                3'b000:
                begin
                    if ( opcode == `ARITH_IMM )  // only case where we need to differentiate
                        aluOper = `ALU_ADD;
                    else
                    begin
                        aluOper = func7 ? `ALU_SUB : `ALU_ADD ; 
                    end
                end
                
                3'b001: aluOper = `ALU_SLL ; // shift left logical
                3'b010: aluOper = `ALU_SLT ; // set if less than 
                3'b011: aluOper = `ALU_SLTU ; // set if less than unsigned
                3'b100: aluOper = `ALU_XOR ; // XOR
                3'b101: aluOper = ( func7 ) ? `ALU_SRA : `ALU_SRL ; // shift right arithmetic or shift right logical
                3'b110: aluOper = `ALU_OR ; // OR
                3'b111: aluOper = `ALU_AND ; // AND
            endcase
        end
        // `ARITH_IMM:
        // begin
        //     case ( func3 )
        //         3'b000: aluOper = `ALU_ADD; // add or sub
        //         // 3'b001: aluOper = 0; // SLL(I): shift left logical
        //         // 3'b010: aluOper = 0; // SLT(I): Set if less than
        //         // 3'b011: aluOper = 0; //SLTU(I): Set if less than unsigned 
        //         // 3'b100: aluOper = `ALU_XOR; // XOR(I)
        //         // 3'b101: aluOper = 0; // SRL(I): shift right logical
        //         // 3'b110: aluOper = `ALU_OR; // OR(I)
        //         // 3'b111: aluOper = `ALU_AND; // AND(I)
        //     endcase
        // end
    endcase
end

// write to ID/EX pipeline registers

always @(posedge clk)
begin
    if ( !reset_n )
    begin
        PIP_rs1_o <= 0;
        PIP_rs2_o <= 0;
        PIP_rd_o <= 0;

        PIP_operand1_o <= 0;
        PIP_operand2_o <= 0;
        PIP_immediate_o <= 0;
        PIP_aluOper_o <= 0;

        PIP_write_mem_o <= 0;
        PIP_read_mem_o <= 0;

        PIP_use_mem_o <= 0;
        PIP_write_reg_o <= 0 ;
    end
    else
    begin
        PIP_rs1_o <= rs1;
        PIP_rs2_o <= rs2;
        PIP_rd_o <= rd;

        PIP_operand1_o <= regf_o1;
        PIP_operand2_o <= is_imm ? current_imm : regf_o2 ;
        PIP_immediate_o <= current_imm;
        PIP_aluOper_o <= aluOper;

        PIP_write_mem_o <= writeMem;
        PIP_read_mem_o <= readMem;

        PIP_use_mem_o <= wb_use_mem;
        PIP_write_reg_o <= writeReg;
    end
end

endmodule