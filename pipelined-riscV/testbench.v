module tb_top_riscV
#( parameter TEST_PROGRAM_PATH = "testing/custom-tests/test.hex" ) ;

// credit: heavily inspired from this testbench => https://github.com/georgeyhere/Toast-RV32i/blob/main/testbench.v
// define testbenches , riscv-official tests

`define RR_ADD   0
`define RR_SUB   1
`define RR_AND   2
`define RR_OR    3
`define RR_XOR   4
`define RR_SLT   5
`define RR_SLTU  6
`define RR_SLL   7
`define RR_SRL   8
`define RR_SRA   9

// Register-Register
`define RR_ADD   0
`define RR_SUB   1
`define RR_AND   2
`define RR_OR    3
`define RR_XOR   4
`define RR_SLT   5
`define RR_SLTU  6
`define RR_SLL   7
`define RR_SRL   8
`define RR_SRA   9
 
 // Register-Immediate
`define I_ADDI   10
`define I_ANDI   11
`define I_ORI    12
`define I_XORI   13
`define I_SLTI   14
`define I_SLLI   15
`define I_SRLI   16
`define I_SRAI   17
 
 // Conditional Branches
`define B_BEQ    18
`define B_BNE    19
`define B_BLT    20
`define B_BGE    21
`define B_BLTU   22
`define B_BGEU   23

// Upper Immediate
`define UI_LUI   24
`define UI_AUIPC 25

// Jumps
`define J_JAL    26
`define J_JALR   27

// Loads
`define L_LB     28
`define L_LH     29
`define L_LW     30
`define L_LBU    31
`define L_LHU    32

// Stores
`define S_SB     33
`define S_SH     34
`define S_SW     35

parameter TEST_MEMORY_WIDTH = 13 ;
parameter SINGLE_TEST = `RR_ADD; 


// Internal definitions *****

reg clk = 0 ;
reg reset_n = 1;
localparam CLK_PERIOD = 10;
 
wire [31:0] IMEM_addr_o ;
reg [31:0] IMEM_data_i = 0 ;
wire IMEM_read_n_o;
reg [31:0] DMEM_data_i = 0 ;
wire [31:0] DMEM_addr_o ;
wire [31:0]  DMEM_data_o ;

wire DMEM_write_o ;
wire DMEM_read_o ;
wire TRAP;

// ********************************

always #(CLK_PERIOD/2) clk=~clk; // run clock

top_riscV uut
(
    .clk(clk),
    .reset_n(reset_n),
    .IMEM_addr_o(IMEM_addr_o),
    .IMEM_data_i(IMEM_data_i),
    .IMEM_read_n_o(IMEM_read_n_o),
    .DMEM_write_o(DMEM_write_o),
    .DMEM_read_o(DMEM_read_o),
    .DMEM_data_i(DMEM_data_i),
    .DMEM_addr_o(DMEM_addr_o),
    .DMEM_data_o(DMEM_data_o),

    // exception lines
    .TRAP_o(TRAP) // signals an exception
);

// Instruction and Data mmemory
reg [31:0] ram [0:2**TEST_MEMORY_WIDTH-1];

initial begin
end

// essentially a two port ram module
always@( posedge clk )
begin
    if ( !reset_n )
    begin
        IMEM_data_i <= 0;
        DMEM_data_i <= 0 ;
    end
    else
    begin
        if ( !IMEM_read_n_o )
            IMEM_data_i <= ram[IMEM_addr_o[TEST_MEMORY_WIDTH-1:0] >> 2 ];

        if ( DMEM_write_o ) // write to ram 
            ram[DMEM_addr_o[TEST_MEMORY_WIDTH-1:0] >> 2 ] <= DMEM_data_o;
        else if ( DMEM_read_o ) // read from ram
            DMEM_data_i <= ram[DMEM_addr_o[TEST_MEMORY_WIDTH-1:0] >> 2 ]; 
    end
end



task load_test;
    input integer index;
    begin
        reset_n = 0 ;
        #20; // 2 cycles

        case(index)
            `RR_ADD: $readmemh( "testing/build-files/add.S.hex" , ram );
            `RR_SUB: $readmemh( "testing/build-files/sub.S.hex" , ram );
            `RR_AND: $readmemh( "testing/build-files/and.S.hex" , ram );
            `RR_OR: $readmemh( "testing/build-files/or.S.hex" , ram );
            `RR_XOR: $readmemh( "testing/build-files/xor.S.hex" , ram );
            `RR_SLT: $readmemh( "testing/build-files/slt.S.hex" , ram );
            `RR_SLTU: $readmemh( "testing/build-files/sltu.S.hex" , ram );
            `RR_SLL: $readmemh( "testing/build-files/sll.S.hex" , ram );
            `RR_SRL: $readmemh( "testing/build-files/srl.S.hex" , ram );
            `RR_SRA: $readmemh( "testing/build-files/sra.S.hex" , ram );
        endcase

        $display("Loading testfile with ID => %0d ", index );
    end 
endtask

integer t;
task eval_result;
    input integer index;
    begin
        reset_n = 1;
        // wait some delay before declaring failed
        for(t=0;t<=100000;t=t+1)
        begin
            @(posedge clk)
            begin
                // $display("tick count = %0d" , t );

                if ( uut.inst_instruction_decode.inst_reg_file.registerFile[3] == 1 &&
                uut.inst_instruction_decode.inst_reg_file.registerFile[17] == 93 && 
                uut.inst_instruction_decode.inst_reg_file.registerFile[10] == 0  )
                begin
                    $display("[TEST PASSED] => TEST-ID : %0d" , index );
                    t = 100000;     // stop
                end
                else if ( TRAP )
                begin
                    $display("[TEST FAILED] EXCEPTION OCCURED! => TEST-ID : %0d " , index );
                    $display("x3 = %0d, x17 = %0d, x10 = %0d" , uut.inst_instruction_decode.inst_reg_file.registerFile[3] , uut.inst_instruction_decode.inst_reg_file.registerFile[17] , uut.inst_instruction_decode.inst_reg_file.registerFile[10] ) ; 
                    $finish;
                end
                else if ( t >= 99900 )
                begin
                    $display("[TEST FAILED] TIMED OUT => TEST-ID : %0d ", index);
                    $finish;
                end
            end
        end
    end
endtask

initial begin
    if ($test$plusargs("trace"))
    begin
        $dumpfile("tb_top_riscV.vcd");
        $dumpvars(0, tb_top_riscV);
    end
end

integer test_index;

initial 
begin
    reset_n <= 0;
    #50;

    if ( $test$plusargs("runall")) // run multiple tests
    begin
        $display("running all tests");

        for ( test_index = `RR_ADD ; test_index <= `RR_SRA ; test_index=test_index+1 )
        begin
            $display("*************");
            $display("Running test %d" , test_index );
            load_test(test_index);
            #50;
            eval_result(test_index);
        end
        
        $display("**************************");
        $display("All Tests finished!");
        $finish;
    end
    else // run single test
    begin
        $display("Running in single test mode");
        $display("Running Test TEST-ID : %d" ,SINGLE_TEST );
        load_test(SINGLE_TEST);
        eval_result(SINGLE_TEST);
        $finish;
    end
end
endmodule
