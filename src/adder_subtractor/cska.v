//the carry skip adder on 8 bits
module carry_skip_adder_8bit(
    input  [7:0] a,
    input  [7:0] b,
    input        cin,
    output [7:0] sum,
    output       cout
);

    //wires for ripple carry
    wire r_c4, r_c6;

    //wires for actual carries
    wire c2, c4, c6;

    //wire for propagate
    wire p1, p2;

    //wire for skip logic
    wire skip_and_1, skip_and_2;


    // Block 0 (bits 0-1) 
    cska_block_2bit block0 (
        .x(a[1:0]),
        .y(b[1:0]),
        .cin(cin),
        .z(sum[1:0]),
        .cout(c2),
        .p() //No skip logic for the first block
    );

    //Block 1 (bits 2-3)
    cska_block_2bit block1 (
        .x(a[3:2]),
        .y(b[3:2]),
        .cin(c2),
        .z(sum[3:2]),
        .cout(r_c4),
        .p(p1)
    );

    //AND-OR Skip Logic
    and2_gate and_skip1(
        .a(p1),
        .b(c2),
        .y(skip_and_1)
    );

    or2_gate or_skip1(
        .a(r_c4),
        .b(skip_and_1),
        .y(c4)
    );

    //Block 2 (bits 4-5)
    cska_block_2bit block2 (
        .x(a[5:4]),
        .y(b[5:4]),
        .cin(c4),
        .z(sum[5:4]),
        .cout(r_c6),
        .p(p2)
    );

    //AND-OR Skip Logic
    and2_gate and_skip2(
        .a(p2),
        .b(c4),
        .y(skip_and_2)
    );

    or2_gate or_skip2(
        .a(r_c6),
        .b(skip_and_2),
        .y(c6)
    );

    //Block 3 (bits 6-7)
    cska_block_2bit block3 (
        .x(a[7:6]),
        .y(b[7:6]),
        .cin(c6),
        .z(sum[7:6]),
        .cout(cout),
        .p() //No skip logic for last block
    );

endmodule