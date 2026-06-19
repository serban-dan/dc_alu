`timescale 1ns/1ps

module alu_rshift_8bit (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] y
);
    wire [7:0] s0, s1;

    // Stage 0: Shift Right by 1
    mux2 m07 (.d0(a[7]), .d1(1'b0), .sel(b[0]), .y(s0[7]));
    mux2 m06 (.d0(a[6]), .d1(a[7]), .sel(b[0]), .y(s0[6]));
    mux2 m05 (.d0(a[5]), .d1(a[6]), .sel(b[0]), .y(s0[5]));
    mux2 m04 (.d0(a[4]), .d1(a[5]), .sel(b[0]), .y(s0[4]));
    mux2 m03 (.d0(a[3]), .d1(a[4]), .sel(b[0]), .y(s0[3]));
    mux2 m02 (.d0(a[2]), .d1(a[3]), .sel(b[0]), .y(s0[2]));
    mux2 m01 (.d0(a[1]), .d1(a[2]), .sel(b[0]), .y(s0[1]));
    mux2 m00 (.d0(a[0]), .d1(a[1]), .sel(b[0]), .y(s0[0]));

    // Stage 1: Shift Right by 2
    mux2 m17 (.d0(s0[7]), .d1(1'b0),  .sel(b[1]), .y(s1[7]));
    mux2 m16 (.d0(s0[6]), .d1(1'b0),  .sel(b[1]), .y(s1[6]));
    mux2 m15 (.d0(s0[5]), .d1(s0[7]), .sel(b[1]), .y(s1[5]));
    mux2 m14 (.d0(s0[4]), .d1(s0[6]), .sel(b[1]), .y(s1[4]));
    mux2 m13 (.d0(s0[3]), .d1(s0[5]), .sel(b[1]), .y(s1[3]));
    mux2 m12 (.d0(s0[2]), .d1(s0[4]), .sel(b[1]), .y(s1[2]));
    mux2 m11 (.d0(s0[1]), .d1(s0[3]), .sel(b[1]), .y(s1[1]));
    mux2 m10 (.d0(s0[0]), .d1(s0[2]), .sel(b[1]), .y(s1[0]));

    // Stage 2: Shift Right by 4
    mux2 m27 (.d0(s1[7]), .d1(1'b0),  .sel(b[2]), .y(y[7]));
    mux2 m26 (.d0(s1[6]), .d1(1'b0),  .sel(b[2]), .y(y[6]));
    mux2 m25 (.d0(s1[5]), .d1(1'b0),  .sel(b[2]), .y(y[5]));
    mux2 m24 (.d0(s1[4]), .d1(1'b0),  .sel(b[2]), .y(y[4]));
    mux2 m23 (.d0(s1[3]), .d1(s1[7]), .sel(b[2]), .y(y[3]));
    mux2 m22 (.d0(s1[2]), .d1(s1[6]), .sel(b[2]), .y(y[2]));
    mux2 m21 (.d0(s1[1]), .d1(s1[5]), .sel(b[2]), .y(y[1]));
    mux2 m20 (.d0(s1[0]), .d1(s1[4]), .sel(b[2]), .y(y[0]));

endmodule