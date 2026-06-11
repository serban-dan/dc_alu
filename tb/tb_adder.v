`timescale 1ns / 1ps

module tb_adder;
    // Inputs (Registers hold values over time)
    reg [7:0] a;
    reg [7:0] b;
    reg       cin;

    // Outputs (Wires connect to the module)
    wire [7:0] sum;
    wire       cout;

    // Instantiate your 8-bit Carry Skip Adder
    carry_skip_adder_8bit uut (
        .a(a), 
        .b(b), 
        .cin(cin), 
        .sum(sum), 
        .cout(cout)
    );

    initial begin
        // --- 1. Setup Waveform Generation ---
        $dumpfile("build/adder_waves.vcd");
        $dumpvars(0, tb_adder); 
        $monitor("Time=%0t | a=%d, b=%d, cin=%b | sum=%d, cout=%b", $time, a, b, cin, sum, cout);

        // --- 2. POWER-ON RESET (Clears the red 'x' states) ---
        a = 8'd0; b = 8'd0; cin = 0;
        #50; // Let the zeros ripple through the entire circuit 

        // --- 3. The Test Vectors ---
        // Test 1: Basic addition (Starts at 50ns now)
        a = 8'd10; b = 8'd5; cin = 0; 
        #50; 

        // Test 2: Triggering the Skip Logic!
        a = 8'd255; b = 8'd0; cin = 1; 
        #50; 

        // Test 3: Mixed ripple and skip (15 + 1)
        a = 8'd15; b = 8'd1; cin = 0; 
        #50;

        // Test 4: Simulating Subtraction (10 - 3)
        a = 8'd10; b = 8'd252; cin = 1; 
        #50;

        $display("Simulation finished successfully.");
        $finish;
    end
endmodule