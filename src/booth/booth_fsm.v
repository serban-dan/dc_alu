module booth_fsm (
    input            clk,
    input            rst_n,
    input            start,      
    input            q0,         
    input            q_minus_1,  
    
    output reg       load_M,
    output reg       load_Q,
    output reg       load_A,
    output reg       clear_A_Qm1,
    output reg       shift_en,
    output reg       do_sub,
    output reg       done
);

    // State Encoding
    localparam S_IDLE   = 3'd0;
    localparam S_LOAD_M = 3'd1;
    localparam S_LOAD_Q = 3'd2;
    localparam S_EVAL   = 3'd3;
    localparam S_ADD    = 3'd4;
    localparam S_SUB    = 3'd5;
    localparam S_SHIFT  = 3'd6;
    localparam S_DONE   = 3'd7;

    reg [2:0] state, next_state;
    reg [3:0] count; //count 8 -> 0

    //Sequential Block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            count <= 4'd0;
        end else begin
            state <= next_state;
            
            //8-cycle loop counter
            if (state == S_LOAD_Q) 
                count <= 4'd8; //Reset counter
            else if (state == S_SHIFT) 
                count <= count - 4'd1; //Decrement counter
        end
    end

    //Combinational Block
    always @(*) begin
        next_state  = state;
        load_M      = 1'b0;
        load_Q      = 1'b0;
        load_A      = 1'b0;
        clear_A_Qm1 = 1'b0;
        shift_en    = 1'b0;
        do_sub      = 1'b0;
        done        = 1'b0;

        case (state)
            S_IDLE: begin
                if (start) next_state = S_LOAD_M;
            end
            
            S_LOAD_M: begin
                load_M = 1'b1;
                next_state = S_LOAD_Q;
            end
            
            S_LOAD_Q: begin
                load_Q      = 1'b1;
                clear_A_Qm1 = 1'b1;
                next_state  = S_EVAL;
            end
            
            S_EVAL: begin
                if (count == 4'd0) begin
                    next_state = S_DONE;
                end else begin
                    case ({q0, q_minus_1})
                        2'b01: next_state = S_ADD;
                        2'b10: next_state = S_SUB;
                        default: next_state = S_SHIFT; // For 00 and 11, skip math
                    endcase
                end
            end
            
            S_ADD: begin
                load_A = 1'b1;
                do_sub = 1'b0;
                next_state = S_SHIFT;
            end
            
            S_SUB: begin
                load_A = 1'b1;
                do_sub = 1'b1;
                next_state = S_SHIFT;
            end
            
            S_SHIFT: begin
                shift_en = 1'b1;
                next_state = S_EVAL;
            end
            
            S_DONE: begin
                done = 1'b1;
                if (!start) next_state = S_IDLE; // Wait for the main ALU to lower the start flag
            end
            
            default: next_state = S_IDLE;
        endcase
    end
endmodule