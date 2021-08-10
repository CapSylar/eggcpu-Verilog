`define LUI 7'b0110111
`define AUIPC 7'b0010111
`define JAL 7'b1101111
`define JALR 7'b1100111

`define LOAD 7'b0000011
`define STORE 7'b0100011
`define ARITH_IMM 7'b0010011
`define ARITH 7'b0110011
`define BRANCH 7'b1100011

// ALU operation defs

`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_AND 4'b0010
`define ALU_OR 4'b0011
`define ALU_XOR 4'b0100
`define ALU_SLL 4'b0101
`define ALU_SLT 4'b0111
`define ALU_SRA 4'b1000
`define ALU_SRL 4'b1001
`define ALU_SLTU 4'b1010
`define ALU_SEQ 4'b1011 // set if equal


// Branch and Jump operation types 2-bit , first indicated wether to bypass alu result in Ex stage
// second bit is 0 for relative and 1 for register+PC

`define BNJ_JALR 2'b11
`define BNJ_JAL 2'b10
`define BNJ_BRANCH 2'b00