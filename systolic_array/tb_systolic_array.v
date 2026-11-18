module tb_systolic_array_4x4;

    reg clk;
    reg rst;

    reg [127:0] A_flat;
    reg [127:0] B_flat;

    wire [511:0] C_flat;

    systolic_array_4x4 DUT (
        .clk(clk),
        .rst(rst),
        .A_flat(A_flat),
        .B_flat(B_flat),
        .C_flat(C_flat)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test
    initial begin

        $dumpfile("systolic_array.vcd");
        $dumpvars(0, tb_systolic_array_4x4);

        rst = 1;

        // Matrix A
        A_flat = {
            8'd16, 8'd15, 8'd14, 8'd13,
            8'd12, 8'd11, 8'd10, 8'd9,
            8'd8,  8'd7,  8'd6,  8'd5,
            8'd4,  8'd3,  8'd2,  8'd1
        };

        // Matrix B
        B_flat = {
            8'd16, 8'd15, 8'd14, 8'd13,
            8'd12, 8'd11, 8'd10, 8'd9,
            8'd8,  8'd7,  8'd6,  8'd5,
            8'd4,  8'd3,  8'd2,  8'd1
        };

        // Reset
        #20;
        rst = 0;

        // Allow systolic computation to complete
        #120;

        // Display output matrix
        $display("-------------------------------------");
        $display("       SYSTOLIC ARRAY RESULT");
        $display("-------------------------------------");

        $display("%d %d %d %d",
            C_flat[31:0],
            C_flat[63:32],
            C_flat[95:64],
            C_flat[127:96]);

        $display("%d %d %d %d",
            C_flat[159:128],
            C_flat[191:160],
            C_flat[223:192],
            C_flat[255:224]);

        $display("%d %d %d %d",
            C_flat[287:256],
            C_flat[319:288],
            C_flat[351:320],
            C_flat[383:352]);

        $display("%d %d %d %d",
            C_flat[415:384],
            C_flat[447:416],
            C_flat[479:448],
            C_flat[511:480]);

        $display("-------------------------------------");

        $finish;

    end

endmodule