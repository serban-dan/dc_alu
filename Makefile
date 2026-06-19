# Makefile for ALU Project

# Define source files by recursively finding all .v files in the src directory.
# This is more robust than listing each subdirectory manually.
VERILOG_SOURCES = $(shell find src -name '*.v')

# --- COMBINATIONAL: Carry Skip Adder ---
adder:
	mkdir -p build
	iverilog -o build/sim_adder.vvp $(VERILOG_SOURCES) tb/tb_adder.v
	vvp build/sim_adder.vvp
	gtkwave build/adder_waves.vcd &

# --- SEQUENTIAL: Booth Multiplier ---
booth:
	mkdir -p build
	iverilog -o build/sim_booth.vvp $(VERILOG_SOURCES) tb/tb_booth.v
	vvp build/sim_booth.vvp
	gtkwave build/booth_waves.vcd &

# --- SEQUENTIAL: Non-Restoring Divider ---
div:
	mkdir -p build
	iverilog -o build/sim_div.vvp $(VERILOG_SOURCES) tb/tb_divider.v
	vvp build/sim_div.vvp
	gtkwave build/div_waves.vcd &

# --- COMBINATIONAL: Top-Level ALU ---
alu:
	mkdir -p build
	iverilog -o build/sim_alu.vvp $(VERILOG_SOURCES) tb/tb_alu.v
	vvp build/sim_alu.vvp
	#gtkwave build/alu_waves.vcd &

comprehensive:
	mkdir -p build
	iverilog -o build/sim_alu.vvp $(VERILOG_SOURCES) tb/tb_alu2.v
	vvp build/sim_alu.vvp
	#gtkwave build/alu_waves.vcd &

# --- CLEANUP ---
clean:
	rm -rf build/*
