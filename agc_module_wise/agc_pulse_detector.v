module agc_pulse_detector #(
    parameter AMP_WIDTH = 12,
    parameter TIME_WIDTH = 64
)(

    input wire clk,
    input wire rst,

    input wire [AMP_WIDTH-1:0] amplitude,
    input wire [AMP_WIDTH-1:0] threshold,

    input wire [15:0] min_duration,

    input wire [TIME_WIDTH-1:0] timestamp,

    output reg event_valid,
    output reg [AMP_WIDTH-1:0] event_peak,
    output reg [TIME_WIDTH-1:0] event_timestamp
);

    reg pulse_active;

    reg [15:0] duration_count;

    reg [AMP_WIDTH-1:0] peak_hold;

    wire above_threshold;

    assign above_threshold = (amplitude >= threshold);

    always @(posedge clk) begin
        if (rst) begin
            pulse_active <= 1'b0;
            duration_count <= 16'd0;
            peak_hold <= 0;
            event_valid <= 1'b0;
            event_peak <= 0;
            event_timestamp <= 0;

        end

        else begin

            //Default: no event this cycle

            event_valid <= 1'b0;

            //Pulse Start

            if (!pulse_active && above_threshold) begin

                pulse_active <= 1'b1;
                duration_count <= 16'd1;
                peak_hold <= amplitude;

            end

            //Pulse Continues

            else if (pulse_active && above_threshold) begin

                if (duration_count != 16'hFFFF)
                    duration_count <= duration_count + 1'b1;

                // Peak Tracking

                if (amplitude > peak_hold)
                    peak_hold <= amplitude;

            end

            //Pulse Ends

            else if (pulse_active && !above_threshold) begin
                if (duration_count >= min_duration) begin
                    event_valid <= 1'b1;
                    event_peak <= peak_hold;
                    event_timestamp <=timestamp;

                end

                pulse_active <= 1'b0;
                duration_count <= 16'd0;
                peak_hold <= 0;

            end

        end
    end
endmodule
