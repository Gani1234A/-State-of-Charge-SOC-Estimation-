`timescale 1ns / 1ps

// ================================================================
// Project 1: Lithium-Ion Battery Modeling & SOC Estimation
// Module   : battery_top
// Description:
//   Top-level integration of:
//     1. Dynamic Load Profile
//     2. Battery Voltage Model
//     3. Coulomb Counting SOC
//     4. OCV-based SOC
//     5. SOC Comparison
//
// Tool:
//   Xilinx Vivado
//
// Current convention:
//   + current = DISCHARGE
//   - current = CHARGE
//
// SOC representation:
//   10000 = 100.00%
//       0 =   0.00%
//
// Voltage:
//   mV
//
// Current:
//   mA
// ================================================================

module battery_top #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer CAPACITY_MAH = 2500,
    parameter integer R_INTERNAL_MOHM = 50,
    parameter integer INITIAL_SOC = 10000
)(
    input wire clk,
    input wire rst,

    // ------------------------------------------------------------
    // Main outputs
    // ------------------------------------------------------------

    output wire signed [15:0] current_ma,

    output wire [15:0] ocv_mv,

    output wire [15:0] battery_voltage_mv,

    output wire [13:0] soc_coulomb,

    output wire [13:0] soc_ocv,

    output wire signed [14:0] soc_signed_error,

    output wire [13:0] soc_abs_error
);

    // ============================================================
    // MODULE 1
    // Dynamic Load Profile
    // ============================================================

    load_profile #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    )
    u_load_profile (
        .clk(clk),
        .rst(rst),

        .current_ma(current_ma)
    );


    // ============================================================
    // MODULE 2
    // Battery Voltage Model
    //
    // Vbattery = OCV - I*R
    // ============================================================

    voltage_model #(
        .R_INTERNAL_MOHM(R_INTERNAL_MOHM)
    )
    u_voltage_model (
        .soc(soc_coulomb),

        .current_ma(current_ma),

        .ocv_mv(ocv_mv),

        .battery_voltage_mv(battery_voltage_mv)
    );


    // ============================================================
    // MODULE 3
    // Coulomb Counting SOC
    // ============================================================

    soc_coulomb #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .CAPACITY_MAH(CAPACITY_MAH),
        .INITIAL_SOC(INITIAL_SOC)
    )
    u_soc_coulomb (
        .clk(clk),
        .rst(rst),

        .current_ma(current_ma),

        .soc(soc_coulomb)
    );


    // ============================================================
    // MODULE 4
    // OCV-based SOC
    // ============================================================

    ocv_soc u_ocv_soc (
        .ocv_mv(ocv_mv),

        .soc_ocv(soc_ocv)
    );


    // ============================================================
    // MODULE 5
    // SOC Comparison
    // ============================================================

    soc_compare u_soc_compare (
        .soc_coulomb(soc_coulomb),

        .soc_ocv(soc_ocv),

        .signed_error(soc_signed_error),

        .abs_error(soc_abs_error)
    );

endmodule