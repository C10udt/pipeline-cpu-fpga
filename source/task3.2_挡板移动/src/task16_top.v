`timescale 1ns / 1ps

// Top level for the educg.net cg_fpga v1.4 online FPGA platform.
module task16_top (
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
    wire [7:0]  btn_raw;
    wire [0:0]  btn_clk_raw;
    wire [0:0]  btn_rst_raw;
    wire        clk_100m;
    wire [31:0] gpio_sw_1;
    wire [31:0] gpio_sw_2;
    wire [3:0]  seg_cs;
    wire [7:0]  seg_data;

    wire pixel_clk;
    wire pixel_locked;
    wire panel_reset = ~btn_rst_raw[0];
    wire system_reset = panel_reset | ~pixel_locked;

    wire [9:0]  paddle_x;
    wire [31:0] debug_pc;
    wire        vid_active;
    wire [23:0] vid_data;
    wire        vid_hblank;
    wire        vid_hsync;
    wire        vid_vblank;
    wire        vid_vsync;

    pixel_clock_25m u_pixel_clock (
        .clk_100m  (clk_100m),
        .reset     (panel_reset),
        .pixel_clk (pixel_clk),
        .locked    (pixel_locked)
    );

    task16_core u_task16_core (
        .cpu_clk    (clk_100m),
        .pixel_clk  (pixel_clk),
        .reset      (system_reset),
        // btn[7:0] maps to BTN8..BTN1 and is active-low. The CPU uses
        // logical active-high button bits, so BTN4=buttons[3], BTN2=buttons[1].
        .buttons    (~btn_raw),
        .paddle_x   (paddle_x),
        .debug_pc   (debug_pc),
        .vid_active (vid_active),
        .vid_data   (vid_data),
        .vid_hblank (vid_hblank),
        .vid_hsync  (vid_hsync),
        .vid_vblank (vid_vblank),
        .vid_vsync  (vid_vsync)
    );

    blank_seven_segment u_blank_display (
        .clk      (clk_100m),
        .reset    (system_reset),
        .seg_cs   (seg_cs),
        .seg_data (seg_data)
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
        .btn               (btn_raw),
        .btn_clk           (btn_clk_raw),
        .btn_rst           (btn_rst_raw),
        .clk_100M          (clk_100m),
        .gpio_led          (32'hFFFF_FFFF),
        .gpio_sw_1         (gpio_sw_1),
        .gpio_sw_2         (gpio_sw_2),
        .ledm_cs           (6'h3F),
        .ledm_data         (16'hFFFF),
        .rx_0              (1'b1),
        .seg_cs            (seg_cs),
        .seg_data          (seg_data),
        .tx_0              (),
        .vid_active        (vid_active),
        .vid_data          (vid_data),
        .vid_hblank        (vid_hblank),
        .vid_hsync         (vid_hsync),
        .vid_io_in_clk     (pixel_clk),
        .vid_vblank        (vid_vblank),
        .vid_vsync         (vid_vsync)
    );
endmodule
