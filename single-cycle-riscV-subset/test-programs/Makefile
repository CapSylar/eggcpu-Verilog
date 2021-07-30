
memfile : test.s convert.out
	riscv32-elf-as test.s -o riscV.out
	@echo "----------DUMP------------"
	@riscv32-elf-objdump -d riscV.out
	@echo "---writing to .mem file---" 
	@./convert.out riscV.out test-program.mem

convert.out: convert.cpp
	g++ convert.cpp -I "../../ELFIO" -o convert.out


clean:
	rm convert.out test-program.mem riscV.out

	
