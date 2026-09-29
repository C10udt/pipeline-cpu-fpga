`timescale 1ns / 1ps

// Generate a low-jitter 25 MHz video clock from the platform's 100 MHz clock.
module pixel_clock_25m (
    input  wire clk_100m,
    input  wire reset,
    output wire pixel_clk,
    output wire locked
);
    wire clk_feedback;
    wire clk_feedback_buf;
    wire clk_25m_unbuffered;

    MMCME2_BASE #(
        .BANDWIDTH          ("OPTIMIZED"),
        .CLKFBOUT_MULT_F    (10.000),
        .CLKIN1_PERIOD      (10.000),
        .CLKOUT0_DIVIDE_F   (40.000),
        .DIVCLK_DIVIDE      (1),
        .STARTUP_WAIT       ("FALSE")
    ) u_mmcm (
        .CLKIN1    (clk_100m),
        .RST       (reset),
        .PWRDWN    (1'b0),
        .CLKFBIN   (clk_feedback_buf),
        .CLKFBOUT  (clk_feedback),
        .CLKFBOUTB (),
        .CLKOUT0   (clk_25m_unbuffered),
        .CLKOUT0B  (),
        .CLKOUT1   (),
        .CLKOUT1B  (),
        .CLKOUT2   (),
        .CLKOUT2B  (),
        .CLKOUT3   (),
        .CLKOUT3B  (),
        .CLKOUT4   (),
        .CLKOUT5   (),
        .CLKOUT6   (),
        .LOCKED    (locked)
    );

    BUFG u_feedback_buf (
        .I (clk_feedback),
        .O (clk_feedback_buf)
    );

    BUFG u_pixel_buf (
        .I (clk_25m_unbuffered),
        .O (pixel_clk)
    );
endmodule
