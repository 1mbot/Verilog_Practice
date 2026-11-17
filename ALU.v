// Behavioral description of 16-bit adder, generation of status flags

module ALU (X, Y, Z, Sign, Zero, Carry, Parity, Overflow);

    input [15:0] X, Y;
    output [15:0] Z;
    output Sign, Zero, Parity, Carry, Overflow;

    assign {Carry, Z} = {1'b0, X} + {1'b0, Y};

    assign Sign     = Z[15];
    assign Zero     = ~|Z;
    assign Parity   = ~^Z;

    assign Overflow = (X[15] & Y[15] & ~Z[15]) |
                      (~X[15] & ~Y[15] & Z[15]);

endmodule