//the 2-to-1 mux
`timescale 1ns/1ps

module mux2 (
    input d0,
    input d1,
    input sel,
    output reg y
);
    always @(*) begin
        case (sel)
            1'b0: y = d0;
            1'b1: y = d1;
            default: y = 1'bz; // High impedance for safety
        endcase
    end
endmodule