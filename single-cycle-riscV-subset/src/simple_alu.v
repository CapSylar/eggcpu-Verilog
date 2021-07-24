// very simple implementation of an ALU
module simple_alu ( clk , control , operand1 , operand2 , result  );

input clk;
input [3:0] control;
input signed [31:0] operand1 , operand2;

output reg [31:0] result /*verilator public*/ ;

always@ ( control )
begin
    result = 0;

    case(control)
        0: result = operand1 & operand2; // AND
        1: result = operand1 | operand1; // OR
        2: result = operand1 + operand2; // ADD
        3: result = operand1 - operand2; // SUB

    default:
        result = 0;
    endcase
end

endmodule