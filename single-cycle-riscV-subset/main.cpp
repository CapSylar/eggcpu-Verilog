#include <iostream>
#include <stdlib.h>
#include <verilated_vcd_c.h>
#include "verilated.h"
#include "module_tb.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);
	
	Module_tb tb;

	tb.opentrace("logs/vlt_dump.vcd");
	
	while(!tb.done())
		tb.tick();

	tb.close(); // !!! not closing will not generate vcd file

	return EXIT_SUCCESS;
}