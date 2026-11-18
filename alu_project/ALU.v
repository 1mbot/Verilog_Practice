module ALU (
    input  [15:0] X,
    input  [15:0] Y,
    input  [2:0] OP,

    output [15:0] Z,
    output Sign,
    output Zero,
    output Carry,
    output Parity,
    output Overflow
);

    wire ADD_EN;
    wire SUB_EN;
    wire AND_EN;
    wire OR_EN;
    wire XOR_EN;
    wire NOT_EN;
    wire SHL_EN;
    wire SHR_EN;

    // Control Unit
    alu_control CU (
        .OP(OP),

        .ADD_EN(ADD_EN),
        .SUB_EN(SUB_EN),
        .AND_EN(AND_EN),
        .OR_EN(OR_EN),
        .XOR_EN(XOR_EN),
        .NOT_EN(NOT_EN),
        .SHL_EN(SHL_EN),
        .SHR_EN(SHR_EN)
    );

    // Datapath
    alu_datapath DP (
        .X(X),
        .Y(Y),

        .ADD_EN(ADD_EN),
        .SUB_EN(SUB_EN),
        .AND_EN(AND_EN),
        .OR_EN(OR_EN),
        .XOR_EN(XOR_EN),
        .NOT_EN(NOT_EN),
        .SHL_EN(SHL_EN),
        .SHR_EN(SHR_EN),

        .Z(Z),
        .Sign(Sign),
        .Zero(Zero),
        .Carry(Carry),
        .Parity(Parity),
        .Overflow(Overflow)
    );

endmodule