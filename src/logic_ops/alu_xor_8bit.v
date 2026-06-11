module alu_xor_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] y
);
    xor2_gate xor0 (.a(a[0]), .b(b[0]), .y(y[0]));
    xor2_gate xor1 (.a(a[1]), .b(b[1]), .y(y[1]));
    xor2_gate xor2 (.a(a[2]), .b(b[2]), .y(y[2]));
    xor2_gate xor3 (.a(a[3]), .b(b[3]), .y(y[3]));
    xor2_gate xor4 (.a(a[4]), .b(b[4]), .y(y[4]));
    xor2_gate xor5 (.a(a[5]), .b(b[5]), .y(y[5]));
    xor2_gate xor6 (.a(a[6]), .b(b[6]), .y(y[6]));
    xor2_gate xor7 (.a(a[7]), .b(b[7]), .y(y[7]));
endmodule