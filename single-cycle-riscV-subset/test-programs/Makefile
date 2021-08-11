
memfile : test.s
	riscv32-unknown-elf-as test.s -o riscV.out
	@echo "----------DUMP------------"
	@riscv32-unknown-elf-objdump -d riscV.out
	@echo "---writing to .mem file---" 
	@riscv32-unknown-elf-elf2hex  --bit-width 32 --input riscV.out > test-program.mem

clean:
	@rm convert.out test-program.mem riscV.out

	
