`timescale 1ns / 1ps

// Top level for the educg.net online FPGA platform.
// The cg_fpga_0 instance is generated from the supplied cg_fpga v1.4 IP.
module task11_top (
    inout  wire [14:0] DDR_addr,
    inout  wire [2:0]  DDR_ba,
    inout  wire        DDR_cas_n,
    inout  wire        DDR_ck_n,
    inout  wire        DDR_ck_p,
    inout  wire        DDR_cke,
    inout  wire        DDR_cs_n,
    inout  wire [3:0]  DDR_dm,
    inout  wire [31:0] DDR_dq,
    inout  wire [3:0]  DDR_dqs_n,
    inout  wire [3:0]  DDR_dqs_p,
    inout  wire        DDR_odt,
    inout  wire        DDR_ras_n,
    inout  wire        DDR_reset_n,
    inout  wire        DDR_we_n,
    inout  wire        FIXED_IO_ddr_vrn,
    inout  wire        FIXED_IO_ddr_vrp,
    inout  wire [53:0] FIXED_IO_mio,
    inout  wire        FIXED_IO_ps_clk,
    inout  wire        FIXED_IO_ps_porb,
    inout  wire        FIXED_IO_ps_srstb
);
    wire [7:0]  btn;
    wire [0:0]  btn_clk;
    wire [0:0]  btn_rst;
    wire        clk_100M;
    wire [31:0] gpio_sw_1;
    wire [31:0] gpio_sw_2;
    wire [31:0] led_value;
    wire [31:0] debug_pc;
    wire        reset = ~btn_rst[0];

    task11_core u_task11_core (
        .clk       (clk_100M),
        .reset     (reset),
        .led_value (led_value),
        .debug_pc  (debug_pc)
    );

    cg_fpga_0 u_platform (
        .DDR_addr          (DDR_addr),
        .DDR_ba            (DDR_ba),
        .DDR_cas_n         (DDR_cas_n),
        .DDR_ck_n          (DDR_ck_n),
        .DDR_ck_p          (DDR_ck_p),
        .DDR_cke           (DDR_cke),
        .DDR_cs_n          (DDR_cs_n),
        .DDR_dm            (DDR_dm),
        .DDR_dq            (DDR_dq),
        .DDR_dqs_n         (DDR_dqs_n),
        .DDR_dqs_p         (DDR_dqs_p),
        .DDR_odt           (DDR_odt),
        .DDR_ras_n         (DDR_ras_n),
        .DDR_reset_n       (DDR_reset_n),
        .DDR_we_n          (DDR_we_n),
        .FIXED_IO_ddr_vrn  (FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp  (FIXED_IO_ddr_vrp),
        .FIXED_IO_mio      (FIXED_IO_mio),
        .FIXED_IO_ps_clk   (FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb  (FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb (FIXED_IO_ps_srstb),
        .audio             (7'h7F),
        .btn               (btn),
        .btn_clk           (btn_clk),
        .btn_rst           (btn_rst),
        .clk_100M          (clk_100M),
        .gpio_led          (~led_value),
        .gpio_sw_1         (gpio_sw_1),
        .gpio_sw_2         (gpio_sw_2),
        .ledm_cs           (6'h3F),
        .ledm_data         (16'hFFFF),
        .rx_0              (1'b1),
        .seg_cs            (4'hF),
        .seg_data          (8'hFF),
        .tx_0              (),
        .vid_active        (1'b0),
        .vid_data          (24'd0),
        .vid_hblank        (1'b1),
        .vid_hsync         (1'b0),
        .vid_io_in_clk     (clk_100M),
        .vid_vblank        (1'b1),
        .vid_vsync         (1'b0)
    );
endmodule
