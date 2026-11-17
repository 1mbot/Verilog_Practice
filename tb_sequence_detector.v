module tb_sequence_detector;

    reg clk;
    reg rstn;
    reg x;

    wire z_moore;
    wire z_mealy;

    // Moore FSM
    moore_1011 M1 (
        .clk(clk),
        .rstn(rstn),
        .x(x),
        .z(z_moore)
    );

    // Mealy FSM
    mealy_1011 M2 (
        .clk(clk),
        .rstn(rstn),
        .x(x),
        .z(z_mealy)
    );

    // Clock generation
    always #10 clk = ~clk;

    initial
    begin
        $dumpfile("sequence_detector.vcd");
        $dumpvars(0, tb_sequence_detector);

        $monitor("T=%0t | x=%b | Moore=%b | Mealy=%b",
                 $time, x, z_moore, z_mealy);

        clk = 0;
        rstn = 0;
        x = 0;

        // Reset
        repeat(2) @(posedge clk);
        @(negedge clk);
        rstn = 1;

        // Input sequence: 1011011

        @(negedge clk); x = 1;
        @(negedge clk); x = 0;
        @(negedge clk); x = 1;
        @(negedge clk); x = 1;
        @(negedge clk); x = 0;
        @(negedge clk); x = 1;
        @(negedge clk); x = 1;

        @(negedge clk);
        $finish;
    end

endmodule