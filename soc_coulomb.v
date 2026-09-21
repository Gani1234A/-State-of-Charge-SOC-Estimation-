`timescale 1ns / 1ps

// ================================================================
// Project 1: Lithium-Ion Battery Modeling & SOC Estimation
// Module   : soc_coulomb
// Method   : Coulomb Counting
// Tool     : Xilinx Vivado
//
// Current convention:
//   + current = DISCHARGE
//   - current = CHARGE
//
// SOC representation:
//   10000 = 100.00%
//    7500 = 75.00%
//    5000 = 50.00%
//    2500 = 25.00%
//       0 = 0.00%
//
// Battery capacity:
//   2500 mAh = 2.5 Ah
//
// SOC update:
//   SOC = SOC - I*dt/Capacity
//
// Since current is in mA and dt = 1 second:
//
//   ?SOC(%) = I(mA) / (Capacity(mAh) * 3600) * 100
//
// ================================================================

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

    // ------------------------------------------------------------
    // 1-second clock counter
    // ------------------------------------------------------------

    reg [31:0] clk_counter;

    // ------------------------------------------------------------
    // Internal high-resolution SOC
    //
    // 1,000,000 = 100%
    // 10,000    = 1%
    //
    // This gives much better accuracy than directly truncating
    // the SOC change to 0.01%.
    // ------------------------------------------------------------

    reg [31:0] soc_high_res;

    // ------------------------------------------------------------
    // Temporary signed variables
    // ------------------------------------------------------------

    reg signed [63:0] delta_soc;
    reg signed [63:0] new_soc;

    // ------------------------------------------------------------
    // One-second SOC update
    // ------------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            clk_counter <= 32'd0;

            // 100% SOC
            // 100% = 1,000,000 in high-resolution format
            soc_high_res <= INITIAL_SOC * 100;

            soc <= INITIAL_SOC;

        end

        else begin

            // ----------------------------------------------------
            // Generate 1-second update
            // ----------------------------------------------------

            if (clk_counter >= CLK_FREQ_HZ - 1) begin

                clk_counter <= 32'd0;

                // ------------------------------------------------
                // Coulomb counting calculation
                //
                // delta SOC high resolution:
                //
                // I(mA) × 1,000,000
                // -----------------
                // Capacity(mAh) × 3600
                //
                // Positive current = discharge
                // therefore SOC decreases.
                //
                // Negative current = charge
                // therefore SOC increases.
                // ------------------------------------------------

                delta_soc =
                    (current_ma * 1000000) /
                    (CAPACITY_MAH * 3600);

                // Discharge:
                // new SOC = old SOC - positive delta
                //
                // Charge:
                // current is negative, therefore subtracting
                // a negative value increases SOC.

                new_soc =
                    $signed({1'b0, soc_high_res}) - delta_soc;

                // ------------------------------------------------
                // SOC upper/lower limits
                // ------------------------------------------------

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

                    // Convert:
                    //
                    // 1,000,000 = 100.00%
                    // 10,000    = 100.00%
                    //
                    // Therefore divide by 100.

                    soc <= new_soc / 100;

                end

            end

            else begin

                clk_counter <= clk_counter + 1'b1;

            end

        end

    end

endmodule