
module updatePC ( clk , reset_n, isBranch , isBeq , isZero , immediate , pc );

input clk , reset_n ,isBranch , isZero , isBeq ;

input [31:0] immediate ; // as it is after joining some fields in the opcode
output reg [31:0] pc;

always@ ( posedge clk ) 
begin
    if ( !reset_n )
        pc <= 0 ;
    else
begin
        if ( isBranch && ((isZero && isBeq) || (!isZero && !isBeq))) // branch is taken 
            pc <= pc + immediate; // shift left imm is already done while decoding
            // since branch instruction not store the LSB, we have to add it ourselves
        else        
            pc <= pc + 4;
    end
end

endmodule