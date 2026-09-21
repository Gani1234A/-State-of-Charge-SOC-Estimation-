`timescale 1ns / 1ps

// ================================================================
// Project 1: Lithium-Ion Battery Modeling & SOC Estimation
// Module   : voltage_model
// Model    : Rint Battery Voltage Model
// Tool     : Xilinx Vivado
//
// Equation:
//
//      Vbattery = OCV(SOC) - I × Rinternal
//
// Current convention:
//
//      + current = DISCHARGE
//      - current = CHARGE
//
// Units:
//
//      Voltage  = mV
//      Current  = mA
//      Resistance = milliohm
//
// Example:
//
//      OCV       = 3900 mV
//      Current   = 1000 mA
//      R         = 50 milliohm
//
//      Voltage drop = 1000 × 50 / 1000
//                   = 50 mV
//
//      Vbattery = 3900 - 50
//               = 3850 mV
// ================================================================

module voltage_model #(
    parameter integer R_INTERNAL_MOHM = 50
)(
    input wire [13:0] soc,

    // + = discharge
    // - = charge
    input wire signed [15:0] current_ma,

    // Open circuit voltage
    output reg [15:0] ocv_mv,

    // Terminal battery voltage
    output reg [15:0] battery_voltage_mv
);

    // ------------------------------------------------------------
    // Internal calculation signals
    // ------------------------------------------------------------

    reg signed [31:0] ir_product;

    reg signed [31:0] voltage_drop_mv;

    reg signed [31:0] calculated_voltage_mv;

    // ------------------------------------------------------------
    // OCV-SOC lookup table
    //
    // SOC:
    // 10000 = 100%
    //  9000 = 90%
    //  5000 = 50%
    //     0 = 0%
    //
    // OCV:
    // 4200 mV = 4.20 V
    // 3900 mV = 3.90 V
    // 3000 mV = 3.00 V
    // ------------------------------------------------------------

    always @(*) begin

        if (soc >= 14'd10000)
            ocv_mv = 16'd4200;

        else if (soc >= 14'd9000)
            ocv_mv = 16'd4100;

        else if (soc >= 14'd8000)
            ocv_mv = 16'd4050;

        else if (soc >= 14'd7000)
            ocv_mv = 16'd4000;

        else if (soc >= 14'd6000)
            ocv_mv = 16'd3950;

        else if (soc >= 14'd5000)
            ocv_mv = 16'd3900;

        else if (soc >= 14'd4000)
            ocv_mv = 16'd3850;

        else if (soc >= 14'd3000)
            ocv_mv = 16'd3800;

        else if (soc >= 14'd2000)
            ocv_mv = 16'd3750;

        else if (soc >= 14'd1000)
            ocv_mv = 16'd3650;

        else
            ocv_mv = 16'd3000;

    end

    // ------------------------------------------------------------
    // Terminal voltage calculation
    //
    // V = OCV - I*R
    // ------------------------------------------------------------

    always @(*) begin

        // Current(mA) × Resistance(milliohm)
        ir_product = current_ma * R_INTERNAL_MOHM;

        // Convert to mV
        voltage_drop_mv = ir_product / 1000;

        // Terminal voltage
        calculated_voltage_mv =
            $signed({1'b0, ocv_mv}) -
            voltage_drop_mv;

        // --------------------------------------------------------
        // Voltage limits
        // --------------------------------------------------------

        if (calculated_voltage_mv <= 0)

            battery_voltage_mv = 16'd0;

        else if (calculated_voltage_mv >= 5000)

            battery_voltage_mv = 16'd5000;

        else

            battery_voltage_mv =
                calculated_voltage_mv[15:0];

    end

endmodule