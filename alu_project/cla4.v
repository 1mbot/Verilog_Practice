//4-bit Sturctural Carry Lookahead Adder 

module CLA4 (A, B, Cin, S, Cout);
    input [3:0] A;
    input [3:0] B;
    input       Cin;
    output [3:0] S;
    output Cout;

    wire [3:0] P, G;
    wire C1, C2, C3;

    //Propagate
    assign P = A ^ B;

    //Generate
    assign G = A & B;

    // Carry Lookahead Equations
    assign C1 = G[0] | (P[0] & Cin);

    assign C2 = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
    
    assign C3 = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);

    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

    //Sum
    assign S[0] = P[0] ^ Cin;
    assign S[1] = P[1] ^ C1;
    assign S[2] = P[2] ^ C2;
    assign S[3] = P[3] ^ C3;
endmodule

