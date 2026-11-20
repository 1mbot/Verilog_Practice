module agc_top (

    input wire clk,

    input wire rst,

    input wire [11:0] alpha_amplitude,

    input wire [11:0] gamma_amplitude,

    input wire bus_write,

    input wire bus_read,

    input wire [31:0] bus_addr,

    input wire [31:0] bus_wdata,

    output wire [31:0] bus_rdata,

    output wire bus_ready,

    output wire [8:0] fifo_occupancy,

    output wire fifo_empty,

    output wire fifo_full

);

    // ==================================
    // Timestamp
    // ==================================

    wire [63:0] timestamp;

    agc_timestamp timestamp_unit (

        .clk(clk),

        .rst(rst),

        .timestamp(timestamp)

    );

    // ==================================
    // Configuration registers
    // ==================================

    wire [11:0] alpha_threshold;

    wire [11:0] gamma_threshold;

    wire [15:0] alpha_min_duration;

    wire [15:0] gamma_min_duration;

    wire fifo_clear;

    wire fifo_pop;

    // ==================================
    // Alpha detector signals
    // ==================================

    wire alpha_event;

    wire [11:0] alpha_peak;

    wire [63:0] alpha_event_timestamp;

    agc_alpha_detector alpha_detector (

        .clk(clk),

        .rst(rst),

        .amplitude(alpha_amplitude),

        .threshold(alpha_threshold),

        .min_duration(alpha_min_duration),

        .timestamp(timestamp),

        .event_valid(alpha_event),

        .event_peak(alpha_peak),

        .event_timestamp(alpha_event_timestamp)

    );

    // ==================================
    // Gamma detector signals
    // ==================================

    wire gamma_event;

    wire [11:0] gamma_peak;

    wire [63:0] gamma_event_timestamp;

    agc_gamma_detector gamma_detector (

        .clk(clk),

        .rst(rst),

        .amplitude(gamma_amplitude),

        .threshold(gamma_threshold),

        .min_duration(gamma_min_duration),

        .timestamp(timestamp),

        .event_valid(gamma_event),

        .event_peak(gamma_peak),

        .event_timestamp(gamma_event_timestamp)

    );

    // ==================================
    // Event formatters
    // ==================================

    wire alpha_fifo_push;

    wire gamma_fifo_push;

    wire [79:0] alpha_event_word;

    wire [79:0] gamma_event_word;

    agc_event_formatter alpha_formatter (

        .event_valid(alpha_event),

        .event_type(1'b0),

        .peak_amplitude(alpha_peak),

        .timestamp(alpha_event_timestamp),

        .fifo_write(alpha_fifo_push),

        .event_word(alpha_event_word)

    );

    agc_event_formatter gamma_formatter (

        .event_valid(gamma_event),

        .event_type(1'b1),

        .peak_amplitude(gamma_peak),

        .timestamp(gamma_event_timestamp),

        .fifo_write(gamma_fifo_push),

        .event_word(gamma_event_word)

    );

    // ==================================
    // Event arbitration
    // ==================================

    // Alpha priority if both events arrive
    // in the same clock cycle.

    wire fifo_push;

    wire [79:0] fifo_write_data;

    assign fifo_push = alpha_fifo_push | gamma_fifo_push;

    assign fifo_write_data =

        alpha_fifo_push ?

        alpha_event_word :

        gamma_event_word;

    // ==================================
    // FIFO
    // ==================================

    wire [79:0] fifo_data;

    wire [8:0] fifo_max_occupancy;

    wire [31:0] lost_events;

    agc_event_fifo #(

        .WIDTH(80),

        .DEPTH(300),

        .PTR_WIDTH(9),

        .COUNT_WIDTH(9)

    ) FIFO (

        .clk(clk),

        .rst(rst),

        .clear(fifo_clear),

        .push(fifo_push),

        .data_in(fifo_write_data),

        .pop(fifo_pop),

        .data_out(fifo_data),

        .empty(fifo_empty),

        .full(fifo_full),

        .occupancy(fifo_occupancy),

        .max_occupancy(fifo_max_occupancy),

        .lost_events(lost_events)

    );

    // ==================================
    // System bus
    // ==================================

    agc_system_bus BUS (

        .clk(clk),

        .rst(rst),

        .bus_write(bus_write),

        .bus_read(bus_read),

        .bus_addr(bus_addr),

        .bus_wdata(bus_wdata),

        .bus_rdata(bus_rdata),

        .bus_ready(bus_ready),

        .alpha_threshold(alpha_threshold),

        .gamma_threshold(gamma_threshold),

        .alpha_min_duration(alpha_min_duration),

        .gamma_min_duration(gamma_min_duration),

        .fifo_clear(fifo_clear),

        .lost_events(lost_events),

        .fifo_occupancy(fifo_occupancy),

        .fifo_max_occupancy(fifo_max_occupancy),

        .fifo_empty(fifo_empty),

        .fifo_data(fifo_data),

        .fifo_pop(fifo_pop)

    );

endmodule