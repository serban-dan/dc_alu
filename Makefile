# Makefile for ALU Project

# --- COMBINATIONAL: Carry Skip Adder ---
adder:
	mkdir -p build
	iverilog -o build/sim_adder.vvp src/*.v src/adder_subtractor/*.v src/logic_ops/*.v tb/tb_adder.v
	vvp build/sim_adder.vvp
	gtkwave build/adder_waves.vcd &

# --- SEQUENTIAL: Booth Multiplier ---
booth:
	mkdir -p build
	iverilog -o build/sim_booth.vvp src/*.v src/adder_subtractor/*.v src/logic_ops/*.v src/booth/*.v tb/tb_booth.v
	vvp build/sim_booth.vvp
	gtkwave build/booth_waves.vcd &

# --- SEQUENTIAL: Non-Restoring Divider ---
div:
	mkdir -p build
	iverilog -o build/sim_div.vvp src/*.v src/adder_subtractor/*.v src/logic_ops/*.v src/divider/*.v tb/tb_divider.v
	vvp build/sim_div.vvp
	gtkwave build/div_waves.vcd &

# --- COMBINATIONAL: Top-Level ALU ---
alu:
	mkdir -p build
	iverilog -o build/sim_alu.vvp src/*.v src/adder_subtractor/*.v src/logic_ops/*.v tb/tb_alu.v
	vvp build/sim_alu.vvp
	gtkwave build/alu_waves.vcd &

# --- CLEANUP ---
clean:
	rm -rf build/*