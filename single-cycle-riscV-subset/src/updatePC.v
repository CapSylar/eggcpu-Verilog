
module updatePC ( clk , reset_n, isBranch , isZero , immediate , pc );

input clk , reset_n ,isBranch , isZero ;

input [31:0] immediate ; // as it is after joining some fields in the opcode
output reg [31:0] pc;

always@ ( posedge clk or negedge reset_n )
begin
    if ( !reset_n )
        pc <= 0 ;
    else
    begin
        if ( isZero && isBranch ) // branch is taken 
            pc <= pc + { immediate[30:0] , 1'b0 }; // shift left imm then add
            // since branch instruction not store the LSB, we have to add it ourselves
        else        
            pc <= pc + 4;
    end
end

endmodule