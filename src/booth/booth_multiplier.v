module booth_multiplier (
    input         clk,
    input         rst_n,
    input         start,
    input  [7:0]  multiplicand,
    input  [7:0]  multiplier,
    output        done,
    output [15:0] product
);

    // Wires connecting the FSM and the Datapath
    wire load_M, load_Q, load_A, clear_A_Qm1, shift_en, do_sub;
    wire q0, q_minus_1;
    wire [7:0] prod_high, prod_low;
    
    // The Shared Data Bus Logic
    wire [7:0] shared_bus = load_M ? multiplicand : multiplier;
    
    // Final 16-bit concatenation
    assign product = {prod_high, prod_low};

    // Instantiate the FSM
    booth_fsm fsm_unit (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .q0(q0),
        .q_minus_1(q_minus_1),
        .load_M(load_M),
        .load_Q(load_Q),
        .load_A(load_A),
        .clear_A_Qm1(clear_A_Qm1),
        .shift_en(shift_en),
        .do_sub(do_sub),
        .done(done)
    );

    // Instantiate the Module
    booth_datapath dp_unit (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(shared_bus),
        .load_M(load_M),
        .load_Q(load_Q),
        .load_A(load_A),
        .clear_A_Qm1(clear_A_Qm1),
        .shift_en(shift_en),
        .do_sub(do_sub),
        .q0(q0),
        .q_minus_1(q_minus_1),
        .prod_high(prod_high),
        .prod_low(prod_low)
    );

endmodule