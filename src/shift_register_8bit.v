module shift_register_8bit (
    input clk,
    input rst_n,
    input [7:0] d_in,
    input load_en,
    input shift_en,
    input shift_dir, // 0 = Left, 1 = Right
    input shift_in,
    output reg [7:0] q_out
);

    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            q_out <= 8'b00000000;
        end
        else if (load_en) begin
            q_out <= d_in;
        end
        else if(shift_en) begin
            if (shift_dir == 1'b1) begin
                //Arithmetic Right Shift (Booth)
                q_out <= {shift_in, q_out[7:1]};
            end
            else begin
                //Logical Shift Left (Division)
                q_out <= {q_out[6:0],shift_in};
            end
        end
    end
endmodule
