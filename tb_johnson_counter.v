module tb_johnson_counter;

    parameter WIDTH = 4;

    reg clk;
    reg rstn;
    wire [WIDTH-1:0] out;

    // DUT instantiation
    johnson_counter #(.WIDTH(WIDTH)) DUT (
        .clk(clk),
        .rstn(rstn),
        .out(out)
    );

    // Clock generation
    always #10 clk = ~clk;

    initial
    begin
        // Initialize signals
        clk = 0;
        rstn = 0;

        // Waveform generation
        $dumpfile("johnson_counter.vcd");
        $dumpvars(0, tb_johnson_counter);

        // Display output
        $monitor("T=%0t | rstn=%b | out=%b", $time, rstn, out);

        // Apply reset for two clock cycles
        repeat(2) @(posedge clk);

        rstn <= 1;

        // Allow counter to complete its sequence
        repeat(10) @(posedge clk);

        $finish;
    end

endmodule