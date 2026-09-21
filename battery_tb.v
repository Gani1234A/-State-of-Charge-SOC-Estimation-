`timescale 1ns / 1ps

// ================================================================
// Project 1: Lithium-Ion Battery Modeling & SOC Estimation
// Testbench : battery_tb
// Tool      : Xilinx Vivado
//
// Purpose:
//   Verify the complete battery_top design.
//
// Tested:
//   1. Dynamic current profile
//   2. Battery voltage
//   3. Coulomb-counting SOC
//   4. OCV-based SOC
//   5. SOC estimation error
//
// IMPORTANT:
//   Simulation clock = 1 MHz
//
//   Therefore:
//       CLK_FREQ_HZ = 1,000,000
//
//   This makes one simulated second equal to one million
//   clock cycles instead of 50 million cycles.
//
// ================================================================

module battery_tb;

    // ------------------------------------------------------------
    // Simulation clock
    // ------------------------------------------------------------

    reg clk;

    // ------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------

    reg rst;

    // ------------------------------------------------------------
    // Outputs from battery_top
    // ------------------------------------------------------------

    wire signed [15:0] current_ma;

    wire [15:0] ocv_mv;

    wire [15:0] battery_voltage_mv;

    wire [13:0] soc_coulomb;

    wire [13:0] soc_ocv;

    wire signed [14:0] soc_signed_error;

    wire [13:0] soc_abs_error;


    // ============================================================
    // DUT
    // Device Under Test
    // ============================================================

    battery_top #(

        // --------------------------------------------------------
        // Simulation clock
        // --------------------------------------------------------

        .CLK_FREQ_HZ(1_000_000),

        // --------------------------------------------------------
        // Battery capacity
        // 2.5 Ah = 2500 mAh
        // --------------------------------------------------------

        .CAPACITY_MAH(2500),

        // --------------------------------------------------------
        // Internal resistance
        // 50 milliohm
        // --------------------------------------------------------

        .R_INTERNAL_MOHM(50),

        // --------------------------------------------------------
        // Initial SOC = 100%
        // --------------------------------------------------------

        .INITIAL_SOC(10000)

    )
    dut (

        .clk(clk),

        .rst(rst),

        .current_ma(current_ma),

        .ocv_mv(ocv_mv),

        .battery_voltage_mv(battery_voltage_mv),

        .soc_coulomb(soc_coulomb),

        .soc_ocv(soc_ocv),

        .soc_signed_error(soc_signed_error),

        .soc_abs_error(soc_abs_error)

    );


    // ============================================================
    // CLOCK GENERATION
    //
    // Period = 1000 ns
    // Frequency = 1 MHz
    //
    // ============================================================

    initial begin

        clk = 1'b0;

        forever #500 clk = ~clk;

    end


    // ============================================================
    // RESET + SIMULATION
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initial reset
        // --------------------------------------------------------

        rst = 1'b1;

        // Hold reset for 2 us

        #2000;

        rst = 1'b0;

        // --------------------------------------------------------
        // Run complete load profile
        //
        // Profile duration = 80 seconds
        //
        // Add a small margin at the end.
        // --------------------------------------------------------

        #82_000_000;

        // --------------------------------------------------------
        // End simulation
        // --------------------------------------------------------

        $finish;

    end


    // ============================================================
    // MONITOR
    //
    // Display important values whenever they change.
    //
    // ============================================================

    initial begin

    $monitor(
        "TIME=%0t ns | CURRENT=%0d mA | OCV=%0d mV | V_BAT=%0d mV | SOC_CC=%0d | SOC_OCV=%0d | ERROR=%0d",
        $time,
        current_ma,
        ocv_mv,
        battery_voltage_mv,
        soc_coulomb,
        soc_ocv,
        soc_signed_error
    );

end



    // ============================================================
    // PERIODIC STATUS DISPLAY
    //
    // Prints a readable result approximately every simulated
    // second.
    // ============================================================

    always @(posedge clk) begin

        if (!rst) begin

            if (dut.u_load_profile.clk_counter == 0) begin

                $display(
                    "--------------------------------------------------"
                );

                $display(
                    "TIME = %0t ns",
                    $time
                );

                $display(
                    "Current          = %0d mA",
                    current_ma
                );

                $display(
                    "OCV              = %0d mV",
                    ocv_mv
                );

                $display(
                    "Battery Voltage  = %0d mV",
                    battery_voltage_mv
                );

                $display(
                    "SOC Coulomb      = %0d (0.01%%)",
                    soc_coulomb
                );

                $display(
                    "SOC OCV          = %0d (0.01%%)",
                    soc_ocv
                );

                $display(
                    "Signed Error     = %0d (0.01%%)",
                    soc_signed_error
                );

                $display(
                    "Absolute Error   = %0d (0.01%%)",
                    soc_abs_error
                );

                $display(
                    "--------------------------------------------------"
                );

            end

        end

    end

endmodule