module agc_event_formatter (
    
    input wire event_valid,
    input wire event_type,
    input wire [11:0] peak_amplitude,
    input wire [63:0] timestamp,

    output wire fifo_write,
    output wire [79:0] event_word

);

    assign fifo_write = event_valid;

    assign event_word = {

        3'b000,
        event_type,
        peak_amplitude,
        timestamp
    };

endmodule