module controller ( instruction , isBranch , isBeq , readMem , memToReg , writeMem ,
         aluSrc , writeReg , aluOper );

input wire [31:0] instruction;

output reg [1:0] aluOper ; 
output reg isBranch , isBeq , readMem , memToReg , writeMem , aluSrc , writeReg ;

wire [6:0] opcode = instruction[6:0];
wire [2:0] func3 = instruction[14:12];

always@(*)
begin
    isBranch = 0;
    readMem = 0;
    memToReg = 0;
    aluOper = 0;
    writeMem = 0;
    aluSrc = 0;
    writeReg = 0;
    isBeq = 0;

    case(opcode)
        7'b1100011: // branch
        begin
            isBranch = 1;
            aluOper = 2'b01;
            isBeq = (func3 == 3'b0) ; // 1 for beq , 0 for bne
        end
        7'b0000011: // load
        begin
            writeReg = 1;
            memToReg = 1;
            aluSrc = 1;
            aluOper = 0; 
            readMem = 1;
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