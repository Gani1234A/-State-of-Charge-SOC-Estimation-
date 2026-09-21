`timescale 1ns / 1ps

// ================================================================
// Project 1: Lithium-Ion Battery Modeling & SOC Estimation
// Module   : battery_model
// Model    : OCV(SOC) + Internal Resistance (Rint)
// Tool     : Xilinx Vivado
//
// Current convention:
//   + current = battery DISCHARGE
//   - current = battery CHARGE
//
// Units:
//   SOC        : 0 to 10000  -> 0.00% to 100.00%
//   Current    : mA
//   Voltage    : mV
//   Resistance : milliohm
// ================================================================

module battery_model #(
    parameter integer R_INTERNAL_MOHM = 50
)(
    input  wire        clk,
    input  wire        rst,

    // Battery SOC
    // 10000 = 100.00%
    //  5000 = 50.00%
    //     0 = 0.00%
    input  wire [13:0] soc,

    // Battery current
    // + = discharge
    // - = charge
    input  wire signed [15:0] current_ma,

    // Battery outputs
    output reg [15:0] ocv_mv,
    output reg [15:0] battery_voltage_mv
);

    // ------------------------------------------------------------
    // Internal signals
    // ------------------------------------------------------------

    reg signed [31:0] voltage_drop_mv;
    reg signed [31:0] calculated_voltage_mv;

    // Product of current and resistance
    reg signed [31:0] current_resistance_product;

    // ------------------------------------------------------------
    // OCV Lookup Table
    //
    // Approximate Li-ion cell OCV curve
    //
    // SOC        OCV
    // 100%       4.20 V
    // 90%        4.10 V
    // 80%        4.05 V
    // 70%        4.00 V
    // 60%        3.95 V
    // 50%        3.90 V
    // 40%        3.85 V
    // 30%        3.80 V
    // 20%        3.75 V
    // 10%        3.65 V
    // 0%         3.00 V
    //
    // Voltage is represented in mV.
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
    // Battery voltage calculation
    //
    // Vbattery = OCV - I * R
    //
    // Current:
    //   mA
    //
    // Resistance:
    //   milliohm
    //
    // Therefore:
    //
    // I(mA) * R(mohm) / 1000 = voltage drop in mV
    //
    // Example:
    //
    // I = 1000 mA
    // R = 50 mohm
    //
    // Voltage drop = 1000 * 50 / 1000
    //               = 50 mV
    //
    // Vbattery = 3900 - 50
    //          = 3850 mV
    // ------------------------------------------------------------

    always @(*) begin

        // Current × resistance
        current_resistance_product =
            current_ma * R_INTERNAL_MOHM;

        // Convert to mV
        voltage_drop_mv =
            current_resistance_product / 1000;

        // V = OCV - I*R
        calculated_voltage_mv =
            $signed({1'b0, ocv_mv}) - voltage_drop_mv;

        // --------------------------------------------------------
        // Voltage saturation
        // Prevent negative voltage and unrealistic values
        // --------------------------------------------------------

        if (calculated_voltage_mv < 0)
            battery_voltage_mv = 16'd0;

        else if (calculated_voltage_mv > 5000)
            battery_voltage_mv = 16'd5000;

        else
            battery_voltage_mv = calculated_voltage_mv[15:0];

    end

endmodule
