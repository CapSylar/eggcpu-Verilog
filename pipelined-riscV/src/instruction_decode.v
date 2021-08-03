`include "definitions.vh"

module instruction_decode
(
    input clk,
    input reset_n,
    input wire [31:0] instruction, // from IF stage
    input wire [4:0] rd_addr, // register file address to write to
    input wire [31:0] rd_data, // data to write to
    input wire regs_write // control line for register file writes

    // output wire isBranch,
    // output wire readMem,
    // output wire memToReg,
    // output wire aluOper,
    // output wire writeMem,
    // output wire aluSrc,
    // output wire writeReg
);

wire [31:0] regf_o1, regf_o2 ; 

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
    .writereg_addr_i(rd_addr),
    .data_i(rd_data),
    .data_write_i(regs_write)
);

//pipeline registers
// we need to save rs1, rs2 and rsd for later use

reg [4:0] pip_rs1, pip_rs2 , pip_rsd;
reg [31:0] pip_operand1 , pip_operand2;

always@( posedge clk )
begin
    if ( !reset_n )
    begin
        pip_rs1 <= 0;
        pip_rs2 <= 0;
        pip_rsd <= 0;
        pip_operand1 <= 0;
        pip_operand2 <= 0;
    end
    else
    begin
        
    end

end

// generate immediate

wire [31:0] imm_i = $signed(instruction[31:20]) ;
wire [31:0] imm_s = $signed({instruction[31:25] , instruction[11:7]});
wire [31:0] imm_b = $signed({instruction[31], instruction[7], instruction[30:25] , instruction[11:8]});
wire [31:0] imm_u = $signed({instruction[31:12]});
wire [31:0] imm_j = $signed({instruction[31] , instruction[19:12] , instruction[20] , instruction[30:21]});

reg [31:0] current_imm ; // is equal to one of the above according to the current instruction
// decode opcodes


// control signals
reg is_imm ; // if = 1 then use immediate instead of rs2 else use rs2
wire isBranch = 0; // if = 1 then the current instruction is a branch
wire readMem = 0; // if = 1 we need to read from data memory
wire memToReg = 0; //
wire aluOper = 0;
wire writeMem = 0;
wire aluSrc = 0;
wire writeReg = 0;

always@(*)
begin
    is_imm = 0;
    current_imm = 0;

    case( opcode )
        `LUI: // load upper immediate
        begin
            current_imm = imm_u;
        end

        `AUIPC: 
        begin
            current_imm = imm_u;
            
        end

        `JAL: // jump and link
        begin
            current_imm = imm_j; 

        end

        `JALR: // jump and link register
        begin
            current_imm = imm_i; 

        end

        `LOAD:
        begin
            current_imm = imm_i;
            is_imm = 1;
        end
        `STORE:
        begin
            current_imm = imm_s;
            is_imm = 1;
        end
        `ARITH:
        begin
            
        end
        `ARITH_IMM:
        begin
            current_imm = imm_i ;
            is_imm = 1;
        end
        `BRANCH:
        begin
            current_imm = imm_b;
        end

        default:
            $display("unsupported instruction used!");
    endcase
end


// write to ID/EX pipeline registers

always @(posedge clk)
begin
    if ( !reset_n )
    begin
        pip_rs1 <= 0;
        pip_rs2 <= 0;
        pip_operand1 <= 0;
        pip_operand2 <= 0;
    end
    else
    begin
        pip_rs1 <= rs1;
        pip_rs2 <= rs2;
        pip_rsd <= rd;
        pip_operand1 <= regf_o1;
        pip_operand2 <= is_imm ? current_imm : regf_o2 ;
    end
end

endmodule