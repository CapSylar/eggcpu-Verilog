module complete_alu( aluSrc , aluOper , instructionw , readRegister1 , readregister2 , isZero , arithResult ,
        extendedImmediate );

input aluSrc ; // aluSrc = 0, use register2 else use immediate
input [1:0] aluOper ; // alu operation line from control 
input [31:0] instructionw , readRegister1 , readregister2;
output [31:0] arithResult;
output reg [31:0] extendedImmediate; // sign extended immediate
output wire isZero ; 

assign isZero = (arithResult == 32'b0);

wire [2:0] func3 = instructionw[14:12];
wire [6:0] func7 = instructionw[31:25];
wire [6:0] opcode = instructionw[6:0];
reg [3:0] aluControl ;

simple_alu instanciated_alu (  .control(aluControl) , .operand1(readRegister1) ,
.operand2(aluSrc ? extendedImmediate : readregister2 ) , .result(arithResult) );

//decode the immediate
// maybe should be in a separate module ?

always@ (*)
begin
        extendedImmediate = 0; // default
        // sign extend always using bit 31
        extendedImmediate[31:12] = {20{instructionw[31]}} ;

        if ( instructionw[5] == 1'b1 ) // store or branch, do weird decode
        begin
                // 4:1 always same pos
                extendedImmediate[4:1] = instructionw[11:8];
                // 10:5 always in the same pos
                extendedImmediate[10:5] = instructionw[30:25];

                if ( instructionw[6] == 1'b1 ) // branch
                begin
                        extendedImmediate[12:11] = { instructionw[31] , instructionw[7] };
                end
                else // store
                begin
                        extendedImmediate[11] = { instructionw[31] };
                end
        end

        // if load or R with immediate
        else if ( opcode == 7'b0010011 || opcode == 7'b0000011 )
        begin
                // direct map, ez
                extendedImmediate[11:0] = instructionw[31:20] ;
        end
end


// generate 4 bit alu control for simple alu from 2 bit that we get from control module
// 2-bit alu: 00 add , 01 subtract , 10 depends on instructionw
// 00 used for load and store , 01 for beq , 10 for R-type that encode the arithmetic operation
// themselves


always@ (*)
begin
        aluControl = 0;

        case(aluOper)
        2'b00: aluControl = 2 ; // add
        2'b01: aluControl = 3; // sub
        2'b10: // depends on op
        begin
                casez ( {func3,opcode} )
                
                10'b???0000011, 10'b???0100011 : // lw or sw
                        aluControl = 2; // add
                
                10'b???1100011: // beq
                        aluControl = 1 ; //sub
                
                10'b0000010011: // addi
                        aluControl = 2;
                10'b1100010011: // ori
                        aluControl = 1 ;
                
                10'b1110010011: // andi
                        aluControl = 0 ;

                10'b0000110011:
                begin
                        if ( func7 == 0 )
                                aluControl = 2; // add
                        else
                                aluControl = 1; // sub
                end

                10'b1100110011: 
                        aluControl = 1; // or
                10'b1110110011:
                        aluControl = 0 ; // add

                default:
                        aluControl = 0;
                endcase
        end

        default:
                aluControl = 0;
        endcase
end

endmodule