module alu_rshift_8bit (
    input  [7:0] a,
    output [7:0] y
);
    // Hard-wired shift right
    assign y[7] = 1'b0;
    assign y[6] = a[7];
    assign y[5] = a[6];
    assign y[4] = a[5];
    assign y[3] = a[4];
    assign y[2] = a[3];
    assign y[1] = a[2];
    assign y[0] = a[1];
endmodule