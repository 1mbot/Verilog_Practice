module tb_traffic_light;
    reg clk;
    reg rstn;
    reg ped_button;

    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;
    wire ped_walk;

    traffic_light_fsm #(
        .NS_GREEN_T(3),
        .NS_YELLOW_T(2),
        .EW_GREEN_T(3),
        .EW_YELLOW_T(2),
        .ALL_RED_T(1),
        .PED_WALK_T(3)
    ) DUT (
        .clk(clk),
        .rstn(rstn),
        .ped_button(ped_button),

        .ns_red(ns_red),
        .ns_green(ns_green),
        .ns_yellow(ns_yellow),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green),

        .ped_walk(ped_walk)
    );

    //Clock Generation
    always #10 clk = ~clk;

    initial
    begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);
        $monitor (
            "T = %0t | NS = %b%b%b | EW = %b%b%b | PED = %b | Request = %b",
            $time,
            ns_red, ns_yellow, ns_green,
            ew_red, ew_yellow, ew_green,
            ped_walk, DUT.ped_pending
        );

        clk = 0;
        rstn = 0;
        ped_button = 0;

        //Apply Reset
        repeat(2) @(posedge clk);

        @(negedge clk);
        rstn = 1;

        // Request pedestrian crossing

        @(negedge clk);
        ped_button = 1;

        @(negedge clk);
        ped_button = 0;

        //Allow traffic controller to complete its cycle
        repeat(30) @(posedge clk);

        $finish;
    end
endmodule