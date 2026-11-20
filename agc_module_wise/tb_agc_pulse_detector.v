`timescale 1ns/1ps

module tb_agc_pulse_detector;

    reg clk;
    reg rst;

    reg [11:0] amplitude;
    reg [11:0] threshold;

    reg [15:0] min_duration;

    reg [63:0] timestamp;

    wire event_valid;
    wire [11:0] event_peak;
    wire [63:0] event_timestamp;

    agc_pulse_detector DUT (
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

        min_duration = 3;

        timestamp = 64'd1234;

        repeat (2) @(posedge clk);

        @(negedge clk);
        rst = 0;

        // Qualified pulse

        @(negedge clk);
        amplitude = 150;

        @(negedge clk);
        amplitude = 250;

        @(negedge clk);
        amplitude = 180;

        @(negedge clk);
        amplitude = 0;

        @(posedge clk);
        #1;

        if (event_valid !== 1'b1)
            $fatal(1, "ERROR: Qualified pulse not detected");

        if (event_peak != 250)
            $fatal(1, "ERROR: Incorrect peak");

        if (event_timestamp != 1234)
            $fatal(1, "ERROR: Incorrect timestamp");

        // Short pulse

        @(negedge clk);
        amplitude = 200;

        @(negedge clk);
        amplitude = 0;

        @(posedge clk);
        #1;

        if (event_valid)
            $fatal(1, "ERROR: Short pulse incorrectly accepted");

        $display("PASS: Pulse detector");

        $finish;

    end

endmodule