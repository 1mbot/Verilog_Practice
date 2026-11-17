module vending_machine (
    input clk,
    input rstn,
    input [1:0] coin,

    output reg vend,
    output reg change5
);

    //State Declarations
    localparam S0 = 3'b000, //0
               S5 = 3'b001, //5
               S10 = 3'b010, //10
               S15 = 3'b011, //vend, no change
               S20 = 3'b100; //Vend return Rs 5

    //Coin encoding
    localparam NO_COIN = 2'b00,
               COIN_5 = 2'b01,
               COIN_10 = 2'b10;

    reg [2:0] present_state, next_state;

    // 1. Sequential Logic

    always @(posedge clk)
    begin
        if(!rstn)
            present_state <= S0;
        else
            present_state <= next_state;
    end

    //2. Next State Logic

    always @(*)
    begin
        next_state = present_state;

        case(present_state)

            //0 deposited
            S0:
            begin
                case(coin)

                    NO_COIN:
                        next_state = S0;

                    COIN_5:
                        next_state = S5;

                    COIN_10:
                        next_state = S10;
                    
                    default:
                        next_state = S0;

                endcase
            end

            // 5 deposited
            S5:
            begin
                case(coin)

                    NO_COIN:
                        next_state = S5;

                    COIN_5:
                        next_state = S10;

                    COIN_10:
                        next_state = S5;

                    default:
                        next_state = S5;

                endcase
            end

            // 10 deposited
            S10:
            begin
                case(coin)

                    NO_COIN:
                        next_state = S10;
                    
                    COIN_5:
                        next_state = S15;

                    COIN_10:
                        next_state = S20;

                    default:
                        next_state = S10;

                    
                endcase
            end

            //Product dispensed with 5rs change
            S20:
                next_state = S0;

            default:
                next_state = S0;

        endcase
    end


    //3. Output Logic Moore machine

    always @(*)
    begin
        vend = 1'b0;
        change5 = 1'b0;

        case (present_state)

            S15:
            begin
                vend = 1'b1;
                change5 = 1'b1;
            end

            S20:
            begin
                vend = 1'b1;
                change5 = 1'b1;
            end

            default:
            begin
                vend = 1'b0;
                change5 = 1'b0;
            end
        endcase
    end

endmodule

                
