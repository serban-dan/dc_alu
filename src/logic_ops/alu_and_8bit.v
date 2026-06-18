module alu_and_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] y
);
    and2_gate and0 (.a(a[0]), .b(b[0]), .y(y[0]));
    and2_gate and1 (.a(a[1]), .b(b[1]), .y(y[1]));
    and2_gate and2 (.a(a[2]), .b(b[2]), .y(y[2]));
    and2_gate and3 (.a(a[3]), .b(b[3]), .y(y[3]));
    and2_gate and4 (.a(a[4]), .b(b[4]), .y(y[4]));
    and2_gate and5 (.a(a[5]), .b(b[5]), .y(y[5]));
    and2_gate and6 (.a(a[6]), .b(b[6]), .y(y[6]));
    and2_gate and7 (.a(a[7]), .b(b[7]), .y(y[7]));
endmodule