`timescale 1ns / 1ps

module tb_alu;
    reg [7:0] A, B;
    reg [2:0] opcode;
    wire [7:0] result;
    wire Z, N, V;

    integer errors = 0;
    integer test_num = 1;

    // Instantiate the ALU
    alu_8bit uut (
        .A(A), .B(B), .opcode(opcode),
        .result(result), .Z(Z), .N(N), .V(V)
    );

    // A simple task to check the answers and print pass/fail
    task check_op;
        input [7:0] test_a, test_b;
        input [2:0] test_op;
        input [7:0] exp_res;
        input exp_Z, exp_N, exp_V;
        begin
            A = test_a; B = test_b; opcode = test_op;
            
            // Wait for the #1 gate delays in the adder to settle
            #50; 

            if (result !== exp_res || Z !== exp_Z || N !== exp_N || V !== exp_V) begin
                $display("Test %0d FAILED! A=%d, B=%d", test_num, A, B);
                $display("  Got: Res=%d, Z=%b, N=%b, V=%b", result, Z, N, V);
                $display("  Exp: Res=%d, Z=%b, N=%b, V=%b", exp_res, exp_Z, exp_N, exp_V);
                errors = errors + 1;
            end else begin
                $display("Test %0d PASSED. (Res=%d)", test_num, result);
            end
            
            test_num = test_num + 1;
        end
    endtask

    initial begin
        $dumpfile("build/alu_waves.vcd");
        $dumpvars(0, tb_alu);

        $display("Starting ALU tests...");

        // Basic Math
        check_op(8'd10, 8'd5, 3'b000, 8'd15, 0, 0, 0); // 10 + 5 = 15
        check_op(8'd20, 8'd5, 3'b001, 8'd15, 0, 0, 0); // 20 - 5 = 15
        check_op(8'd15, 8'd15, 3'b001, 8'd0,  1, 0, 0); // 15 - 15 = 0
        
        // Signed Math and Overflow
        check_op(8'd5, 8'd10, 3'b001, -8'd5,  0, 1, 0); // 5 - 10 = -5
        check_op(8'd100, 8'd100, 3'b000, 8'd200, 0, 1, 1); // 100 + 100 (Overflow)
        
        // Logic and Shifts
        check_op(8'hAA, 8'h55, 3'b100, 8'hFF, 0, 1, 0); // XOR
        check_op(8'h0F, 8'h00, 3'b101, 8'h1E, 0, 0, 0); // Left Shift

        $display("--------------------------------");
        if (errors == 0) begin
            $display("All tests passed! 0 errors.");
        end else begin
            $display("Tests finished with %0d errors.", errors);
        end
        
        $finish;
    end
endmodule