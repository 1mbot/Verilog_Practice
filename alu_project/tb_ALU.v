module tb_ALU;

    reg [15:0] X, Y;
    reg [2:0] OP;

    wire [15:0] Z;
    wire Sign, Zero, Carry, Parity, Overflow;

    ALU DUT (
        .X(X),
        .Y(Y),
        .OP(OP),

        .Z(Z),
        .Sign(Sign),
        .Zero(Zero),
        .Carry(Carry),
        .Parity(Parity),
        .Overflow(Overflow)
    );

    initial begin

        $dumpfile("ALU.vcd");
        $dumpvars(0, tb_ALU);

        $monitor("Time=%0t | X=%h Y=%h OP=%b | Z=%h | S=%b ZF=%b CF=%b PF=%b OF=%b",
                 $time, X, Y, OP, Z, Sign, Zero, Carry, Parity, Overflow);

        X = 16'h000F;
        Y = 16'h0001;

        OP = 3'b000;       // ADD
        #10;

        OP = 3'b001;       // SUB
        #10;

        OP = 3'b010;       // AND
        #10;

        OP = 3'b011;       // OR
        #10;

        OP = 3'b100;       // XOR
        #10;

        OP = 3'b101;       // NOT X
        #10;

        OP = 3'b110;       // Shift Left
        #10;

        OP = 3'b111;       // Shift Right
        #10;

        // Carry test
        X = 16'hFFFF;
        Y = 16'h0001;
        OP = 3'b000;
        #10;

        // Overflow test
        X = 16'h7FFF;
        Y = 16'h0001;
        OP = 3'b000;
        #10;

        // Zero flag test
        X = 16'h5555;
        Y = 16'h5555;
        OP = 3'b001;
        #10;

        $finish;

    end

endmodule