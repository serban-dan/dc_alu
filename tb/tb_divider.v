`timescale 1ns / 1ps

module tb_divider;
    // Sequential Inputs
    reg clk;
    reg rst_n;
    reg start;
    
    // Data Inputs
    reg [7:0] dividend;
    reg [7:0] divisor;

    // Outputs
    wire       done;
    wire [7:0] quotient;
    wire [7:0] remainder;

    // Instantiate the Top-Level Non-Restoring Divider
    non_restoring_divider uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .done(done),
        .quotient(quotient),
        .remainder(remainder)
    );

    // --- CLOCK GENERATOR ---
    always #25 clk = ~clk; // 50ns period

    initial begin
        // Setup Waveform Generation
        $dumpfile("build/div_waves.vcd");
        $dumpvars(0, tb_divider);

        // --- POWER-ON RESET ---
        clk = 0;
        rst_n = 0; 
        start = 0;
        dividend = 8'd0;
        divisor = 8'd0;
        
        #20; 
        rst_n = 1; 
        #10;

        // --- TEST 1: Perfect Division (15 / 3) ---
        // Expected: Quotient = 5, Remainder = 0
        @(posedge clk); 
        dividend = 8'd15;
        divisor = 8'd3;
        start = 1; 
        
        @(posedge clk); 
        start = 0; 
        
        wait(done); 
        #100; 

        // --- TEST 2: Division with a Remainder (27 / 4) ---
        // Expected: Quotient = 6, Remainder = 3
        @(posedge clk);
        dividend = 8'd27; 
        divisor = 8'd4;
        start = 1;
        
        @(posedge clk);
        start = 0;
        
        wait(done);
        #100;

        // --- TEST 3: Larger Numbers (100 / 7) ---
        // Expected: Quotient = 14, Remainder = 2
        @(posedge clk);
        dividend = 8'd100; 
        divisor = 8'd7;
        start = 1;
        
        @(posedge clk);
        start = 0;
        
        wait(done);
        #100;

        $display("Non-Restoring Division simulation finished successfully.");
        $finish;
    end
endmodule
