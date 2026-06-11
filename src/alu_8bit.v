module alu_8bit (
    input  [7:0] A,
    input  [7:0] B,
    input  [2:0] opcode,     // 3-bit control signal
    output reg [7:0] result, // The final selected output
    output Z,                // Zero Flag
    output N,                // Negative Flag
    output V                 // Overflow Flag
);

    //1. Opcodes
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_LSL = 3'b101;
    localparam OP_LSR = 3'b110;
    localparam OP_PAS = 3'b111; 

    //2. Internal Wires
    wire [7:0] out_add_sub, out_and, out_or, out_xor, out_lsl, out_lsr;
    wire cout_add_sub;

    //3. Arithmetic Core
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

    //5. The Multiplexer
    always @(*) begin
        case (opcode)
            OP_ADD: result = out_add_sub;
            OP_SUB: result = out_add_sub;
            OP_AND: result = out_and;
            OP_OR:  result = out_or;
            OP_XOR: result = out_xor;
            OP_LSL: result = out_lsl;
            OP_LSR: result = out_lsr;
            OP_PAS: result = A;
            default: result = 8'b00000000;
        endcase
    end

    //6. Status Flags
    
    // Zero (Z): True if every bit of the result is 0
    assign Z = (result == 8'd0);
    
    // Negative (N): True if the Most Significant Bit (MSB) is 1
    assign N = result[7];
    
    // Overflow (V)
    wire is_math_op   = (opcode == OP_ADD) || (opcode == OP_SUB);
    wire sign_A       = A[7];
    wire sign_B       = B_actual[7];
    wire sign_Result  = out_add_sub[7];

    wire pos_overflow = (~sign_A & ~sign_B & sign_Result); // (+) + (+) = (-)
    wire neg_overflow = (sign_A & sign_B & ~sign_Result);  // (-) + (-) = (+)

    // V is high only during math operations where an overflow condition is met
    assign V = is_math_op ? (pos_overflow | neg_overflow) : 1'b0;

endmodule