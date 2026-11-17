module testbench_ring_counter;
    parameter WIDTH = 4;
    reg clk;
    reg rstn;
    wire [WIDTH-1:0] out;

    ring_counter #(.WIDTH(WIDTH)) DUT (.clk(clk), .rstn(rstn), .out(out));
    
    always #10 clk = ~clk;

    initial
        begin
            $dumpfile("ring_counter.vcd");
            $dumpvars(0, testbench_ring_counter);
            {clk, rstn} <= 0;

            $monitor ("T=%0T out = %b", $time, out);
            repeat(2) @(posedge clk);
                rstn <= 1;
            repeat(2) @(posedge clk);
                $finish;
        end
endmodule
