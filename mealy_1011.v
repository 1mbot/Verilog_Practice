module mealy_1011 (clk, rstn, x, z);

    input clk;
    input rstn;
    input x;
    output reg z;

    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;

    reg [2:0] present_state, next_state;

    always @ (posedge clk)
        begin
            if(!rstn)
                present_state <= S0;
            else
                present_state <= next_state;
        end

    //Next state and Output Logic

    always @(*)

    begin
        //default assignment

        next_state = S0;
        z = 1'b0;

        case (present_state)
            S0:
                if (x == 1'b0)
                    next_state = S0;
                else
                    next_state = S1;

            S1:
                if (x == 1'b0)
                    next_state = S2;
                else
                    next_state = S1;


            S2:
                if (x == 1'b0)
                    next_state = S0;
                else
                    next_state = S3;


            S3:
                if (x == 1'b0)
                    next_state = S2;
                else
                begin
                    next_state = S1;
                    z = 1'b1;
                end
            
            default:
                begin
                    next_state = S0;
                    z = 1'b0;
                end
        endcase
    end
endmodule
            
