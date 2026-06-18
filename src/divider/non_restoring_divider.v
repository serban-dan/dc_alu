`default_nettype none

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

    // ==========================================
    // 1. INPUT CONVERSION (Absolute Value)
    // ==========================================
    wire sign_dividend = dividend[7];
    wire sign_divisor  = divisor[7];
    
    // Convert negative 2's complement inputs to positive
    wire [7:0] abs_dividend = sign_dividend ? (~dividend + 8'd1) : dividend;
    wire [7:0] abs_divisor  = sign_divisor  ? (~divisor + 8'd1)  : divisor;
    
    wire load_M, load_Q, load_A, clear_A, shift_en, do_sub, set_q0;
    wire A_sign;
    
    // Feed the POSITIVE divisor/dividend to the datapath
    wire [7:0] shared_bus = load_M ? abs_divisor : abs_dividend;

    wire [7:0] u_quotient;
    wire [7:0] u_remainder;

    // ==========================================
    // 2. UNSIGNED CORE INSTANTIATION
    // ==========================================
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
        .remainder(u_remainder),
        .quotient(u_quotient)
    );

    // ==========================================
    // 3. OUTPUT CONVERSION (Apply Signs)
    // ==========================================
    // Quotient is negative if signs differ. Remainder takes sign of the dividend.
    wire sign_quot = sign_dividend ^ sign_divisor;
    wire sign_rem  = sign_dividend;
    
    // Convert positive results back to negative if required
    assign quotient  = sign_quot ? (~u_quotient + 8'd1) : u_quotient;
    assign remainder = sign_rem  ? (~u_remainder + 8'd1) : u_remainder;

endmodule