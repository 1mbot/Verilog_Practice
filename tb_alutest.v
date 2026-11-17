module alutest;

    reg [15:0] X, Y;
    wire [15:0] Z;
    wire S, ZR, CY, P, OV;

    ALU DUT (
        .X(X),
        .Y(Y),
        .Z(Z),
        .Sign(S),
        .Zero(ZR),
        .Carry(CY),
        .Parity(P),
        .Overflow(OV)
    );

    initial begin

        $dumpfile("ALU.vcd");
        $dumpvars(0, alutest);

        $monitor("%0t X=%h Y=%h Z=%h S=%b ZR=%b CY=%b P=%b OV=%b",
                 $time, X, Y, Z, S, ZR, CY, P, OV);

        #5 X = 16'h8fff; Y = 16'h8000;
        #5 X = 16'hfffe; Y = 16'h0002;
        #5 X = 16'haaaa; Y = 16'h5555;

        #5 $finish;

    end

endmodule