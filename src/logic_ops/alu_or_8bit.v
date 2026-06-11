module alu_or_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] y
);
    or2_gate or0 (.a(a[0]), .b(b[0]), .y(y[0]));
    or2_gate or1 (.a(a[1]), .b(b[1]), .y(y[1]));
    or2_gate or2 (.a(a[2]), .b(b[2]), .y(y[2]));
    or2_gate or3 (.a(a[3]), .b(b[3]), .y(y[3]));
    or2_gate or4 (.a(a[4]), .b(b[4]), .y(y[4]));
    or2_gate or5 (.a(a[5]), .b(b[5]), .y(y[5]));
    or2_gate or6 (.a(a[6]), .b(b[6]), .y(y[6]));
    or2_gate or7 (.a(a[7]), .b(b[7]), .y(y[7]));
endmodule