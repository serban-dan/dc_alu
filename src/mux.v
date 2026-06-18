//the 2-to-1 mux
module mux2 (
    input d0,
    input d1,
    input sel,
    output y
);
    assign y = sel ? d1 : d0;
endmodule