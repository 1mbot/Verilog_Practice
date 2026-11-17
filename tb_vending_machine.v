module tb_vending_machine;

    reg clk;
    reg rstn;
    reg [1:0] coin;

    wire vend;
    wire change5;

    // DUT instantiation
    vending_machine DUT (
        .clk(clk),
        .rstn(rstn),
        .coin(coin),
        .vend(vend),
        .change5(change5)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Task to insert a coin
    task insert_coin;
        input [1:0] value;

        begin
            @(negedge clk);
            coin = value;

            @(negedge clk);
            coin = 2'b00;
        end
    endtask

    initial
    begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);

        $monitor(
            "T=%0t | Coin=%b | State=%b | Vend=%b | Change5=%b",
            $time, coin, DUT.present_state, vend, change5
        );

        clk = 0;
        rstn = 0;
        coin = 2'b00;

        // Reset
        repeat(2) @(posedge clk);

        @(negedge clk);
        rstn = 1;

        // Transaction 1: Rs.5 + Rs.10
        insert_coin(2'b01);
        insert_coin(2'b10);

        // Allow vending state to return to idle
        repeat(2) @(posedge clk);

        // Transaction 2: Rs.10 + Rs.10
        insert_coin(2'b10);
        insert_coin(2'b10);

        repeat(2) @(posedge clk);

        // Transaction 3: Rs.5 + Rs.5 + Rs.10
        insert_coin(2'b01);
        insert_coin(2'b01);
        insert_coin(2'b10);

        repeat(2) @(posedge clk);

        $finish;
    end

endmodule