`timescale 1ns / 1ps



module ocv_soc (

    input  wire [15:0] ocv_mv,

    output reg [13:0] soc_ocv

);


    always @(*) begin

        if (ocv_mv >= 16'd4200)

            soc_ocv = 14'd10000;


        else if (ocv_mv >= 16'd4100)

            soc_ocv = 14'd9000;

       -

        else if (ocv_mv >= 16'd4050)

            soc_ocv = 14'd8000;

      ----------

        else if (ocv_mv >= 16'd4000)

            soc_ocv = 14'd7000;


        else if (ocv_mv >= 16'd3950)

            soc_ocv = 14'd6000;

        else if (ocv_mv >= 16'd3900)

            soc_ocv = 14'd5000;

     -

        else if (ocv_mv >= 16'd3850)

            soc_ocv = 14'd4000;

      

        else if (ocv_mv >= 16'd3800)

            soc_ocv = 14'd3000;


        else if (ocv_mv >= 16'd3750)

            soc_ocv = 14'd2000;

        
        else if (ocv_mv >= 16'd3650)

            soc_ocv = 14'd1000;
-

        else

            soc_ocv = 14'd0;

    end

endmodule
