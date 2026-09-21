`timescale 1ns / 1ps

// ================================================================
// Project 1: Lithium-Ion Battery Modeling & SOC Estimation
// Module   : soc_compare
// Purpose  : Compare Coulomb Counting SOC and OCV-based SOC
// Tool     : Xilinx Vivado
//
// SOC representation:
//   10000 = 100.00%
//    5000 = 50.00%
//       0 = 0.00%
//
// Outputs:
//   signed_error : SOC_CC - SOC_OCV
//   abs_error    : absolute difference
//
// Example:
//   SOC_CC  = 8500  -> 85.00%
//   SOC_OCV = 8300  -> 83.00%
//
//   signed_error = +200 -> +2.00%
//   abs_error    = 200 ->  2.00%
// ================================================================

module soc_compare (

    // ------------------------------------------------------------
    // Coulomb-counting SOC
    // ------------------------------------------------------------

    input wire [13:0] soc_coulomb,

    // ------------------------------------------------------------
    // OCV-based SOC
    // ------------------------------------------------------------

    input wire [13:0] soc_ocv,

    // ------------------------------------------------------------
    // Signed SOC difference
    //
    // Positive:
    //   SOC_CC > SOC_OCV
    //
    // Negative:
    //   SOC_CC < SOC_OCV
    //
    // Unit:
    //   1 count = 0.01%
    // ------------------------------------------------------------

    output reg signed [14:0] signed_error,

    // ------------------------------------------------------------
    // Absolute SOC error
    //
    // Unit:
    //   1 count = 0.01%
    // ------------------------------------------------------------

    output reg [13:0] abs_error

);

    // ------------------------------------------------------------
    // Temporary signed difference
    // ------------------------------------------------------------

    reg signed [14:0] difference;

    // ------------------------------------------------------------
    // Comparison logic
    // ------------------------------------------------------------

    always @(*) begin

        // --------------------------------------------------------
        // Calculate difference
        // --------------------------------------------------------

        difference =
            $signed({1'b0, soc_coulomb}) -
            $signed({1'b0, soc_ocv});

        // --------------------------------------------------------
        // Signed error
        // --------------------------------------------------------

        signed_error = difference;

        // --------------------------------------------------------
        // Absolute error
        // --------------------------------------------------------

        if (difference < 0)

            abs_error = -difference;

        else

            abs_error = difference;

    end

endmodule