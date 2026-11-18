module alu_datapath(
    input [15:0] X,
    input [15:0] Y,

    input ADD_EN,
    input SUB_EN,
    input AND_EN,
    input OR_EN,
    input XOR_EN,
    input NOT_EN,
    input SHL_EN,
    input SHR_EN,

    output reg [15:0] Z,
    output reg Sign,
    output reg Zero,
    output reg Carry,
    output reg Parity,
    output reg Overflow
);

    reg [16:0] Temp;

    always @(*) begin

        //Default Values
        Z = 16'b0;
        Temp = 17'b0;
        Carry = 1'b0;
        Overflow = 1'b0;

        //Arithmetic and Logic operations
        if (ADD_EN) begin

            Temp = {1'b0, X} + {1'b0, Y};

            Z = Temp[15:0];
            Carry = Temp[16];

            Overflow = (~X[15] & ~Y[15] & Z[15]) | (X[15] & Y[15] & ~Z[15]);

        end
        else if (SUB_EN) begin
            Temp = {1'b0, X} + {1'b0, ~Y} + 17'b1;

            Z = Temp[15:0];

            // Carry = 1 means no broww
            Carry = Temp[16];

            Overflow = (X[15] & ~Y[15] & ~Z[15]) | (~X[15] & Y[15] & Z[15]);

        end
        else if (AND_EN) begin
            Z = X & Y;
        end

        else if (OR_EN) begin
            Z = X | Y;
        end

        else if (XOR_EN) begin
            Z = X ^ Y;
        end

        else if (NOT_EN) begin
            Z = ~X;
        end

        else if (SHL_EN) begin
            Z = X << 1;
            Carry = X[15];
        end

        else if (SHR_EN) begin
            Z = X >> 1;
            Carry = X[0];
        end

        // Status Flags
        Sign = Z[15];
        Zero = (Z == 16'b0);
        Parity = ~^Z;

    end
endmodule

