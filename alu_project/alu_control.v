module alu_control(
    input [2:0] OP,

    output reg ADD_EN,
    output reg SUB_EN,
    output reg AND_EN,
    output reg OR_EN,
    output reg XOR_EN,
    output reg NOT_EN,
    output reg SHL_EN,
    output reg SHR_EN
);

    always @(*)
    begin
        // default: all operations disabled
        ADD_EN = 0;
        SUB_EN = 0;
        AND_EN = 0;
        OR_EN = 0;
        XOR_EN = 0;
        NOT_EN = 0;
        SHL_EN = 0;
        SHR_EN = 0;

        case(OP)
            3'b000: ADD_EN = 1;
            3'b001: SUB_EN = 1;
            3'b010: AND_EN = 1;
            3'b011: OR_EN = 1;
            3'b100: XOR_EN = 1;
            3'b101: NOT_EN = 1;
            3'b110: SHL_EN = 1;
            3'b111: SHR_EN = 1;

        endcase

    end
endmodule