#include <iostream>
#include <stdlib.h>
#include <verilated_vcd_c.h>
#include "verilated.h"
#include "testbench.h"
#include "instructionMem.h"
#include "dataMem.h"

#include "Vtop_riscV.h"
#include "Vtop_riscV_top_riscV.h"


int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);
	auto tb = TESTBENCH<Vtop_riscV>();

	instructionMem instructionMemory;
	dataMem dataMemory;

	tb.opentrace("logs/vlt_dump.vcd");

	tb.m_core->reset_n = 0 ;
	tb.tick();
	tb.m_core->reset_n = 1;

	for ( int i = 0 ; i < 2 ; ++i )
	{
		tb.m_core->instructionW = instructionMemory.readMem(tb.m_core->pc/4);
		tb.tick();
	}
	
	tb.tick();
	tb.tick();

	tb.close(); // !!! not closing will not generate vcd file

	return EXIT_SUCCESS;
}