`timescale 1ns / 1ps


module soc_coulomb #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer CAPACITY_MAH = 2500,
    parameter integer INITIAL_SOC = 10000
)(
    input  wire               clk,
    input  wire               rst,

    // Battery current
    // + = discharge
    // - = charge
    input  wire signed [15:0] current_ma,

    // SOC output
    // 0 to 10000 = 0.00% to 100.00%
    output reg [13:0] soc
);

    reg [31:0] clk_counter;

    
    // Internal high-resolution SOC
    //
    // 1,000,000 = 100%
    // 10,000    = 1%
    //
    // This gives much better accuracy than directly truncating
    // the SOC change to 0.01%.
    // ------------------------------------------------------------

    reg [31:0] soc_high_res;

    // Temporary signed variables

    reg signed [63:0] delta_soc;
    reg signed [63:0] new_soc;

    // One-second SOC update
 
    always @(posedge clk) begin

        if (rst) begin

            clk_counter <= 32'd0;

            // 100% SOC
            // 100% = 1,000,000 in high-resolution format
            soc_high_res <= INITIAL_SOC * 100;

            soc <= INITIAL_SOC;

        end

        else begin
           
            // Generate 1-second update

            if (clk_counter >= CLK_FREQ_HZ - 1) begin

                clk_counter <= 32'd0;

    

                delta_soc =
                    (current_ma * 1000000) /
                    (CAPACITY_MAH * 3600);

                new_soc =
                    $signed({1'b0, soc_high_res}) - delta_soc;

               
                if (new_soc <= 0) begin

                    soc_high_res <= 32'd0;
                    soc          <= 14'd0;

                end

                else if (new_soc >= 1000000) begin

                    soc_high_res <= 32'd1000000;
                    soc          <= 14'd10000;

                end

                else begin

                    soc_high_res <= new_soc[31:0];

                    soc <= new_soc / 100;

                end

            end

            else begin

                clk_counter <= clk_counter + 1'b1;

            end

        end

    end

endmodule
