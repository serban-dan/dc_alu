module divider_fsm (
    input            clk,
    input            rst_n,
    input            start,
    input            A_sign,     // From Datapath: A[7]

    // Control signals OUT to Datapath
    output reg       load_M,
    output reg       load_Q,
    output reg       load_A,
    output reg       clear_A,
    output reg       shift_en,
    output reg       do_sub,
    output reg       set_q0,
    output reg       done
);

    // State Encoding
    localparam S_IDLE        = 4'd0;
    localparam S_LOAD_M      = 4'd1;
    localparam S_LOAD_Q      = 4'd2;
    localparam S_EVAL        = 4'd3;
    localparam S_SHIFT_POS   = 4'd4;
    localparam S_SHIFT_NEG   = 4'd5;
    localparam S_SUB         = 4'd6;
    localparam S_ADD         = 4'd7;
    localparam S_SET_Q       = 4'd8;
    localparam S_CHK_RESTORE = 4'd9;
    localparam S_RESTORE     = 4'd10;
    localparam S_DONE        = 4'd11;

    reg [3:0] state, next_state;
    reg [3:0] count;

    // Sequential Block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            count <= 4'd0;
        end else begin
            state <= next_state;
            if (state == S_LOAD_Q)
                count <= 4'd8; // Start 8-bit countdown
            else if (state == S_SET_Q)
                count <= count - 4'd1; // Decrement after one full math cycle
        end
    end

    // Combinational Routing
    always @(*) begin
        next_state = state;
        load_M     = 1'b0;
        load_Q     = 1'b0;
        load_A     = 1'b0;
        clear_A    = 1'b0;
        shift_en   = 1'b0;
        do_sub     = 1'b0;
        set_q0     = 1'b0;
        done       = 1'b0;

        case (state)
            S_IDLE: if (start) next_state = S_LOAD_M;
            
            S_LOAD_M: begin
                load_M = 1'b1;
                next_state = S_LOAD_Q;
            end
            
            S_LOAD_Q: begin
                load_Q = 1'b1;
                clear_A = 1'b1;
                next_state = S_EVAL;
            end
            
            S_EVAL: begin
                if (count == 4'd0) next_state = S_CHK_RESTORE;
                else if (A_sign == 1'b0) next_state = S_SHIFT_POS;
                else next_state = S_SHIFT_NEG;
            end
            
            S_SHIFT_POS: begin
                shift_en = 1'b1;
                next_state = S_SUB;
            end
            
            S_SHIFT_NEG: begin
                shift_en = 1'b1;
                next_state = S_ADD;
            end
            
            S_SUB: begin
                load_A = 1'b1;
                do_sub = 1'b1;
                next_state = S_SET_Q;
            end
            
            S_ADD: begin
                load_A = 1'b1;
                do_sub = 1'b0;
                next_state = S_SET_Q;
            end
            
            S_SET_Q: begin
                set_q0 = 1'b1;
                next_state = S_EVAL;
            end
            
            // Final Correction Step
            S_CHK_RESTORE: begin
                if (A_sign == 1'b1) next_state = S_RESTORE;
                else next_state = S_DONE;
            end
            
            S_RESTORE: begin
                load_A = 1'b1;
                do_sub = 1'b0; // Add divisor back to restore remainder
                next_state = S_DONE;
            end
            
            S_DONE: begin
                done = 1'b1;
                if (!start) next_state = S_IDLE;
            end
            
            default: next_state = S_IDLE;
        endcase
    end
endmodule