#include <stdio.h>
#include "testbench.h"
#include "Vtop_riscV.h"
#include "Vtop_riscV_top_riscV.h"
#include "instructionMem.h"
#include "dataMem.h"
#include "Vtop_riscV_complete_alu.h"
#include "Vtop_riscV_simple_alu.h"
#include "Vtop_riscV_reg_file.h"

class Module_tb : public TestBench<Vtop_riscV>
{
public:
    bool writeOut = false;
    bool program_fin = false;
    instructionMem instruction_mem; 
    dataMem data_mem ;

    Module_tb( bool writeOut = true ) : writeOut(writeOut) , instruction_mem("test-programs/a.out")
    {
        // instruction_mem = instructionMem("test-programs/a.out");
        m_core->reset_n = 0;
        tick();
        m_core->reset_n = 1;
    };

    void tick() override
    {
        printf("tick %d " , m_tickcount);
        uint32_t iW = instruction_mem.readMem(m_core->pc);

        m_core->instructionW = iW ;
        TestBench<Vtop_riscV>::tick();

        if ( m_core->data_mem_read )
            m_core->data_mem_read_data = data_mem.readMem(m_core->data_mem_address) ;
        
        if ( m_core->data_mem_write )
            data_mem.writeMem( m_core->data_mem_address , m_core->data_mem_data_write );

        if ( writeOut )
        {
            dump_state();
        }  
        
        // mem loc 0 is read by the test harness after every clock cycle, if
        //it contains a value other than 0 the simulation halts

        printf("read from 0 0x%02x\n" , data_mem.readMem(0));
        if ( data_mem.readMem(0) != 0 )
            program_fin = true; 
    }

    bool done() override
    {
         return (Verilated::gotFinish() || (program_fin) || m_tickcount == 15 ); 
    }


    void dump_state()
    {
        printf( "PC = 0x%08x IW = 0x%08x\n" , m_core->pc , m_core->instructionW );
        
        for ( int i = 0 ; i < 10 ; ++i )
            printf("x%d: 0x%08x  " , i , m_core->top_riscV->instance_reg_file->registerFile[i] );
        printf("\n");
    }
 
};