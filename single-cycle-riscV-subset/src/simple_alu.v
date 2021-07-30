// very simple implementation of an ALU
module simple_alu ( control , operand1 , operand2 , result  );

input [3:0] control;
input signed [31:0] operand1 , operand2 /*verilator public*/;

output reg [31:0] result /*verilator public*/ ;

always@ (*)
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