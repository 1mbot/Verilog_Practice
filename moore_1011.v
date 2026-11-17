// Moore Sequence Detector FSM Sequence = 1011

module moore_1011 (clk, rstn, x, z);
    
    input clk;
    input rstn;
    input x;
    output reg z;

    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;
    reg [2:0] present_state, next_state;

    //Sequential Logic
    always @ (posedge clk)
    begin
        if (!rstn)
            present_state <= S0;
        else 
            present_state <= next_state;
    end

    //Next State Logic

    always @ (*)
    begin
        case (present_state)
            S0 : 
                if (x == 1'b0)
                    next_state = S0;
                else
                    next_state = S1;
            
            S1 : 
                if (x == 1'b0)
                    next_state = S2;
                else
                    next_state = S1;

            S2 : 
                if (x == 1'b0)
                    next_state = S0;
                else
                    next_state = S3;

            S3 : 
                if (x == 1'b0)
                    next_state = S2;
                else
                    next_state = S4;

            S4 : 
                if (x == 1'b0)
                    next_state = S2;
                else
                    next_state = S1;

            default:
                    next_state = S0;
            
        endcase
    end

    // Output Logic

    always @ (*)
    begin
        if (present_state == S4)
            z = 1'b1;
        else
            z = 1'b0;
    end
endmodule