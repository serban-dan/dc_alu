module alu_rshift_8bit (
    input  [7:0] a,
    output [7:0] y
);
    // Hard-wired shift right
    // This is a logical shift right, so we shift in a 0 from the left.
    assign y = {1'b0, a[7:1]};
endmodule