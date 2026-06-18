//the rca star on 2 bits from 2 fca star modules
module cska_block_2bit (
    input  [1:0] x,
    input  [1:0] y,
    input        cin,
    output [1:0] z,
    output       cout,
    output       p
);
    wire c1, p1, p2;

    fac_star fac1 (
        .xi(x[0]),
        .yi(y[0]),
        .ci(cin),
        .zi(z[0]),
        .pi(p1),
        .ci_next(c1)
    );

    fac_star fac2 (
        .xi(x[1]),
        .yi(y[1]),
        .ci(c1),
        .zi(z[1]),
        .pi(p2),
        .ci_next(cout)
    );

    and2_gate and_propagate (
        .a(p1),
        .b(p2),
        .y(p)
    );

endmodule