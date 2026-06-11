# **8-Bit Structural ALU & Processor Datapath**

## **Project Overview**

This project implements a fully functional, gate-level accurate 8-bit Arithmetic Logic Unit (ALU) alongside dedicated sequential datapath cores for multiplication and division. Rather than using high-level behavioral math synthesis, the arithmetic cores are built from scratch using structural logic gates with simulated \#1 (1 nanosecond) propagation delays to accurately model physical silicon behavior and electrical timing.

## **Supported Operations**

The combinational ALU supports:

1. Addition  
2. Subtraction  
3. AND  
4. OR  
5. XOR  
6. Logical Shift Left (LSL)  
7. Logical Shift Right (LSR)  
8. Pass A

The sequential execution units support:

1. Multiplication (Signed 2's Complement)  
2. Division (Signed/Unsigned)

## **Used Algorithms**

* **Addition / Subtraction** \-\> 2-bit Block Carry Skip Adder (CSkA)  
* **Multiplication** \-\> Booth's Algorithm (Sequential Moore FSM)  
* **Division** \-\> Non-Restoring Division (Sequential FSM)

## **Top-Level ALU Interface**

**Top module:** alu\_8bit

| Signal | Direction | Width | Description |
| :---- | :---- | :---- | :---- |
| A | input | 8 | First operand |
| B | input | 8 | Second operand |
| opcode | input | 3 | Operation select |
| result | output | 8 | Selected result |
| Z | output | 1 | Zero Flag: Set when result is exactly zero |
| N | output | 1 | Negative Flag: Set when result\[7\] is one |
| V | output | 1 | Overflow Flag: Set on signed arithmetic overflow |

## **Operation Select (Opcode)**

| opcode | Operation |
| :---- | :---- |
| 000 | Addition |
| 001 | Subtraction |
| 010 | Bitwise AND |
| 011 | Bitwise OR |
| 100 | Bitwise XOR |
| 101 | Logical Shift Left (LSL) |
| 110 | Logical Shift Right (LSR) |
| 111 | Pass A (B is ignored) |

## **Project Structure**

Plaintext  
.  
├── Makefile  
├── build/                 \# Compiled VVP binaries and VCD waveforms  
├── src/  
│   ├── adder\_subtractor/  \# Carry Skip Adder and primitive Full Adders  
│   ├── booth/             \# FSM, datapath, and wrapper for Booth Multiplier  
│   ├── divider/           \# FSM, datapath, and wrapper for Non-Restoring Divider  
│   ├── logic\_ops/         \# Combinational bitwise gates and shifters  
│   ├── gates.v            \# Base structural primitives with \#1ns delays  
│   ├── shift\_register\_8bit.v \# Universal register for sequential algorithms  
│   └── alu\_8bit.v         \# Top-level combinational ALU wrapper  
└── tb/  
    ├── tb\_adder.v         \# Adder verification  
    ├── tb\_alu.v           \# Self-checking ALU testbench  
    ├── tb\_booth.v         \# Sequential multiplier testbench  
    └── tb\_divider.v       \# Sequential divider testbench

## **Hardware Notes & Architecture**

* **Structural Gate Delays:** All primitive logic gates (and2\_gate, xor2\_gate, etc.) include a \#1 nanosecond physical propagation delay. This accurately simulates "Zero-Delay Racing" and requires testbenches to use an underclocked 50ns period to allow logic ripples to settle before flip-flops capture data.  
* **Carry Skip Adder (CSkA):** Replaces standard $O(N)$ Ripple Carry Adders. The 8-bit core is divided into 2-bit blocks with AND-OR skip logic dynamically evaluating the propagate (p) bits to bypass the ripple chain. Subtraction natively reuses this hardware by inverting B via an XOR array and asserting cin.  
* **Sequential Multiplier:** Uses a dedicated datapath isolated from the main ALU to save multiplexing complexity. A Moore-style FSM executes Booth's algorithm natively handling negative numbers using universal arithmetic shift registers (ASR).  
* **Sequential Divider:** Reuses the physical register architecture (A, Q, M) of the multiplier. The FSM performs exactly one arithmetic operation (Add or Sub) per clock cycle based on the dynamic sign evaluation of the remainder register, avoiding trial-and-error subtraction bottlenecks.

## **Toolchain Setup**

This project uses standard open-source verification tools. Ensure the following are installed:

* **Icarus Verilog** (iverilog, vvp)  
* **GTKWave** (for waveform viewing)

## **Simulation & Testing Commands**

The project includes an automated Makefile for compiling, executing, and viewing the hardware tests.  
**Run the Combinational ALU Self-Checking Testbench:**

Bash  
make alu

**Run the Booth Multiplier Simulation:**

Bash  
make booth

**Run the Non-Restoring Divider Simulation:**

Bash  
make div

**Clean build artifacts:**

Bash  
make clean  
