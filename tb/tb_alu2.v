`timescale 1ns / 1ps

module tb_alu;

    // Testbench Parameters
    localparam CLK_PERIOD = 50;

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

    // Test Statistics Trackers
    integer tests_passed = 0;
    integer tests_failed = 0;

    // Opcodes
    localparam OP_ADD = 4'b0000;
    localparam OP_SUB = 4'b0001;
    localparam OP_AND = 4'b0010;
    localparam OP_OR  = 4'b0011;
    localparam OP_XOR = 4'b0100;
    localparam OP_LSL = 4'b0101;
    localparam OP_LSR = 4'b0110;
    localparam OP_PAS = 4'b0111;
    localparam OP_MUL = 4'b1000;
    localparam OP_DIV = 4'b1001;

    // Instantiate the DUT
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

    // Upgraded Task: Checks result AND all three flags
    task run_operation;
        input [3:0] op;
        input [7:0] opa;
        input [7:0] opb;
        input [7:0] exp_res;
        input exp_Z;
        input exp_N;
        input exp_V;
        
        reg flag_error;
        begin
            @(negedge clk);
            opcode <= op;
            A <= opa;
            B <= opb;
            start <= 1'b1;
            
            @(negedge clk);
            start <= 1'b0; // Drop start so FSM can finish
            
            wait(ready == 1'b1);
            @(negedge clk); // Give data one cycle to settle on wires

            flag_error = (Z !== exp_Z) || (N !== exp_N) || (V !== exp_V);

            if ((result === exp_res) && !flag_error) begin
                $display("  [PASS] OP=%b | A=%4d, B=%4d | Res=%4d | Flags: Z=%b N=%b V=%b", 
                          op, $signed(opa), $signed(opb), $signed(result), Z, N, V);
                tests_passed = tests_passed + 1;
            end else begin
                $display("  [FAIL] OP=%b | A=%4d, B=%4d", op, $signed(opa), $signed(opb));
                if (result !== exp_res)
                    $display("         -> Result Mismatch: Got %4d, Expected %4d", $signed(result), $signed(exp_res));
                if (flag_error)
                    $display("         -> Flag Mismatch: Got Z=%b N=%b V=%b | Expected Z=%b N=%b V=%b", Z, N, V, exp_Z, exp_N, exp_V);
                tests_failed = tests_failed + 1;
            end
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
        
        $display("\n=======================================================");
        $display("   ALU EXHAUSTIVE TESTBENCH (EDGE CASES & FLAGS)");
        $display("=======================================================\n");

        // ----------------------------------------------------------------
        // 1. ADDITION
        // ----------------------------------------------------------------
        $display("--- ADDITION ---");
        run_operation(OP_ADD,  8'd10,   8'd20,   8'd30,   0, 0, 0); 
        run_operation(OP_ADD, -8'd15,   8'd15,   8'd0,    1, 0, 0); 
        run_operation(OP_ADD,  8'd127,  8'd1,   -8'd128,  0, 1, 1); 
        run_operation(OP_ADD, -8'd128, -8'd1,    8'd127,  0, 0, 1); 

        // ----------------------------------------------------------------
        // 2. SUBTRACTION
        // ----------------------------------------------------------------
        $display("\n--- SUBTRACTION ---");
        run_operation(OP_SUB,  8'd50,   8'd15,   8'd35,   0, 0, 0); 
        run_operation(OP_SUB,  8'd15,   8'd50,  -8'd35,   0, 1, 0); 
        run_operation(OP_SUB,  8'd127, -8'd1,   -8'd128,  0, 1, 1); 
        run_operation(OP_SUB, -8'd128,  8'd1,    8'd127,  0, 0, 1); 

        // ----------------------------------------------------------------
        // 3. LOGICAL AND
        // ----------------------------------------------------------------
        $display("\n--- LOGICAL AND ---");
        run_operation(OP_AND,  8'hFF,   8'h00,   8'h00,   1, 0, 0); 
        run_operation(OP_AND,  8'hA5,   8'hF0,   8'hA0,   0, 1, 0); 

        // ----------------------------------------------------------------
        // 4. LOGICAL OR
        // ----------------------------------------------------------------
        $display("\n--- LOGICAL OR ---");
        run_operation(OP_OR,   8'h00,   8'h00,   8'h00,   1, 0, 0); 
        run_operation(OP_OR,   8'h55,   8'hAA,   8'hFF,   0, 1, 0); 

        // ----------------------------------------------------------------
        // 5. LOGICAL XOR
        // ----------------------------------------------------------------
        $display("\n--- LOGICAL XOR ---");
        run_operation(OP_XOR,  8'hFF,   8'hFF,   8'h00,   1, 0, 0); 
        run_operation(OP_XOR,  8'h0F,   8'hF0,   8'hFF,   0, 1, 0); 

        // ----------------------------------------------------------------
        // 6. LOGICAL SHIFT LEFT 
        // ----------------------------------------------------------------
        $display("\n--- LOGICAL SHIFT LEFT ---");
        run_operation(OP_LSL,  8'h01,   8'd3,    8'h08,   0, 0, 0); 
        run_operation(OP_LSL,  8'h80,   8'd1,    8'h00,   1, 0, 0); 
        run_operation(OP_LSL,  8'h0F,   8'd4,    8'hF0,   0, 1, 0); 

        // ----------------------------------------------------------------
        // 7. LOGICAL SHIFT RIGHT 
        // ----------------------------------------------------------------
        $display("\n--- LOGICAL SHIFT RIGHT ---");
        run_operation(OP_LSR,  8'h80,   8'd7,    8'h01,   0, 0, 0); 
        run_operation(OP_LSR,  8'h01,   8'd1,    8'h00,   1, 0, 0); 

        // ----------------------------------------------------------------
        // 8. MULTIPLICATION
        // ----------------------------------------------------------------
        $display("\n--- SEQUENTIAL MULTIPLICATION ---");
        run_operation(OP_MUL,  8'd7,    8'd8,    8'd56,   0, 0, 0); 
        run_operation(OP_MUL, -8'd10,   8'd5,   -8'd50,   0, 1, 0); 
        run_operation(OP_MUL, -8'd8,   -8'd8,    8'd64,   0, 0, 0); 
        run_operation(OP_MUL,  8'd42,   8'd0,    8'd0,    1, 0, 0); 

        // ----------------------------------------------------------------
        // 9. DIVISION
        // ----------------------------------------------------------------
        $display("\n--- SEQUENTIAL DIVISION ---");
        run_operation(OP_DIV,  8'd100,  8'd10,   8'd10,   0, 0, 0); 
        run_operation(OP_DIV, -8'd20,   8'd4,   -8'd5,    0, 1, 0); 
        run_operation(OP_DIV, -8'd50,  -8'd5,    8'd10,   0, 0, 0); 
        run_operation(OP_DIV,  8'd0,    8'd15,   8'd0,    1, 0, 0); 

        // ----------------------------------------------------------------
        // FINAL SUMMARY
        // ----------------------------------------------------------------
        $display("\n=======================================================");
        $display("   TEST SUMMARY");
        $display("=======================================================");
        $display("   Tests Passed: %0d", tests_passed);
        $display("   Tests Failed: %0d", tests_failed);
        if (tests_failed == 0)
            $display("   STATUS: PERFECT PASS!");
        else
            $display("   STATUS: ERRORS DETECTED.");
        $display("=======================================================\n");

        #50 $finish;
    end

endmodule