//the primitive gates used for all other implementations

`timescale 1ns/1ps

module xor2_gate (
    input a,
    input b,
    output y
);
    assign #1 y = a ^ b;
endmodule //xor gate on 2 bits

module and2_gate (
    input a,
    input b,
    output y
);
    assign #1 y = a & b;
endmodule //and gate on 2 bits

module or2_gate (
    input a,
    input b,
    output y
);
    assign #1 y = a | b;
endmodule //or gate on 2 bits

module or3_gate (
    input a,
    input b,
    input c,
    output y
);
    assign #1 y = a | b | c;
endmodule //or gate on 3 bits