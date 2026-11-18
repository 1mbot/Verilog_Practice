module tb_cla4;

    reg [3:0] A, B;
    reg Cin;

    wire [3:0] S;
    wire Cout;

    CLA4 DUT (.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));

    initial begin

        $dumpfile("cla4.vcd");
        $dumpvars(0, tb_cla4);

        $monitor ("Time = %0t A = %b B = %b | S = %b Cout = %b", $time, A, B, Cin, S, Cout);

        A = 4'b0000; B = 4'b0000; Cin = 0;
        #10;

        A = 4'b0011; B = 4'b0101; Cin = 0;
        #10;

        A = 4'b1111; B = 4'b0001; Cin = 0;
        #10;

        A = 4'b1111; B = 4'b1111; Cin = 1;
        #10;

        A = 4'b1010; B = 4'b0101; Cin = 1;
        #10;

        A = 4'b0111; B = 4'b0001; Cin = 0;
        #10;

        $finish;

    end
endmodule
