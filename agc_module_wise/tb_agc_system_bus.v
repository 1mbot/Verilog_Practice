`timescale 1ns/1ps

module tb_agc_system_bus;

    reg clk;
    reg rst;

    reg bus_write;
    reg bus_read;

    reg [31:0] bus_addr;
    reg [31:0] bus_wdata;

    wire [31:0] bus_rdata;

    wire bus_ready;

    wire [11:0] alpha_threshold;
    wire [11:0] gamma_threshold;

    wire [15:0] alpha_min_duration;
    wire [15:0] gamma_min_duration;

    wire fifo_clear;
    wire fifo_pop;

    reg [31:0] lost_events;

    reg [8:0] fifo_occupancy;
    reg [8:0] fifo_max_occupancy;

    reg fifo_empty;

    reg [79:0] fifo_data;

    agc_system_bus DUT (

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

    always #5 clk = ~clk;

    initial begin

        clk = 0;

        rst = 1;

        bus_write = 0;

        bus_read = 0;

        bus_addr = 0;

        bus_wdata = 0;

        lost_events = 7;

        fifo_occupancy = 3;

        fifo_max_occupancy = 9;

        fifo_empty = 0;

        fifo_data = {3'b000, 1'b1, 12'hABC, 64'h123456789ABCDEF0};

        repeat (2) @(posedge clk);

        @(negedge clk);

        rst = 0;

        // Write alpha threshold

        bus_write = 1;

        bus_addr = 32'h0000;

        bus_wdata = 32'h345;

        @(posedge clk);
        #1;

        if (alpha_threshold != 12'h345)

            $fatal(1, "Alpha threshold write failed");

        // Read lost event register

        @(negedge clk);

        bus_write = 0;

        bus_read = 1;

        bus_addr = 32'h0014;

        @(posedge clk);
        #1;

        if (bus_rdata != 7)

            $fatal(1, "Lost event register read failed");

        // Read event metadata

        @(negedge clk);

        bus_addr = 32'h0020;

        @(posedge clk);
        #1;

        if (bus_rdata[0] != 1)

            $fatal(1, "Event valid bit missing");

        // Read timestamp low

        @(negedge clk);

        bus_addr = 32'h0024;

        @(posedge clk);
        #1;

        if (bus_rdata != 32'h9ABCDEF0)

            $fatal(1, "Timestamp low incorrect");

        // Read timestamp high / consume

        @(negedge clk);

        bus_addr = 32'h0028;

        @(posedge clk);
        #1;

        if (bus_rdata != 32'h12345678)

            $fatal(1, "Timestamp high incorrect");

        $display("PASS: System bus");

        $finish;

    end

endmodule