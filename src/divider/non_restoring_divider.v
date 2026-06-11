module non_restoring_divider (
    input         clk,
    input         rst_n,
    input         start,
    input  [7:0]  dividend,
    input  [7:0]  divisor,
    output        done,
    output [7:0]  quotient,
    output [7:0]  remainder
);

    wire load_M, load_Q, load_A, clear_A, shift_en, do_sub, set_q0;
    wire A_sign;
    
    wire [7:0] shared_bus = load_M ? divisor : dividend;

    divider_fsm div_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .A_sign(A_sign),
        .load_M(load_M),
        .load_Q(load_Q),
        .load_A(load_A),
        .clear_A(clear_A),
        .shift_en(shift_en),
        .do_sub(do_sub),
        .set_q0(set_q0),
        .done(done)
    );

    divider_datapath div_dp (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(shared_bus),
        .load_M(load_M),
        .load_Q(load_Q),
        .load_A(load_A),
        .clear_A(clear_A),
        .shift_en(shift_en),
        .do_sub(do_sub),
        .set_q0(set_q0),
        .A_sign(A_sign),
        .remainder(remainder),
        .quotient(quotient)
    );

endmodule