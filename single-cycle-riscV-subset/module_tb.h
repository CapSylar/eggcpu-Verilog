#include <stdio.h>
#include "testbench.h"
#include "Vtop_tb.h"
#include "Vtop_tb_top_tb.h"
#include "Vtop_tb_riscV.h"
#include "Vtop_tb_data_memory.h"
#include "Vtop_tb_reg_file.h"

class Module_tb : public TestBench<Vtop_tb>
{
public:
    bool writeOut = false;
    bool program_fin = false;

    Module_tb( bool writeOut = true ) : writeOut(writeOut) 
    {
        // instruction_mem = instructionMem("test-programs/a.out");
        m_core->reset_n = 0;
        TestBench<Vtop_tb>::tick();
        m_core->reset_n = 1;
    };

    void tick() override
    {
        printf("tick %d " , m_tickcount);

        if ( writeOut )
        {
            dump_state();
        }  

        TestBench<Vtop_tb>::tick();
        
        // mem loc 0 is read by the test harness after every clock cycle, if
        //it contains a value other than 0 the simulation halts

        const auto value = m_core->top_tb->inst_data_memory->mem[0] ; 
        printf("read from [0] = 0x%02x\n" , value );
        if ( value )
            program_fin = true;
    }

    bool done() override
    {
        if (Verilated::gotFinish() || program_fin ) // done
        {
            if ( writeOut ) dump_state() ; // dump a final time before exiting!
            // print exit status stored at location [1]
            printf("exited with code %d\n" , m_core->top_tb->inst_data_memory->mem[4] );
            return true;
        }
         
        return false;
    }

    void dump_state()
    {
        printf( "PC = 0x%08x IW = 0x%08x\n" , m_core->top_tb->__Vtogcov__pc , m_core->top_tb->__Vtogcov__rom_data_out  );
        
        for ( int i = 0 ; i < 10 ; ++i )
            printf("x%d: 0x%08x  " , i , m_core->top_tb->eggcpu->instance_reg_file->registerFile[i] );
        printf("\n");
    }
 
};