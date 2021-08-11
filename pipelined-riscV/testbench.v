module tb_top_riscV
#( parameter TEST_PROGRAM_PATH = "testing/custom-tests/test.hex" ) ;

// credit: heavily inspired from this testbench => https://github.com/georgeyhere/Toast-RV32i/blob/main/testbench.v
// define testbenches , riscv-official tests

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

// TESTBENCH PARAMETERS
parameter TEST_MEMORY_WIDTH = 13 ;
parameter SINGLE_TEST = `S_SB; 
parameter TEST_TIME_MAX_TICKS = 100000;
parameter START_INDEX = `RR_ADD ;
parameter END_INDEX = `S_SW ;


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

wire [3:0] DMEM_byte_en ;
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
    .DMEM_write_byte_o(DMEM_byte_en),
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

wire [31:0] DMEM_addr = DMEM_addr_o[TEST_MEMORY_WIDTH-1:0] >> 2;
wire [31:0] IMEM_addr = IMEM_addr_o[TEST_MEMORY_WIDTH-1:0] >> 2;
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
            IMEM_data_i <= ram[IMEM_addr];

        if (DMEM_byte_en[0])
            ram[DMEM_addr][7:0] <= DMEM_data_o[7:0];
        if ( DMEM_byte_en[1] )
            ram[DMEM_addr][15:8] <= DMEM_data_o[15:8];
        if (DMEM_byte_en[2])
            ram[DMEM_addr][23:16] <= DMEM_data_o[23:16];
        if ( DMEM_byte_en[3] )
            ram[DMEM_addr][31:24] <= DMEM_data_o[31:24];

        if( DMEM_read_o ) // read from ram
            DMEM_data_i <= ram[DMEM_addr]; 
    end
end



task load_test;
    input integer index;
    begin
        reset_n = 0 ;
        #20; // 2 cycles

        case(index)


            //********* Register register instructions
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

            //*********** register Immediate instructions

            `I_ADDI: $readmemh( "testing/build-files/addi.S.hex" , ram );
            `I_ANDI: $readmemh( "testing/build-files/andi.S.hex" , ram );
            `I_ORI: $readmemh( "testing/build-files/ori.S.hex" , ram );
            `I_XORI: $readmemh( "testing/build-files/xori.S.hex" , ram );
            `I_SLTI: $readmemh( "testing/build-files/slti.S.hex" , ram );
            `I_SLLI: $readmemh( "testing/build-files/slli.S.hex" , ram );
            `I_SRLI: $readmemh( "testing/build-files/srli.S.hex" , ram );
            `I_SRAI: $readmemh( "testing/build-files/srai.S.hex" , ram );

            //************ conditional branch instructions

            `B_BEQ: $readmemh( "testing/build-files/beq.S.hex" , ram );
            `B_BNE: $readmemh( "testing/build-files/bne.S.hex" , ram );
            `B_BLT: $readmemh( "testing/build-files/blt.S.hex" , ram );
            `B_BGE: $readmemh( "testing/build-files/bge.S.hex" , ram );
            `B_BLTU:$readmemh( "testing/build-files/bltu.S.hex" , ram );
            `B_BGEU:$readmemh( "testing/build-files/bgeu.S.hex" , ram );

            //************ upper immediate instructions

            `UI_LUI: $readmemh( "testing/build-files/lui.S.hex" , ram );
            `UI_AUIPC: $readmemh( "testing/build-files/auipc.S.hex" , ram );

            //************ Jump and link instructions
            `J_JAL: $readmemh( "testing/build-files/jal.S.hex" , ram );
            `J_JALR: $readmemh( "testing/build-files/jalr.S.hex" , ram );

            //************  Load instructions

           `L_LB:  $readmemh( "testing/build-files/lb.S.hex" , ram );
           `L_LH:  $readmemh( "testing/build-files/lh.S.hex" , ram );
           `L_LW:  $readmemh( "testing/build-files/lw.S.hex" , ram );
           `L_LBU: $readmemh( "testing/build-files/lbu.S.hex" , ram );
           `L_LHU: $readmemh( "testing/build-files/lhu.S.hex" , ram );

            //************ Store instructions

            `S_SB:$readmemh( "testing/build-files/sb.S.hex" , ram );
            `S_SH:$readmemh( "testing/build-files/sh.S.hex" , ram );
            `S_SW:$readmemh( "testing/build-files/sw.S.hex" , ram );

        endcase

        $display("Loading testfile with ID => %0d ", index );
    end 
endtask

integer t;
task eval_result;
    input integer index;
    output integer result;
    begin
        reset_n = 1;
        // wait some delay before declaring failed
        result = 0; 
        for(t=0;t<=TEST_TIME_MAX_TICKS;t=t+1)
        begin
            @(posedge clk)
            begin
                // $display("tick count = %0d" , t );

                if ( uut.inst_instruction_decode.inst_reg_file.registerFile[3] == 1 &&
                uut.inst_instruction_decode.inst_reg_file.registerFile[17] == 93 && 
                uut.inst_instruction_decode.inst_reg_file.registerFile[10] == 0  )
                begin
                    result = 1; // test passed
                    $display("[TEST PASSED] => TEST-ID : %0d" , index );
                    $display("Program Counter stopped at => %0x " , uut.IF_ID_pc );
                    t = TEST_TIME_MAX_TICKS;     // stop
                end
                else if ( TRAP )
                begin
                    $display("[TEST FAILED] EXCEPTION OCCURED! => TEST-ID : %0d " , index );
                    $display("x3 = %0d, x17 = %0d, x10 = %0d" , uut.inst_instruction_decode.inst_reg_file.registerFile[3] , uut.inst_instruction_decode.inst_reg_file.registerFile[17] , uut.inst_instruction_decode.inst_reg_file.registerFile[10] ) ; 
                    t = TEST_TIME_MAX_TICKS;     // stop

                end 
                else if ( t >= TEST_TIME_MAX_TICKS-1  ) // just before hitting the maximum 
                begin
                    $display("[TEST FAILED] TIMED OUT => TEST-ID : %0d ", index);
                    t = TEST_TIME_MAX_TICKS;     // stop
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

integer test_index = 0;
integer num_passed = 0;
integer num_failed = 0;
integer current = 0;
initial 
begin
    reset_n <= 0;
    #50;

    if ( $test$plusargs("runall")) // run multiple tests
    begin
        $display("running all tests");

        for ( test_index = START_INDEX ; test_index <= END_INDEX ; test_index=test_index+1 )
        begin
            $display("*************");
            $display("Running test %d" , test_index );
            load_test(test_index);
            #50;
            eval_result(test_index , current );
            num_passed = num_passed + current;
            if ( !current )
                num_failed = num_failed + 1;
        end
        
        $display("**************************");
        $display("Tests passed: %0d" , num_passed );
        $display("Tests failed: %0d" , num_failed );
        $finish;
    end
    else // run single test
    begin
        $display("Running in single test mode");
        $display("Running Test TEST-ID : %d" ,SINGLE_TEST );
        load_test(SINGLE_TEST);
        eval_result(SINGLE_TEST , current );
        $finish;
    end
end
endmodule
