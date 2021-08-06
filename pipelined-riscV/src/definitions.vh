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