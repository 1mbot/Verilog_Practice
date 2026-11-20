module agc_event_fifo #(

    parameter WIDTH = 80,
    parameter DEPTH = 300,
    parameter PTR_WIDTH = 9,
    parameter COUNT_WIDTH = 9
)(

    input wire clk,
    input wire rst,
    input wire clear,
    input wire push,
    input wire [WIDTH-1:0] data_in,
    input wire pop,

    output wire [WIDTH-1:0] data_out,
    output wire empty,
    output wire full,
    output reg [COUNT_WIDTH-1:0] occupancy,
    output reg [COUNT_WIDTH-1:0] max_occupancy,
    output reg [31:0] lost_events
);

    reg [WIDTH-1:0] memory [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] wr_ptr;
    reg [PTR_WIDTH-1:0] rd_ptr;

    //status flag

    assign empty = (occupancy == 0);

    assign full = (occupancy == DEPTH);

    //read current fifo head

    assign data_out = empty ? {WIDTH{1'b0}} : memory[rd_ptr];

    //accpted operations

    wire accepted_pop;
    wire accepted_push;

    assign accepted_pop = pop && !empty;
    assign accepted_push = push && (!full || accepted_pop);

    always @(posedge clk) begin

        if (rst || clear) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            occupancy <= 0;
            max_occupancy <= 0;
            lost_events <= 0;
        end

        else begin
            // write operation

            if (accepted_push) begin

                memory[wr_ptr] <= data_in;

                if (wr_ptr == DEPTH-1)

                    wr_ptr <= 0;

                else

                    wr_ptr <= wr_ptr + 1'b1;

            end

            // write goes overflow

            if (push && full && !accepted_pop)

                lost_events <= lost_events +1'b1;

            // read operation

            if (accepted_pop) begin

                if (rd_ptr == DEPTH-1)
                    rd_ptr <= 0;

                else

                    rd_ptr <= rd_ptr + 1'b1;

            end

            // Occupancy

            case ({accepted_push, accepted_pop})

                2'b10:

                    occupancy <= occupancy + 1'b1;

                2'b01:

                    occupancy <= occupancy - 1'b1;

                default:

                    occupancy <= occupancy;
            
            endcase

            // maximum occupancy

            if (accepted_push && !accepted_pop) begin

                if ((occupancy + 1'b1) > max_occupancy)

                    max_occupancy <= occupancy + 1'b1;

            end

            else if (occupancy > max_occupancy)

                max_occupancy <= occupancy;

            

        end

    end

endmodule