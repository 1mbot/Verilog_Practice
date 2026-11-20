`timescale 1ns/1ps

module tb_agc_data_driven;

    reg clk = 0;
    reg rst = 1;

    reg [11:0] alpha_amplitude = 0;
    reg [11:0] gamma_amplitude = 0;

    reg bus_write = 0;
    reg bus_read  = 0;
    reg [31:0] bus_addr = 0;
    reg [31:0] bus_wdata = 0;

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

    // 100 MHz clock
    always #5 clk = ~clk;


    // ============================================================
    // BUS WRITE
    // ============================================================

    task bus_wr;

        input [31:0] addr;
        input [31:0] data;

        integer timeout;

        begin

            @(negedge clk);

            bus_addr  = addr;
            bus_wdata = data;

            bus_write = 1;
            bus_read  = 0;

            timeout = 0;

            @(posedge clk);

            while ((bus_ready !== 1'b1) && timeout < 20) begin

                timeout = timeout + 1;

                @(posedge clk);

            end

            if (bus_ready !== 1'b1)
                $display("WARNING: BUS WRITE TIMEOUT at %h", addr);

            @(negedge clk);

            bus_write = 0;
            bus_addr  = 0;
            bus_wdata = 0;

        end

    endtask


    // ============================================================
    // BUS READ
    // ============================================================

    task bus_rd;

        input [31:0] addr;
        output [31:0] data;

        integer timeout;

        begin

            @(negedge clk);

            bus_addr = addr;

            bus_read  = 1;
            bus_write = 0;

            timeout = 0;

            @(posedge clk);

            while ((bus_ready !== 1'b1) && timeout < 20) begin

                timeout = timeout + 1;

                @(posedge clk);

            end

            #1 data = bus_rdata;

            if (bus_ready !== 1'b1)
                $display("WARNING: BUS READ TIMEOUT at %h", addr);

            @(negedge clk);

            bus_read = 0;
            bus_addr = 0;

        end

    endtask


    // ============================================================
    // EVENT DATA ARRAYS
    // ============================================================

    localparam MAX_EVENTS = 1000;

    reg [7:0] event_channel [0:MAX_EVENTS-1];

    integer event_start [0:MAX_EVENTS-1];

    integer event_duration [0:MAX_EVENTS-1];

    integer event_amplitude [0:MAX_EVENTS-1];


    integer event_count = 0;
    integer max_cycle = 0;

    integer fd;
    integer scan_result;

    integer start_c;
    integer duration_c;
    integer amp_c;

    reg [7:0] channel_char;

    reg [1023:0] csv_line;


    // ============================================================
    // LOAD CSV FILE
    // ============================================================

    task load_csv;

        begin

            fd = $fopen("agc_events.csv", "r");

            if (fd == 0) begin

                $display("ERROR: Cannot open agc_events.csv");

                $finish;

            end


            // Skip header

            scan_result = $fgets(csv_line, fd);

            event_count = 0;
            max_cycle = 0;


            while (!$feof(fd) && event_count < MAX_EVENTS) begin

                scan_result = $fscanf(
                    fd,
                    "%c,%d,%d,%d\n",
                    channel_char,
                    start_c,
                    duration_c,
                    amp_c
                );


                if (scan_result == 4) begin

                    event_channel[event_count] = channel_char;

                    event_start[event_count] = start_c;

                    event_duration[event_count] = duration_c;

                    event_amplitude[event_count] = amp_c;


                    if (start_c + duration_c > max_cycle)

                        max_cycle = start_c + duration_c;


                    $display(
                        "Loaded: channel=%c start=%0d duration=%0d amplitude=%0d",
                        channel_char,
                        start_c,
                        duration_c,
                        amp_c
                    );


                    event_count = event_count + 1;

                end
                else begin

                    scan_result = $fgets(csv_line, fd);

                end

            end


            $fclose(fd);


            $display("----------------------------------------");

            $display("Total events loaded: %0d", event_count);

            $display("Final event ends at cycle: %0d", max_cycle);

            $display("----------------------------------------");

        end

    endtask


    // ============================================================
    // GENERATE INPUTS FROM CSV
    // ============================================================

    integer cycle;
    integer e;

    integer pulse_a;
    integer pulse_g;


    task drive_cycle;

        input integer current_cycle;

        begin

            pulse_a = 0;
            pulse_g = 0;


            for (e = 0; e < event_count; e = e + 1) begin

                if (
                    current_cycle >= event_start[e] &&
                    current_cycle < event_start[e] + event_duration[e]
                ) begin


                    if (event_channel[e] == "A") begin

                        if (event_amplitude[e] > pulse_a)

                            pulse_a = event_amplitude[e];

                    end


                    else if (event_channel[e] == "G") begin

                        if (event_amplitude[e] > pulse_g)

                            pulse_g = event_amplitude[e];

                    end

                end

            end


            alpha_amplitude = pulse_a[11:0];

            gamma_amplitude = pulse_g[11:0];

        end

    endtask


    // ============================================================
    // READ EVENTS FROM FIFO THROUGH SYSTEM BUS
    // ============================================================

    reg [31:0] event_metadata;

    reg [31:0] timestamp_low;

    reg [31:0] timestamp_high;

    integer events_read = 0;


    task read_fifo_events;

        begin

            events_read = 0;


            // Allow detector/FIFO pipeline to settle

            repeat (5) @(posedge clk);


            while (fifo_occupancy != 0) begin


                // Read event metadata

                bus_rd(32'h00000020, event_metadata);


                // Read timestamp lower 32 bits

                bus_rd(32'h00000024, timestamp_low);


                // Read timestamp upper 32 bits
                // This access also pops the event

                bus_rd(32'h00000028, timestamp_high);


                $display("");

                $display("========== FIFO EVENT ==========");

                $display("Valid      : %b", event_metadata[31]);

                if (event_metadata[30] == 0)

                    $display("Type       : ALPHA");

                else

                    $display("Type       : GAMMA");


                $display("Amplitude  : %0d", event_metadata[29:16]);

                $display("Timestamp  : %0d",
                    {timestamp_high, timestamp_low});

                $display("===============================");


                events_read = events_read + 1;


                @(posedge clk);


                if (events_read > MAX_EVENTS) begin

                    $display("ERROR: FIFO drain safety limit reached");

                    disable read_fifo_events;

                end

            end

        end

    endtask


    // ============================================================
    // MAIN
    // ============================================================

    integer sim_end_cycle;

    reg [31:0] read_data;


    initial begin


        $dumpfile("agc_data_driven.vcd");

        $dumpvars(0, tb_agc_data_driven);


        // Load event data

        load_csv();


        // Reset

        repeat (5) @(posedge clk);

        @(negedge clk);

        rst = 0;


        // --------------------------------------------------------
        // CONFIGURATION
        //
        // Register map assumed:
        // 0x00 Alpha threshold
        // 0x04 Gamma threshold
        // 0x08 Alpha minimum duration
        // 0x0C Gamma minimum duration
        // --------------------------------------------------------

        bus_wr(32'h00000000, 32'd100);

        bus_wr(32'h00000004, 32'd100);

        bus_wr(32'h00000008, 32'd2);

        bus_wr(32'h0000000C, 32'd2);


        $display("");

        $display("Starting CSV-driven simulation...");


        // --------------------------------------------------------
        // Generate events cycle-by-cycle
        // --------------------------------------------------------

        sim_end_cycle = max_cycle + 20;


        for (cycle = 0; cycle <= sim_end_cycle; cycle = cycle + 1) begin

            @(negedge clk);

            drive_cycle(cycle);

            @(posedge clk);

        end


        // Return inputs to zero

        @(negedge clk);

        alpha_amplitude = 0;

        gamma_amplitude = 0;


        $display("");

        $display("Stimulus finished.");

        $display("FIFO occupancy = %0d", fifo_occupancy);


        // --------------------------------------------------------
        // Retrieve events
        // --------------------------------------------------------

        read_fifo_events();


        // --------------------------------------------------------
        // Summary
        // --------------------------------------------------------

        $display("");

        $display("========================================");

        $display("INPUT EVENTS      : %0d", event_count);

        $display("FIFO EVENTS READ  : %0d", events_read);

        $display("SIMULATION DONE");

        $display("========================================");


        $finish;

    end

endmodule