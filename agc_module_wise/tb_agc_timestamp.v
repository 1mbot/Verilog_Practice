`timescale 1ns/1ps

module tb_agc_timestamp;

    reg clk;
    reg rst;

    wire [63:0] timestamp;

    agc_timestamp DUT (
        .clk(clk),
        .rst(rst),
        .timestamp(timestamp)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        repeat (2) @(posedge clk);

        @(negedge clk);
        rst = 0;

        @(posedge clk);
        #1;

        if (timestamp != 1)
            $fatal(1, "ERROR: EXPECTED TIMESTAMP 1");

        @(posedge clk);
        #1;

        if (timestamp != 2)
            $fatal(1, "ERROR: Expected timestamp 2");

        @(posedge clk);
        #1;

        if (timestamp != 3)
            $fatal(1, "ERROR: Expected timestamp 3");

        $display("PASS: Timestamp counter");

        $finish;

    end

endmodule    