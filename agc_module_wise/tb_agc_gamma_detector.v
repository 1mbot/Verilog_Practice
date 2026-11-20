`timescale 1ns/1ps

module tb_agc_gamma_detector;

    reg clk, rst;

    reg [11:0] amplitude;
    reg [11:0] threshold;

    reg [15:0] min_duration;

    reg [63:0] timestamp;

    wire event_valid;
    wire [11:0] event_peak;
    wire [63:0] event_timestamp;

    agc_gamma_detector DUT (
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
        threshold = 200;

        min_duration = 2;

        timestamp = 64'd900;

        repeat (2) @(posedge clk);

        @(negedge clk);
        rst = 0;

        @(negedge clk);
        amplitude = 250;

        @(negedge clk);
        amplitude = 400;

        @(negedge clk);
        amplitude = 0;

        @(posedge clk);
        #1;

        if (!event_valid)
            $fatal(1, "Gamma event missing");

        if (event_peak != 400)
            $fatal(1, "Gamma peak incorrect");

        $display("PASS: Gamma detector");

        $finish;

    end

endmodule