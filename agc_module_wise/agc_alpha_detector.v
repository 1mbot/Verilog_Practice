module agc_alpha_detector (
    input wire clk,
    input wire rst,

    input wire [11:0] amplitude,
    input wire [11:0] threshold,
    input wire [15:0] min_duration,
    input wire [63:0] timestamp,
    
    output wire event_valid,
    output wire [11:0] event_peak,
    output wire [63:0] event_timestamp
);
    agc_pulse_detector #(
        .AMP_WIDTH(12),
        .TIME_WIDTH(64)
    ) detector (

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

endmodule