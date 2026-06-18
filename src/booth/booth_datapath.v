module booth_datapath (
    input        clk,
    input        rst_n,
    input  [7:0] data_in,
    
    // Control Signals from the FSM
    input        load_M,       // c0: Load multiplicand
    input        load_Q,       // c1: Load multiplier
    input        load_A,       // c2: Load ALU result into A
    input        clear_A_Qm1,  // c0: Clears A and Q[-1] at initialization
    input        shift_en,     // c4: Trigger the right shift
    input        do_sub,       // 1 = Subtract, 0 = Add
    
    // Status Signals going OUT to the FSM
    output       q0,           // Q[0]
    output       q_minus_1,    // Q[-1]
    
    // Final product outputs
    output [7:0] prod_high,    // Upper 8 bits [A]
    output [7:0] prod_low      // Lower 8 bits [Q]
);

    // Internal bus wires
    wire [7:0] A_out, Q_out, M_out;
    wire [7:0] alu_result;
    wire       alu_cout;
    
    // The Q[-1] physical register
    reg Qm1_reg;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || clear_A_Qm1) 
            Qm1_reg <= 1'b0;
        else if (shift_en)         
            Qm1_reg <= Q_out[0]; // Catches the bit falling out of Q
    end
    
    // Assign outputs for the FSM to read
    assign q0 = Q_out[0];
    assign q_minus_1 = Qm1_reg;
    assign prod_high = A_out;
    assign prod_low = Q_out;

    //1. Register M (Multiplicand)
    // Never shifts, just holds the value
    shift_register_8bit reg_M (
        .clk(clk), .rst_n(rst_n),
        .d_in(data_in), 
        .load_en(load_M), 
        .shift_en(1'b0),
        .shift_dir(1'b0), 
        .shift_in(1'b0),
        .q_out(M_out)
    );

    //2. Register Q (Multiplier / Lower Product)
    // Loads from INBUS. During shift, pulls in A[0]
    shift_register_8bit reg_Q (
        .clk(clk), .rst_n(rst_n),
        .d_in(data_in), 
        .load_en(load_Q), 
        .shift_en(shift_en), 
        .shift_dir(1'b1),        // 1 = Right Shift
        .shift_in(A_out[0]),     // << Wire from A to Q
        .q_out(Q_out)
    );

    //3. Register A (Accumulator / Upper Product)
    // Loads from the ALU. During shift, pulls in its own sign bit
    // If clear_A_Qm1 is high, we feed it 0s instead of the ALU result
    wire [7:0] A_input = clear_A_Qm1 ? 8'b00000000 : alu_result;
    
    shift_register_8bit reg_A (
        .clk(clk), .rst_n(rst_n),
        .d_in(A_input), 
        .load_en(load_A | clear_A_Qm1), 
        .shift_en(shift_en), 
        .shift_dir(1'b1),        // 1 = Right Shift
        .shift_in(A_out[7]),     // << Sign Extension
        .q_out(A_out)
    );

    //4. The Arithmetic Core (Reusing CSkA)
    // The EXOR wordgate array for subtraction
    wire [7:0] M_actual = M_out ^ {8{do_sub}}; 

    carry_skip_adder_8bit booth_adder (
        .a(A_out),
        .b(M_actual),
        .cin(do_sub), // 1 for sub, 0 for add
        .sum(alu_result),
        .cout(alu_cout)
    );

endmodule