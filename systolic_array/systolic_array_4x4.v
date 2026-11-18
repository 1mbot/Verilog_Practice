module systolic_array_4x4 #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input clk,
    input rst,

    input [127:0] A_flat,
    input [127:0] B_flat,

    output [511:0] C_flat
);

    reg [3:0] cycle_count;

    // -----------------------------------------------
    // Internal PE input/output connections
    // -----------------------------------------------

    wire [DATA_WIDTH-1:0] A_PE_in  [0:3][0:3];
    wire [DATA_WIDTH-1:0] A_PE_out [0:3][0:3];

    wire [DATA_WIDTH-1:0] B_PE_in  [0:3][0:3];
    wire [DATA_WIDTH-1:0] B_PE_out [0:3][0:3];

    wire valid_A_in  [0:3][0:3];
    wire valid_A_out [0:3][0:3];

    wire valid_B_in  [0:3][0:3];
    wire valid_B_out [0:3][0:3];

    wire [ACC_WIDTH-1:0] Acc [0:3][0:3];

    // -----------------------------------------------
    // Systolic timing counter
    // -----------------------------------------------

    always @(posedge clk or posedge rst) begin

        if (rst)
            cycle_count <= 0;

        else if (cycle_count < 10)
            cycle_count <= cycle_count + 1'b1;

    end

    // -----------------------------------------------
    // Matrix element extraction functions
    // -----------------------------------------------

    function [DATA_WIDTH-1:0] get_A_element;
        input [127:0] matrix;
        input integer row;
        input integer col;

        begin
            if (row >= 0 && row < 4 &&
                col >= 0 && col < 4)

                get_A_element =
                    matrix[8*(row*4+col) +: 8];

            else
                get_A_element = 0;
        end

    endfunction


    function [DATA_WIDTH-1:0] get_B_element;
        input [127:0] matrix;
        input integer row;
        input integer col;

        begin
            if (row >= 0 && row < 4 &&
                col >= 0 && col < 4)

                get_B_element =
                    matrix[8*(row*4+col) +: 8];

            else
                get_B_element = 0;
        end

    endfunction

    // -----------------------------------------------
    // Generate 4x4 Processing Elements
    // -----------------------------------------------

    genvar i, j;

    generate

        for (i = 0; i < 4; i = i + 1) begin : ROW

            for (j = 0; j < 4; j = j + 1) begin : COL

                // =====================================
                // A: horizontal data movement
                // =====================================

                if (j == 0) begin

                    assign A_PE_in[i][j] =
                        get_A_element(
                            A_flat,
                            i,
                            cycle_count - i
                        );

                    assign valid_A_in[i][j] =
                        (cycle_count >= i) &&
                        (cycle_count < i + 4);

                end

                else begin

                    assign A_PE_in[i][j] =
                        A_PE_out[i][j-1];

                    assign valid_A_in[i][j] =
                        valid_A_out[i][j-1];

                end

                // =====================================
                // B: vertical data movement
                // =====================================

                if (i == 0) begin

                    assign B_PE_in[i][j] =
                        get_B_element(
                            B_flat,
                            cycle_count - j,
                            j
                        );

                    assign valid_B_in[i][j] =
                        (cycle_count >= j) &&
                        (cycle_count < j + 4);

                end

                else begin

                    assign B_PE_in[i][j] =
                        B_PE_out[i-1][j];

                    assign valid_B_in[i][j] =
                        valid_B_out[i-1][j];

                end

                // =====================================
                // Processing Element
                // =====================================

                processing_element #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) PE (

                    .clk(clk),
                    .rst(rst),

                    .A_in(A_PE_in[i][j]),
                    .B_in(B_PE_in[i][j]),

                    .valid_A_in(valid_A_in[i][j]),
                    .valid_B_in(valid_B_in[i][j]),

                    .A_out(A_PE_out[i][j]),
                    .B_out(B_PE_out[i][j]),

                    .valid_A_out(valid_A_out[i][j]),
                    .valid_B_out(valid_B_out[i][j]),

                    .Acc(Acc[i][j])

                );

                // =====================================
                // Matrix C output
                // =====================================

                assign C_flat[32*(i*4+j) +: 32] =
                    Acc[i][j];

            end

        end

    endgenerate

endmodule