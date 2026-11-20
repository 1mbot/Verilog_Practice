`timescale 1ns/1ps

module tb_agc_event_formatter;

    reg event_valid;
    reg event_type;

    reg [11:0] peak_amplitude;

    reg [63:0] timestamp;

    wire fifo_write;

    wire [79:0] event_word;

    agc_event_formatter DUT (

        .event_valid(event_valid),

        .event_type(event_type),

        .peak_amplitude(peak_amplitude),

        .timestamp(timestamp),

        .fifo_write(fifo_write),

        .event_word(event_word)

    );

    initial begin

        event_valid = 1;

        event_type = 1;

        peak_amplitude = 12'hABC;

        timestamp = 64'h123456789ABCDEF0;

        #1;

        if (!fifo_write)
            $fatal(1, "FIFO write signal incorrect");

        if (event_word[76] != 1)
            $fatal(1, "Event type incorrect");

        if (event_word[75:64] != 12'hABC)
            $fatal(1, "Peak incorrect");

        if (event_word[63:0] != 64'h123456789ABCDEF0)
            $fatal(1, "Timestamp incorrect");

        $display("PASS: Event formatter");

        $finish;

    end

endmodule