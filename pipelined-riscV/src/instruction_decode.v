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
    input wire id_flush_i, // flush the local pipeline registers

    // ID/EX pipeline registers ***********************************
    // these below are for the EX stage
    output reg [31:0] PIP_pc_o, // just forward PC
    output reg [31:0] PIP_operand1_o, // rs1
    output reg [31:0] PIP_operand2_o, // rs2
    output reg [31:0] PIP_immediate_o, // extended immediate, TODO: maybe we can get away with not saving it ?\
    output reg [3:0] PIP_aluOper_o, // to determine what operation to use
    output reg PIP_use_imm_o, // for execute stage only
    output reg PIP_use_pc_o, // for execute stage only
    output reg PIP_use_zero, // use zero as rs1

    // for branches and jumps
    output reg [1:0] PIP_bnj_oper_o, // branch and jump operation type
    output reg PIP_is_bnj_o, // indicated whether this is a branch or jump
    output reg PIP_bnj_neg_o, // indicates wether to negate result from alu when evaluating if branch is taken or not

    // below is used to induce a flush

    // these below are for the Memory stage
    output reg PIP_write_mem_o,
    output reg PIP_read_mem_o,

    // these below are for the Write Back stage
    output reg PIP_use_mem_o,
    output reg PIP_write_reg_o, 

    // these below are used are for the forwarding unit and WB stage
    output reg[4:0] PIP_rs1_o, // address of first register operand
    output reg[4:0] PIP_rs2_o, // address of second register operand
    output reg[4:0] PIP_rd_o, // address of destination register


    output reg PIP_TRAP_o // for EBREAK or ECALL
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
wire [31:0] imm_b = $signed({instruction[31], instruction[7], instruction[30:25] , instruction[11:8] , 1'b0 });
wire [31:0] imm_u = {instruction[31:12] , 12'b0};
wire [31:0] imm_j = $signed({instruction[31] , instruction[19:12] , instruction[20] , instruction[30:21] , 1'b0 });


//   wire [31:0] imm_i = {{20{i_data[31]}}, i_data[31:20]};
//   wire [31:0] imm_s = {{20{i_data[31]}}, i_data[31:25], i_data[11:7]};
//   wire [31:0] imm_b = {{19{i_data[31]}}, i_data[31], i_data[7], i_data[30:25], i_data[11:8], 1'b0};
//   wire [31:0] imm_u = {i_data[31:12], 12'b0};
//   wire [31:0] imm_j = {{11{i_data[31]}}, i_data[31], i_data[19:12], i_data[20], i_data[30:21], 1'b0};


reg [31:0] current_imm ; // is equal to one of the above according to the current instruction

// decode opcodes
// control signals
reg is_imm ; // if = 1 then use immediate instead of rs2 else use rs2
reg readMem = 0; // if = 1 we need to read from data memory
reg writeMem = 0;
reg aluSrc = 0;
reg writeReg = 0;
reg wb_use_mem = 0; // use memory data out in to write back 
reg [3:0] aluOper = 0;
reg use_pc; // tell EX stage to use pc instead of rs1, used only for ALUIP
reg use_zero; // set rs1 to zero

// for jumps and branches

reg [1:0] bnj_oper;
reg is_bnj;
reg bnj_neg;

// handle TRAPS , organize this later
reg TRAP;
always @(*)
    TRAP = (instruction == 32'h00000073) || ( instruction == 32'h00100073)  ; // EBREAK or ECALL

// decode
always@(*)
begin
    is_imm = 0;
    current_imm = 0;
    writeReg = 0;
    writeMem = 0;
    wb_use_mem = 0;
    readMem = 0; 
    bnj_oper = 0;
    is_bnj = 0;
    bnj_neg = 0;
    use_pc = 0;
    use_zero = 0;

    case( opcode )
        `LUI: // load upper immediate
        begin
            current_imm = imm_u;
            is_imm = 1;
            writeReg = 1;
            use_zero = 1; // set rs1 to zero
        end

        `AUIPC: 
        begin
            current_imm = imm_u;
            writeReg = 1;
            use_pc = 1;
            is_imm = 1;
        end

        `BRANCH:
        begin
            current_imm = imm_b;
            is_bnj = 1;
            bnj_oper = `BNJ_BRANCH;
        end


        `JAL: // jump and link
        begin
            current_imm = imm_j; 
            is_bnj = 1;
            writeReg = 1;
            bnj_oper = `BNJ_JAL;
            is_imm = 1;
        end

        `JALR: // jump and link register
        begin
            current_imm = imm_i; 
            is_bnj = 1;
            writeReg = 1;
            bnj_oper = `BNJ_JALR;
            is_imm = 1;
        end

        `LOAD:
        begin
            current_imm = imm_i;
            is_imm = 1;
            writeReg = 1;
            readMem = 1;
            wb_use_mem = 1;
        end
        `STORE:
        begin
            current_imm = imm_s;
            is_imm = 1;
            writeMem = 1;
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
        `AUIPC:
            aluOper = `ALU_ADD;
        `BRANCH:
        begin
         case ( func3 )
            3'b000: // BEQ: branch if equal
            begin
                aluOper = `ALU_SEQ;
            end
            3'b001: // BNE: branch if not equal
            begin
                aluOper = `ALU_SEQ;
                bnj_neg = 1;
            end
            3'b100: // BLT: branch if less than
            begin
                aluOper = `ALU_SLT;
            end
            3'b101: // BGE: branch if greater than or equal
            begin
                aluOper = `ALU_SLT;
                bnj_neg = 1;
            end
            3'b110: //BLTU: branch if less than unsigned
            begin
                aluOper = `ALU_SLTU;
            end
            3'b111: //BGEU: branch if greater than unsigned or equal
            begin
                aluOper = `ALU_SLTU;
                bnj_neg = 1;
            end
            endcase 
        end
            
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
    endcase
end

// write to ID/EX pipeline registers

always @(posedge clk)
begin
    if ( !reset_n || id_flush_i )
    begin
        PIP_pc_o <= 0;
        PIP_rs1_o <= 0;
        PIP_rs2_o <= 0;
        PIP_rd_o <= 0;

        PIP_operand1_o <= 0;
        PIP_operand2_o <= 0;
        PIP_immediate_o <= 0;
        PIP_aluOper_o <= 0;
        PIP_use_imm_o <= 0;
        PIP_use_pc_o <= 0 ;
        PIP_use_zero <= 0;

        PIP_write_mem_o <= 0;
        PIP_read_mem_o <= 0;

        PIP_use_mem_o <= 0;
        PIP_write_reg_o <= 0 ;

        // branches and jumps
        PIP_bnj_oper_o <= 0; // branch and jump operation type
        PIP_is_bnj_o <= 0; // indicated whether this is a branch or jump
        PIP_bnj_neg_o <= 0;

        // for TRAPS

        PIP_TRAP_o <= 0 ;
    end
    else if ( !id_stall_i ) // update only in the case where there is no stall
    begin
        PIP_pc_o <= PIP_pc_i;
        PIP_rs1_o <= rs1;
        PIP_rs2_o <= rs2;
        PIP_rd_o <= rd;

        PIP_operand1_o <= regf_o1;
        PIP_operand2_o <= regf_o2;
        PIP_immediate_o <= current_imm;
        PIP_aluOper_o <= aluOper;
        PIP_use_imm_o <= is_imm;
        PIP_use_pc_o <= use_pc;
        PIP_use_zero <= use_zero;

        PIP_write_mem_o <= writeMem;
        PIP_read_mem_o <= readMem;

        PIP_use_mem_o <= wb_use_mem;
        PIP_write_reg_o <= writeReg;

        // branches and jumps
        PIP_bnj_oper_o <= bnj_oper;
        PIP_is_bnj_o <= is_bnj;
        PIP_bnj_neg_o <= bnj_neg ; 

        PIP_TRAP_o <= TRAP;
    end
end

endmodule