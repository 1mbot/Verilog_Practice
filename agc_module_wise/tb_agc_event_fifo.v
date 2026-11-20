`timescale 1ns/1ps

module tb_agc_event_fifo;

    reg clk;
    reg rst;
    reg clear;

    reg push;
    reg [79:0] data_in;

    reg pop;

    wire [79:0] data_out;

    wire empty;
    wire full;

    wire [8:0] occupancy;
    wire [8:0] max_occupancy;

    wire [31:0] lost_events;

    agc_event_fifo DUT (

        .clk(clk),

        .rst(rst),

        .clear(clear),

        .push(push),

        .data_in(data_in),

        .pop(pop),

        .data_out(data_out),

        .empty(empty),

        .full(full),

        .occupancy(occupancy),

        .max_occupancy(max_occupancy),

        .lost_events(lost_events)

    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;

        rst = 1;

        clear = 0;

        push = 0;

        pop = 0;

        data_in = 0;

        repeat (2) @(posedge clk);

        @(negedge clk);

        rst = 0;

        // Push first event

        push = 1;

        data_in = 80'h1111;

        @(negedge clk);

        data_in = 80'h2222;

        @(negedge clk);

        push = 0;

        if (occupancy != 2)

            $fatal(1, "Occupancy should be 2");

        // Check FIFO head

        if (data_out != 80'h1111)

            $fatal(1, "Incorrect FIFO head");

        // Pop first event

        @(negedge clk);

        pop = 1;

        @(negedge clk);

        pop = 0;

        if (occupancy != 1)

            $fatal(1, "Occupancy should be 1");

        if (data_out != 80'h2222)

            $fatal(1, "FIFO ordering error");

        $display("PASS: FIFO");

        $finish;

    end

endmodule