// NOTE: This module has been converted to a sequential controller
// to manage multi-cycle operations like multiplication and division.
module alu_8bit (
    input  clk,
    input  reset,
    input  start,            // Start the selected operation
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] opcode,     // 4-bit control signal to support more ops
    output reg [7:0] result, // The final selected output. Note: MUL/DIV may need more bits.
    output reg ready,        // Operation is complete, result is valid
    output Z,                // Zero Flag
    output N,                // Negative Flag
    output V                // Overflow Flag
);

    //1. Opcodes
    localparam OP_ADD = 4'b0000;
    localparam OP_SUB = 4'b0001;
    localparam OP_AND = 4'b0010;
    localparam OP_OR  = 4'b0011;
    localparam OP_XOR = 4'b0100;
    localparam OP_LSL = 4'b0101;
    localparam OP_LSR = 4'b0110;

    // Opcodes for sequential operations
    localparam OP_MUL = 4'b1000;
    localparam OP_DIV = 4'b1001;

    // FSM States for managing sequential operations
    localparam STATE_IDLE = 1'b0;
    localparam STATE_BUSY = 1'b1;

    reg state;

    //2. Internal Wires
    wire [7:0] out_add_sub, out_and, out_or, out_xor, out_lsl, out_lsr;
    wire [15:0] product_16bit; // Booth multiplier gives a 16-bit result
    wire [7:0]  quotient_out;
    wire [7:0]  remainder_out; // Remainder from divider, currently unused by top-level result

    wire cout_add_sub;

    //3. Arithmetic Core
    // Note: This core handles both Addition and Subtraction
    
    //Wordgate
    wire is_sub = (opcode == OP_SUB);
    wire [7:0] B_actual = B ^ {8{is_sub}}; 
    
    carry_skip_adder_8bit alu_adder (
        .a(A),
        .b(B_actual),
        .cin(is_sub),
        .sum(out_add_sub),
        .cout(cout_add_sub)
    );

    //4. Logic & Shift Cores
    alu_and_8bit u_and (.a(A), .b(B), .y(out_and));
    alu_or_8bit  u_or  (.a(A), .b(B), .y(out_or));
    alu_xor_8bit u_xor (.a(A), .b(B), .y(out_xor));
    alu_lshift_8bit u_ls (.a(A), .y(out_lsl));
    alu_rshift_8bit u_rs (.a(A), .y(out_lsr));

    // Instantiate Sequential Units
    wire is_mul_op = (opcode == OP_MUL);
    wire is_div_op = (opcode == OP_DIV);
    wire is_seq_op = is_mul_op || is_div_op;

    wire mul_start = (state == STATE_IDLE) && start && is_mul_op;
    wire div_start = (state == STATE_IDLE) && start && is_div_op;
    wire mul_done, div_done;

    // Fixed port connections to match structural module definitions
    booth_multiplier u_booth (
        .clk(clk), 
        .rst_n(~reset),       // Pass inverted active-high reset to active-low port
        .start(mul_start),
        .multiplicand(A), 
        .multiplier(B), 
        .product(product_16bit), 
        .done(mul_done)
    );

    non_restoring_divider u_div (
        .clk(clk), 
        .rst_n(~reset),       // Pass inverted active-high reset to active-low port
        .start(div_start),
        .dividend(A), 
        .divisor(B), 
        .quotient(quotient_out), 
        .remainder(remainder_out), 
        .done(div_done)
    );

    //5. The Multiplexer
    always @(*) begin
        case (opcode)
            OP_ADD,
            OP_SUB: result = out_add_sub; // Both ops use the same arithmetic core output
            OP_AND: result = out_and;
            OP_OR:  result = out_or;
            OP_XOR: result = out_xor;
            OP_LSL: result = out_lsl;
            OP_LSR: result = out_lsr;
            // Note: Multiplication of two 8-bit numbers can yield a 16-bit result.
            // This design truncates to 8 bits.
            OP_MUL: result = product_16bit[7:0]; // Using lower 8 bits of the product
            OP_DIV: result = quotient_out;       // Result is quotient, remainder is separate
            default: result = 8'b00000000;
        endcase
    end

    //6. Status Flags
    
    // Zero (Z): True if every bit of the result is 0
    assign Z = (result == 8'd0);
    
    // Negative (N): True if the Most Significant Bit (MSB) is 1
    assign N = result[7];
    
    // Overflow (V): Valid for 2's complement addition and subtraction ONLY.
    // Multiplication and division have different overflow conditions not covered here.
    // For example, 8x8 multiplication requires a 16-bit result.
    wire is_math_op   = (opcode == OP_ADD) || (opcode == OP_SUB);
    wire sign_A       = A[7];
    wire sign_B       = B_actual[7];
    wire sign_Result  = out_add_sub[7];

    wire pos_overflow = (~sign_A & ~sign_B & sign_Result); // (+) + (+) = (-)
    wire neg_overflow = (sign_A & sign_B & ~sign_Result);  // (-) + (-) = (+)

    // V is high only during math operations where an overflow condition is met
    assign V = is_math_op ? (pos_overflow | neg_overflow) : 1'b0;

    //7. Control FSM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            ready <= 1'b1;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (start) begin
                        ready <= 1'b0;
                        state <= STATE_BUSY;
                    end
                end
                STATE_BUSY: begin
                    // Combinational ops are done in one cycle
                    // Sequential ops wait for their 'done' signal
                    if (!is_seq_op || (is_mul_op && mul_done) || (is_div_op && div_done)) begin
                        ready <= 1'b1;
                        if (!start) begin // Wait for start to go low before returning to IDLE
                            state <= STATE_IDLE;
                        end
                    end
                end
            endcase
        end
    end
endmodule