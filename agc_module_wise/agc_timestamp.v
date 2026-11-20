module agc_timestamp (
    input wire clk,
    input wire rst,
    output reg [63:0] timestamp
);

    always @(posedge clk) begin
        if (rst)
            timestamp <= 64'd0;
        else
            timestamp <= timestamp + 64'd1;
    end

endmodule