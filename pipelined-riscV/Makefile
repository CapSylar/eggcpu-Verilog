TEST_PROGRAMS_DIR_PATH = simulation/test-programs
SRC_MODULES = $(shell ls src/* )

sim: testbench.vvp
	@echo "running simulation without trace"
	vvp $<
	@echo "************************"

trace: testbench.vvp
	@echo "running simulation with trace"
	vvp $< +trace 
	@echo "************************"
	@echo "opening gtkwave with savefile"
	gtkwave tb_top_riscV.vcd gtk_signals.gtkw &
	
testbench.vvp: testbench.v $(SRC_MODULES)
	@echo "compiling testbench.v"
	iverilog -Wall -o $@ $< \
		$(SRC_MODULES)  -I src
	@echo "************************"

runall: testbench.vvp
	@echo "running simulation on all tests"
	vvp $< +runall
	@echo "************************"

.PHONY: clean

clean:
	rm -f testbench.vvp
	rm -f tb_top_riscV.vcd

 



