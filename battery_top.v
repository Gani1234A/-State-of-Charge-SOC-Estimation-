`timescale 1ns / 1ps


module battery_top #(
    parameter integer CLK_FREQ_HZ = 50_000_000,
    parameter integer CAPACITY_MAH = 2500,
    parameter integer R_INTERNAL_MOHM = 50,
    parameter integer INITIAL_SOC = 10000
)(
    input wire clk,
    input wire rst,

    output wire signed [15:0] current_ma,

    output wire [15:0] ocv_mv,

    output wire [15:0] battery_voltage_mv,

    output wire [13:0] soc_coulomb,

    output wire [13:0] soc_ocv,

    output wire signed [14:0] soc_signed_error,

    output wire [13:0] soc_abs_error
);

    load_profile #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ)
    )
    u_load_profile (
        .clk(clk),
        .rst(rst),

        .current_ma(current_ma)
    );


   

    voltage_model #(
        .R_INTERNAL_MOHM(R_INTERNAL_MOHM)
    )
    u_voltage_model (
        .soc(soc_coulomb),

        .current_ma(current_ma),

        .ocv_mv(ocv_mv),

        .battery_voltage_mv(battery_voltage_mv)
    );


    
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


    

    ocv_soc u_ocv_soc (
        .ocv_mv(ocv_mv),

        .soc_ocv(soc_ocv)
    );


  

    soc_compare u_soc_compare (
        .soc_coulomb(soc_coulomb),

        .soc_ocv(soc_ocv),

        .signed_error(soc_signed_error),

        .abs_error(soc_abs_error)
    );

endmodule
