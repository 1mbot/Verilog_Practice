module tb_mux16to1;
    reg [15:0] A;
    reg [3:0] S;
    wire F;

    mux16to1 DUT (.in(A), .sel(S), .out(F));

    integer i;

    initial
        begin
            $dumpfile("mux16to1.vcd");
            $dumpvars(0, tb_mux16to1);

            A = 16'hA35C;
            
            for (i = 0; i< 16; i = i+1)
            begin
                S = i;
                #10;
                $display("S = %d, F = %b, expected = %b", S, F, A[S]);

                if(F !== A[S])
                    $display("ERROR!");

                else
                    $display("PASS");
            end

            $finish;
        end
endmodule