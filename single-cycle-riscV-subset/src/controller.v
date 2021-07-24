module controller ( clk , reset_n , opcode , isBranch , readMem , memToReg , writeMem ,
         aluSrc , writeReg , aluOper );

input clk , reset_n ;
input [6:0] opcode;

output reg [1:0] aluOper ; 
output reg isBranch , readMem , memToReg , writeMem , aluSrc , writeReg ;


always@( posedge clk )
begin
    isBranch = 0;
    readMem = 0;
    memToReg = 0;
    aluOper = 0;
    writeMem = 0;
    aluSrc = 0;
    writeReg = 0;

    case(opcode)
    7'b1100011: // branch
        isBranch = 1;
    7'b0000011: // load
    begin
        writeReg = 1;
        memToReg = 1;
        aluSrc = 1;
        aluOper = 0; 
    end
    7'b0100011: // store
    begin
        aluSrc = 1;
        writeMem = 1;
        aluOper = 0;
    end
    7'b0010011: // R-type operations immediate
    begin
        aluSrc = 1;
        writeReg = 1;
        aluOper = 2'b10; 
    end
    7'b0110011: // R-type normal
    begin
        writeReg = 1;
        aluOper = 2'b10;
    end

    default:
    begin
        
    end

    endcase
end


endmodule;