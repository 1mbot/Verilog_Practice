`timescale 1ns/1ps

module tb_agc_top;

    reg clk;
    reg rst;

    reg [11:0] alpha_amplitude;
    reg [11:0] gamma_amplitude;

    reg bus_write;
    reg bus_read;

    reg [31:0] bus_addr;
    reg [31:0] bus_wdata;

    wire [31:0] bus_rdata;
    wire bus_ready;

    wire [8:0] fifo_occupancy;

    wire fifo_empty;
    wire fifo_full;

    agc_top DUT (

        .clk(clk),

        .rst(rst),

        .alpha_amplitude(alpha_amplitude),

        .gamma_amplitude(gamma_amplitude),

        .bus_write(bus_write),

        .bus_read(bus_read),

        .bus_addr(bus_addr),

        .bus_wdata(bus_wdata),

        .bus_rdata(bus_rdata),

        .bus_ready(bus_ready),

        .fifo_occupancy(fifo_occupancy),

        .fifo_empty(fifo_empty),

        .fifo_full(fifo_full)

    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;

        rst = 1;

        alpha_amplitude = 0;

        gamma_amplitude = 0;

        bus_write = 0;

        bus_read = 0;

        bus_addr = 0;

        bus_wdata = 0;

        // Reset

        repeat (2) @(posedge clk);

        @(negedge clk);

        rst = 0;

        // ==================================
        // Set alpha threshold = 100
        // ==================================

        bus_write = 1;

        bus_addr = 32'h0000;

        bus_wdata = 100;

        @(negedge clk);

        // ==================================
        // Set alpha minimum duration = 2
        // ==================================

        bus_addr = 32'h0008;

        bus_wdata = 2;

        @(negedge clk);

        bus_write = 0;

        // ==================================
        // Generate alpha pulse
        // ==================================

        alpha_amplitude = 150;

        @(negedge clk);

        alpha_amplitude = 220;

        @(negedge clk);

        alpha_amplitude = 0;

        // Wait for detector and FIFO

        repeat (5) @(posedge clk);

        if (fifo_occupancy == 0)

            $fatal(1, "Integration error: event not stored");

        // ==================================
        // Read event metadata
        // ==================================

        @(negedge clk);

        bus_read = 1;

        bus_addr = 32'h0020;

        @(posedge clk);

        #1;

        if (bus_rdata[0] != 1'b1)

            $fatal(1, "Event valid missing");

        if (bus_rdata[13:2] != 12'd220)

            $fatal(1, "Peak amplitude mismatch");

        if (bus_rdata[1] != 1'b0)

            $fatal(1, "Expected alpha event");

        $display("--------------------------------");

        $display("PASS: AGC top integration");

        $display("FIFO occupancy = %0d", fifo_occupancy);

        $display("--------------------------------");

        $finish;

    end

endmodule