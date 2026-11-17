module traffic_light_fsm #(
    parameter NS_GREEN_T = 5,
    parameter NS_YELLOW_T = 2,
    parameter EW_GREEN_T = 5,
    parameter EW_YELLOW_T = 2,
    parameter ALL_RED_T = 1,
    parameter PED_WALK_T = 4
)
(
    input clk,
    input rstn,
    input ped_button,

    output reg ns_red,
    output reg ns_yellow,
    output reg ns_green,

    output reg ew_red,
    output reg ew_yellow,
    output reg ew_green,

    output reg ped_walk
);

    //state declarations
    localparam S0 = 3'b000, //NS Green
               S1 = 3'b001, // NS YELLOW
               S2 = 3'b010, // ALL RED before NW
               S3 = 3'b011, // EW GREEN
               S4 = 3'b100, // EW Yellow
               S5 = 3'b101, // ALL RED before NS
               S6 = 3'b110; // PEDESTRIAN WALK

    reg [2:0] present_state, next_state;

    //Timer and pedestrian request memory

    reg [31:0] timer;
    reg ped_pending;

    // 1. Sequential Logic
    always @(posedge clk)
    begin
        if (!rstn)
        begin
            present_state <= S0;
            timer <= 0;
            ped_pending <=0;
        end
        else
        begin
            // Remember pedestrian request
            if (ped_button)
                ped_pending <= 1'b1;

            // Clear request after pedestrian crossing
            if (present_state == S6)
                ped_pending <= 1'b0;
            
            // State transition and timer management
            if (next_state != present_state)
            begin
                present_state <= next_state;
                timer <=0;
            end

            else
            begin
                present_state <= present_state;
                timer <= timer + 1'b1;
            end
        end
    end

    // 2. Next state Logic
    always @(*)
    begin
        next_state = present_state;

        case (present_state)

            S0:
                if (timer >= NS_GREEN_T-1)
                    next_state = S1;
                
            S1:
                if (timer >= NS_YELLOW_T-1)
                    next_state = S2;

            S2:
                if (timer >= ALL_RED_T-1)
                    next_state = S3;

            S3:
                if (timer >= EW_GREEN_T-1)
                    next_state = S4;

            S4:
                if (timer >= EW_YELLOW_T-1)
                    next_state = S5;

            S5:
                if (timer >= ALL_RED_T-1)
                begin
                    if (ped_pending)
                        next_state = S6;
                    else    
                        next_state = S0;
                end

            S6: 
                if (timer >= PED_WALK_T-1)
                    next_state = S0;

            default:
                next_state = S0;
            
        endcase
    end


    // 3. Output logic (Moore Machine)

    always @(*)
    begin
        // Default outputs
        ns_red = 1'b0;
        ns_yellow = 1'b0;
        ns_green = 1'b0;

        ew_red = 1'b0;
        ew_yellow = 1'b0;
        ew_green = 1'b0;

        ped_walk = 1'b0;

        case (present_state)

            S0:
            begin
                ns_green = 1'b1;
                ew_red = 1'b1;
            end

            S1:
            begin
                ns_yellow = 1'b1;
                ew_red = 1'b1;
            end

            S2:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            S3:
            begin
                ns_red = 1'b1;
                ew_green = 1'b1;
            end

            S4:
            begin
                ns_red = 1'b1;
                ew_yellow = 1'b1;
            end

            S5:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end

            S6:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
                ped_walk = 1'b1;
            end

            default:
            begin
                ns_red = 1'b1;
                ew_red = 1'b1;
            end
        endcase
    end
endmodule
        