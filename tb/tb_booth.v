`timescale 1ns / 1ps

module tb_booth;
    // Sequential Inputs
    reg clk;
    reg rst_n;
    reg start;
    
    // Data Inputs
    reg [7:0] multiplicand;
    reg [7:0] multiplier;

    // Outputs
    wire        done;
    wire [15:0] product;

    // Instantiate the Top-Level Booth Multiplier
    booth_multiplier uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .done(done),
        .product(product)
    );

    // --- CLOCK GENERATOR ---
    // This physically toggles the clock wire every 5ns (10ns total period)
    always #25 clk = ~clk; 

    initial begin
        // Setup Waveform Generation
        $dumpfile("build/booth_waves.vcd");
        $dumpvars(0, tb_booth);

        // --- POWER-ON RESET ---
        clk = 0;
        rst_n = 0; 
        start = 0;
        multiplicand = 8'd0;
        multiplier = 8'd0;
        
        #20; // Hold the system in reset for 2 clock cycles
        rst_n = 1; // Power up the system!
        #10;

        // --- TEST 1: Positive Math (5 x 3 = 15) ---
        // Wait for the exact moment the clock goes high to send the data
        @(posedge clk); 
        multiplicand = 8'd5;
        multiplier = 8'd3;
        start = 1; // Tell the FSM to begin
        
        @(posedge clk); // Wait one clock cycle
        start = 0; // Drop the start flag so it doesn't loop infinitely
        
        wait(done); // Pause the testbench until the FSM says it is finished
        #100; // Wait a moment to observe the final result

        // --- TEST 2: Negative Math (-4 x 6 = -24) ---
        // In 8-bit two's complement, -4 is 11111100 (252)
        // -24 in 16-bit is 1111111111101000 (65512)
        @(posedge clk);
        multiplicand = -8'd4; 
        multiplier = 8'd6;
        start = 1;
        
        @(posedge clk);
        start = 0;
        
        wait(done);
        #100;

        // --- TEST 3: Negative x Negative (-7 x -5 = 35) ---
        @(posedge clk);
        multiplicand = -8'd7; 
        multiplier = -8'd5;
        start = 1;
        
        @(posedge clk);
        start = 0;
        
        wait(done);
        #20;

        $display("Booth sequential simulation finished successfully.");
        $finish;
    end
endmodule