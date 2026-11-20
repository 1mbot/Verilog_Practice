module agc_system_bus (
    
    input wire clk,
    input wire rst,
    input wire bus_write,
    input wire bus_read,
    input wire [31:0] bus_addr,
    input wire [31:0] bus_wdata,

    output reg [31:0] bus_rdata,
    output reg bus_ready,
    output reg [11:0] alpha_threshold,
    output reg [11:0] gamma_threshold,
    output reg [15:0] alpha_min_duration,
    output reg [15:0] gamma_min_duration,
    output reg fifo_clear,
    
    input wire [31:0] lost_events,
    input wire [8:0] fifo_occupancy,
    input wire [8:0] fifo_max_occupancy,
    input wire fifo_empty,
    input wire [79:0] fifo_data,
    output reg fifo_pop
);

    reg [79:0] event_latch;
    reg event_latched;

    always @(posedge clk) begin

        if (rst) begin
            alpha_threshold <= 100;
            gamma_threshold <= 100;
            alpha_min_duration <= 1;
            gamma_min_duration <= 1;
            fifo_clear <= 0;
            fifo_pop <= 0;
            bus_rdata <= 0;
            bus_ready <= 0;
            event_latch <= 0;
            event_latched <= 0;

        end

        else begin

            bus_ready <= 0;
            fifo_clear <= 0;
            fifo_pop <= 0;

            // Write

            if (bus_write) begin

                bus_ready <= 1;

                case (bus_addr)

                    32'h0000:
                        alpha_threshold <= bus_wdata[11:0];

                    32'h0004:
                        gamma_threshold <= bus_wdata[11:0];

                    32'h0008:
                        alpha_min_duration <= bus_wdata[15:0];

                    32'h000C:
                        gamma_min_duration <= bus_wdata[15:0];

                    32'h0010:

                        if(bus_wdata[0])
                            fifo_clear <= 1;

                    default:


                        ;


                endcase

            end


            // Read

            if (bus_read) begin

                bus_ready <= 1;

                case (bus_addr)
                    //lost event

                    32'h0014:

                        bus_rdata <= lost_events;

                    //fifo stat

                    32'h0018:

                        bus_rdata <= {
                            7'd0,
                            fifo_max_occupancy,
                            7'd0,
                            fifo_occupancy
                        };

                    //event metadata

                    32'h0020: begin

                        if (!fifo_empty) begin

                            event_latch <= fifo_data;

                            event_latched <= 1;

                            bus_rdata <= {
                                18'd0,
                                fifo_data[75:64],
                                fifo_data[76],
                                1'b1
                            };

                        end

                        else begin

                            bus_rdata <= 0;
                            event_latched <= 0;

                        end

                    end

                    // timestamp low

                    32'h0024:

                        bus_rdata <= event_latch[31:0];

                        //timestamp high
                        // reading this address consumes the event


                    32'h0028: begin

                        bus_rdata <= event_latch[63:32];

                        if (event_latched) begin
                            fifo_pop <= 1;

                            event_latched <= 0;

                        end

                    end

                    default:

                        bus_rdata <= 0;

                endcase

            end
        
        end
        
    end

endmodule

