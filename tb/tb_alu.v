`timescale 1ns / 1ps

module tb_alu;

    // Testbench Parameters
    localparam CLK_PERIOD = 50; // 50ns period for gate-level propagation delays

    // DUT Inputs
    reg clk;
    reg reset;
    reg start;
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] opcode;

    // DUT Outputs
    wire [7:0] result;
    wire ready;
    wire Z;
    wire N;
    wire V;

    // Instantiate the DUT (Device Under Test)
    alu_8bit dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .ready(ready),
        .Z(Z),
        .N(N),
        .V(V)
    );

    // Clock Generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Task to run an operation and wait for completion
    task run_operation;
        input [3:0] op;
        input [7:0] opa;
        input [7:0] opb;
        input [7:0] expected_result;
        begin
            @(negedge clk);
            opcode <= op;
            A <= opa;
            B <= opb;
            start <= 1'b1;
            $display("INFO: Starting operation op=%b, A=%d, B=%d", op, $signed(opa), $signed(opb));
            
            @(negedge clk);
            start <= 1'b0;

            // Wait for the ready signal, indicating the operation is complete
            @(posedge ready);
            
            // Check result
            if (result == expected_result) begin
                $display("PASS: Result %d matches expected %d.", $signed(result), $signed(expected_result));
            end else begin
                $error("FAIL: Result %d does not match expected %d.", $signed(result), $signed(expected_result));
            end
            $display("      Flags: Z=%b, N=%b, V=%b\n", Z, N, V);
        end
    endtask

    // Main Test Sequence
    initial begin
        $dumpfile("build/alu_waves.vcd");
        $dumpvars(0, tb_alu);

        // 1. Reset the DUT
        reset <= 1'b1;
        start <= 1'b0;
        A <= 8'h00;
        B <= 8'h00;
        opcode <= 4'h0;
        repeat (2) @(posedge clk);
        reset <= 1'b0;
        $display("\n--- Starting ALU Self-Checking Testbench ---");

        // 2. Run a sequence of tests
        run_operation(4'b0000, 8'd10,   8'd20,   8'd30);   // ADD: 10 + 20 = 30
        run_operation(4'b0001, 8'd50,   8'd15,   8'd35);   // SUB: 50 - 15 = 35
        run_operation(4'b0010, 8'hF0,   8'h0F,   8'h00);    // AND: 11110000 & 00001111 = 0
        run_operation(4'b1000, 8'd7,    8'd8,    8'd56);    // MUL: 7 * 8 = 56 (Sequential)
        run_operation(4'b1000, -8'sd10, 8'sd5,   -8'sd50);  // MUL: -10 * 5 = -50 (Sequential, Signed)
        run_operation(4'b1001, 8'd100,  8'd10,   8'd10);    // DIV: 100 / 10 = 10 (Sequential)
        run_operation(4'b1001, -8'sd20, 8'sd4,   -8'sd5);   // DIV: -20 / 4 = -5 (Sequential, Signed)

        // 3. End Simulation
        #20;
        $display("--- Testbench Finished ---");
        $finish;
    end

endmodule
