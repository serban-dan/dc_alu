module divider_datapath (
    input        clk,
    input        rst_n,
    input  [7:0] data_in,

    // Control Signals from the FSM
    input        load_M,       // Load Divisor
    input        load_Q,       // Load Dividend
    input        load_A,       // Load math result into Remainder
    input        clear_A,      // Initialize A to 0
    input        shift_en,     // Trigger the Logical Shift Left
    input        do_sub,       // 1 = Subtract, 0 = Add
    input        set_q0,       // Triggers writing the quotient bit

    // Status Signal going OUT to the FSM
    output       A_sign,       // The MSB of A (determines add/sub)
    
    // Final Outputs
    output [7:0] remainder,    // A
    output [7:0] quotient      // Q
);

    wire [7:0] A_out, Q_out, M_out;
    wire [7:0] alu_result;
    wire       alu_cout;

    // Route signals to the FSM and top level
    assign A_sign = A_out[7];
    assign remainder = A_out;
    assign quotient = Q_out;

    //1. Register M (Divisor)
    shift_register_8bit reg_M (
        .clk(clk), .rst_n(rst_n),
        .d_in(data_in), 
        .load_en(load_M), 
        .shift_en(1'b0), .shift_dir(1'b0), .shift_in(1'b0), 
        .q_out(M_out)
    );

    //2. Register Q (Dividend / Quotient)
    // If setting the quotient bit, feed Q its own data shifted left, but replace bit 0.
    wire [7:0] Q_input = set_q0 ? {Q_out[7:1], ~A_out[7]} : data_in;

    shift_register_8bit reg_Q (
        .clk(clk), .rst_n(rst_n),
        .d_in(Q_input), 
        .load_en(load_Q | set_q0), // load_Q grabs data_in, set_q0 grabs the quotient bit
        .shift_en(shift_en), 
        .shift_dir(1'b0),        // 0 = Left Shift
        .shift_in(1'b0),         // Pulls in a temporary 0
        .q_out(Q_out)
    );

    //3. Register A (Remainder)
    wire [7:0] A_input = clear_A ? 8'b00000000 : alu_result;
    
    shift_register_8bit reg_A (
        .clk(clk), .rst_n(rst_n),
        .d_in(A_input), 
        .load_en(load_A | clear_A), 
        .shift_en(shift_en), 
        .shift_dir(1'b0),        // 0 = Left Shift
        .shift_in(Q_out[7]),     // << Wire from Q to A
        .q_out(A_out)
    );

    //4. The Arithmetic
    wire [7:0] M_actual = M_out ^ {8{do_sub}}; 

    carry_skip_adder_8bit div_adder (
        .a(A_out),
        .b(M_actual),
        .cin(do_sub),
        .sum(alu_result),
        .cout(alu_cout)
    );

endmodule