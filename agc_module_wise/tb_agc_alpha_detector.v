`timescale 1ns/1ps

module tb_agc_alpha_detector;

    reg clk, rst;

    reg [11:0] amplitude;
    reg [11:0] threshold;

    reg [15:0] min_duration;

    reg [63:0] timestamp;

    wire event_valid;
    wire [11:0] event_peak;
    wire [63:0] event_timestamp;

    agc_alpha_detector DUT (
        .clk(clk),
        .rst(rst),

        .amplitude(amplitude),
        .threshold(threshold),

        .min_duration(min_duration),

        .timestamp(timestamp),

        .event_valid(event_valid),
        .event_peak(event_peak),
        .event_timestamp(event_timestamp)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;

        amplitude = 0;
        threshold = 100;

        min_duration = 2;

        timestamp = 64'd500;

        repeat (2) @(posedge clk);

        @(negedge clk);
        rst = 0;

        @(negedge clk);
        amplitude = 150;

        @(negedge clk);
        amplitude = 300;

        @(negedge clk);
        amplitude = 0;

        @(posedge clk);
        #1;

        if (!event_valid)
            $fatal(1, "Alpha event missing");

        if (event_peak != 300)
            $fatal(1, "Alpha peak incorrect");

        $display("PASS: Alpha detector");

        $finish;

    end

endmodule