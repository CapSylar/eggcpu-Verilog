#!/bin/bash

INCLUDE_DIR="include"
SOURCES_DIR="rv32ui"
BUILD_DIR="../build-files"

FILES=`ls ${SOURCES_DIR}/*.S`

#instruction start = 0x00000000
#data start = 0x00001000

if [ ! -d "${BUILD_DIR}" ]
then
	echo "build-tests does not existing... creating!"
	mkdir "${BUILD_DIR}"
fi

for eachfile in $FILES
do
	eachfile=${eachfile##*/}
	riscv32-unknown-elf-gcc -c "${SOURCES_DIR}/${eachfile}" -I "${INCLUDE_DIR}/" -o "${BUILD_DIR}/${eachfile}.o"
	riscv32-unknown-elf-ld  "${BUILD_DIR}/${eachfile}.o" -Ttext 0x00000000 -Tdata 0x00001000 -o "${BUILD_DIR}/${eachfile}.out"
	riscv32-unknown-elf-elf2hex --bit-width 32 --input "${BUILD_DIR}/${eachfile}.out" > "${BUILD_DIR}/${eachfile}.hex"

	echo "done ${eachfile}"
done

