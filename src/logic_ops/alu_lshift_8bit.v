module alu_lshift_8bit (
    input  [7:0] a,
    output [7:0] y
);
    // Hard-wired shift left
    assign y[0] = 1'b0;
    assign y[1] = a[0];
    assign y[2] = a[1];
    assign y[3] = a[2];
    assign y[4] = a[3];
    assign y[5] = a[4];
    assign y[6] = a[5];
    assign y[7] = a[6];
endmodule