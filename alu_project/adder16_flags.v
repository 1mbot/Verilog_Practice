//16-bit Adder with Status Flag Generation
module adder16_flags (
    input [15:0] X,
    input [15:0] Y,
    output [15:0] Z,
    output Sign,
    output Zero,
    output Carry,
    output Parity,
    output Overflow
);

    wire [16:0] Sum_Ext;

    //17-bit addition to retain the carry-out
    assign Sum_Ext = {1'b0, X} + {1'b0, Y};

    assign Z = Sum_Ext[15:0];
    assign Carry = Sum_Ext[16];

    //Status Flags
    assign Sign = Z[15];
    assign Zero = (Z == 16'h0000);

    //Even Parity
    assign Parity = ~^Z;

    //Signed Overflow
    assign Overflow = (~X[15] & ~Y[15] & Z[15]) | (X[15] & Y[15] & ~Z[15]);

endmodule