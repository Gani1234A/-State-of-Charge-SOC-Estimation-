`timescale 1ns / 1ps

// ================================================================
// Project 1: Lithium-Ion Battery Modeling & SOC Estimation
// Module   : load_profile
// Purpose  : Generate dynamic battery charge/discharge current
// Tool     : Xilinx Vivado
//
// Current convention:
//   + current = DISCHARGE
//   - current = CHARGE
//
// Example profile:
//   0-10 s   : 0 A
//   10-20 s  : 1 A discharge
//   20-30 s  : 2 A discharge
//   30-40 s  : 0 A
//   40-50 s  : 1 A charge
//   50-60 s  : 2 A discharge
//   60-70 s  : 0 A
//   70-80 s  : 0.5 A charge
// ================================================================

module load_profile #(
    parameter integer CLK_FREQ_HZ = 50_000_000
)(
    input  wire               clk,
    input  wire               rst,

    // Dynamic load current
    // Unit: mA
    // Positive = discharge
    // Negative = charge
    output reg signed [15:0] current_ma
);

    // ------------------------------------------------------------
    // 1-second clock counter
    // ------------------------------------------------------------

    reg [31:0] clk_counter;

    // ------------------------------------------------------------
    // Profile time in seconds
    // ------------------------------------------------------------

    reg [7:0] profile_time;

    // ------------------------------------------------------------
    // Generate one-second timing
    // ------------------------------------------------------------

    always @(posedge clk) begin

        if (rst) begin

            clk_counter  <= 32'd0;
            profile_time <= 8'd0;

        end

        else begin

            if (clk_counter >= CLK_FREQ_HZ - 1) begin

                clk_counter <= 32'd0;

                // Restart profile after 80 seconds
                if (profile_time >= 8'd79)
                    profile_time <= 8'd0;

                else
                    profile_time <= profile_time + 1'b1;

            end

            else begin

                clk_counter <= clk_counter + 1'b1;

            end

        end

    end

    // ------------------------------------------------------------
    // Dynamic current profile
    // ------------------------------------------------------------

    always @(*) begin

        case (profile_time)

            // ----------------------------------------------------
            // 0 - 9 seconds
            // Rest
            // ----------------------------------------------------
            8'd0  : current_ma = 16'sd0;
            8'd1  : current_ma = 16'sd0;
            8'd2  : current_ma = 16'sd0;
            8'd3  : current_ma = 16'sd0;
            8'd4  : current_ma = 16'sd0;
            8'd5  : current_ma = 16'sd0;
            8'd6  : current_ma = 16'sd0;
            8'd7  : current_ma = 16'sd0;
            8'd8  : current_ma = 16'sd0;
            8'd9  : current_ma = 16'sd0;

            // ----------------------------------------------------
            // 10 - 19 seconds
            // 1 A DISCHARGE
            // ----------------------------------------------------
            8'd10 : current_ma = 16'sd1000;
            8'd11 : current_ma = 16'sd1000;
            8'd12 : current_ma = 16'sd1000;
            8'd13 : current_ma = 16'sd1000;
            8'd14 : current_ma = 16'sd1000;
            8'd15 : current_ma = 16'sd1000;
            8'd16 : current_ma = 16'sd1000;
            8'd17 : current_ma = 16'sd1000;
            8'd18 : current_ma = 16'sd1000;
            8'd19 : current_ma = 16'sd1000;

            // ----------------------------------------------------
            // 20 - 29 seconds
            // 2 A DISCHARGE
            // ----------------------------------------------------
            8'd20 : current_ma = 16'sd2000;
            8'd21 : current_ma = 16'sd2000;
            8'd22 : current_ma = 16'sd2000;
            8'd23 : current_ma = 16'sd2000;
            8'd24 : current_ma = 16'sd2000;
            8'd25 : current_ma = 16'sd2000;
            8'd26 : current_ma = 16'sd2000;
            8'd27 : current_ma = 16'sd2000;
            8'd28 : current_ma = 16'sd2000;
            8'd29 : current_ma = 16'sd2000;

            // ----------------------------------------------------
            // 30 - 39 seconds
            // Rest
            // ----------------------------------------------------
            8'd30 : current_ma = 16'sd0;
            8'd31 : current_ma = 16'sd0;
            8'd32 : current_ma = 16'sd0;
            8'd33 : current_ma = 16'sd0;
            8'd34 : current_ma = 16'sd0;
            8'd35 : current_ma = 16'sd0;
            8'd36 : current_ma = 16'sd0;
            8'd37 : current_ma = 16'sd0;
            8'd38 : current_ma = 16'sd0;
            8'd39 : current_ma = 16'sd0;

            // ----------------------------------------------------
            // 40 - 49 seconds
            // 1 A CHARGE
            // Negative current = charging
            // ----------------------------------------------------
            8'd40 : current_ma = -16'sd1000;
            8'd41 : current_ma = -16'sd1000;
            8'd42 : current_ma = -16'sd1000;
            8'd43 : current_ma = -16'sd1000;
            8'd44 : current_ma = -16'sd1000;
            8'd45 : current_ma = -16'sd1000;
            8'd46 : current_ma = -16'sd1000;
            8'd47 : current_ma = -16'sd1000;
            8'd48 : current_ma = -16'sd1000;
            8'd49 : current_ma = -16'sd1000;

            // ----------------------------------------------------
            // 50 - 59 seconds
            // 2 A DISCHARGE
            // ----------------------------------------------------
            8'd50 : current_ma = 16'sd2000;
            8'd51 : current_ma = 16'sd2000;
            8'd52 : current_ma = 16'sd2000;
            8'd53 : current_ma = 16'sd2000;
            8'd54 : current_ma = 16'sd2000;
            8'd55 : current_ma = 16'sd2000;
            8'd56 : current_ma = 16'sd2000;
            8'd57 : current_ma = 16'sd2000;
            8'd58 : current_ma = 16'sd2000;
            8'd59 : current_ma = 16'sd2000;

            // ----------------------------------------------------
            // 60 - 69 seconds
            // Rest
            // ----------------------------------------------------
            8'd60 : current_ma = 16'sd0;
            8'd61 : current_ma = 16'sd0;
            8'd62 : current_ma = 16'sd0;
            8'd63 : current_ma = 16'sd0;
            8'd64 : current_ma = 16'sd0;
            8'd65 : current_ma = 16'sd0;
            8'd66 : current_ma = 16'sd0;
            8'd67 : current_ma = 16'sd0;
            8'd68 : current_ma = 16'sd0;
            8'd69 : current_ma = 16'sd0;

            // ----------------------------------------------------
            // 70 - 79 seconds
            // 0.5 A CHARGE
            // ----------------------------------------------------
            8'd70 : current_ma = -16'sd500;
            8'd71 : current_ma = -16'sd500;
            8'd72 : current_ma = -16'sd500;
            8'd73 : current_ma = -16'sd500;
            8'd74 : current_ma = -16'sd500;
            8'd75 : current_ma = -16'sd500;
            8'd76 : current_ma = -16'sd500;
            8'd77 : current_ma = -16'sd500;
            8'd78 : current_ma = -16'sd500;
            8'd79 : current_ma = -16'sd500;

            default:
                current_ma = 16'sd0;

        endcase

    end

endmodule