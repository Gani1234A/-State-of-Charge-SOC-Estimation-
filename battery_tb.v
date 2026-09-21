`timescale 1ns / 1ps

module battery_tb;

    reg clk;
    reg rst;
    wire signed [15:0] current_ma;

    wire [15:0] ocv_mv;

    wire [15:0] battery_voltage_mv;

    wire [13:0] soc_coulomb;

    wire [13:0] soc_ocv;

    wire signed [14:0] soc_signed_error;

    wire [13:0] soc_abs_error;

    battery_top #(

        .CLK_FREQ_HZ(1_000_000),

        .CAPACITY_MAH(2500),

        .R_INTERNAL_MOHM(50),

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

  
    // Period = 1000 ns
    // Frequency = 1 MHz
    initial begin

        clk = 1'b0;

        forever #500 clk = ~clk;

    end

    initial begin
        rst = 1'b1;

       
        #2000;

        rst = 1'b0;

        #82_000_000;
        $finish;

    end

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
