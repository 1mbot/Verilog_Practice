module processing_element #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 32
)(
    input clk,
    input rst,

    input [DATA_WIDTH-1:0] A_in,
    input [DATA_WIDTH-1:0] B_in,

    input valid_A_in,
    input valid_B_in,

    output reg [DATA_WIDTH-1:0] A_out,
    output reg [DATA_WIDTH-1:0] B_out,

    output reg valid_A_out,
    output reg valid_B_out,

    output reg [ACC_WIDTH-1:0] Acc
);

    wire [2*DATA_WIDTH-1:0] Product;

    assign Product = A_in * B_in;

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            A_out <= 0;
            B_out <= 0;
            valid_A_out <= 0;
            valid_B_out <= 0;
            Acc <= 0;

        end

        else begin
        // Forward A horizontally
        A_out <= A_in;
        valid_A_out <= valid_A_in;

        //Forward B vertically
        B_out <= B_in;
        valid_B_out <= valid_B_in;

        //Multiply and accumulate

        if (valid_A_in && valid_B_in)
            Acc <= Acc + Product;

        end
    end
endmodule