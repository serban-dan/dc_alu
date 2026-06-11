//the full adder cell for the ripple carry cell
module fac_star (
    input  xi,
    input  yi,
    input  ci,
    output zi,
    output ci_next,
    output pi
);
    wire w_xor1, w_and1, w_and2, w_and3;

    xor2_gate x1 (
        .a(xi),
        .b(yi),
        .y(w_xor1)
    );

    xor2_gate x2 (
        .a(w_xor1),
        .b(ci),
        .y(zi)
    );

    and2_gate a1 (
        .a(xi),
        .b(ci),
        .y(w_and1)
    );

    and2_gate a2 (
        .a(yi),
        .b(ci),
        .y(w_and2)
    );

    and2_gate a3 (
        .a(xi),
        .b(yi),
        .y(w_and3)
    );

    or3_gate o3 (
        .a(w_and1),
        .b(w_and2),
        .c(w_and3),
        .y(ci_next)
    );

    or2_gate o2 (
        .a(xi),
        .b(yi),
        .y(pi)
    );
endmodule