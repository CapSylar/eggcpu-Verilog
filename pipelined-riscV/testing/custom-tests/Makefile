

all: test.s
	riscv32-unknown-elf-as test.s
	riscv32-unknown-elf-elf2hex --bit-width 32 --input a.out > test.hex

