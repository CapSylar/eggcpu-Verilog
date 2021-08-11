SRC=../src
BASE= /home/robin/fpga-tools
XRAY_UTILS_DIR=${BASE}/prjxray/utils
XRAY_TOOLS_DIR=${BASE}/prjxray/build/tools
XRAY_DATABASE_DIR=${BASE}/prjxray-db

FILES := $(wildcard $(SRC)/*)

synth: ${FILES}
	@echo "****************************************************"
	@echo "synthesizing"
	yosys -p " read_verilog ${FILES} ; synth_xilinx  -arch xc7 -top top_riscV ; write_json riscV.json"

place: synth basys3.xdc
	@echo "****************************************************"
	@echo "place and route"

	${BASE}/nextpnr-xilinx/nextpnr-xilinx --quiet --chipdb ${BASE}/nextpnr-xilinx/xilinx/xc7a35t.bin --xdc basys3.xdc --json riscV.json --write routed_riscV.json --fasm riscV.fasm

upload: synt-pnr
	@echo "*****************************************************"
	@echo "writing xilinx bit file and uploading"
	"${XRAY_UTILS_DIR}/fasm2frames.py" --db-root "${XRAY_DATABASE_DIR}/artix7" --part xc7a35tcpg236-1 design.fasm > design.frames
	"${XRAY_TOOLS_DIR}/xc7frames2bit" --part-file "${XRAY_DATABASE_DIR}/artix7/xc7a35tcpg236-1/part.yaml" --part-name xc7a35tcpg236-1 --frm_file design.frames --output-file top.bit
	openFPGALoader -b basys3 top.bit







