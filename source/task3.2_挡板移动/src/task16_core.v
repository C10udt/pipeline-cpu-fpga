`timescale 1ns / 1ps

module task16_core #(
    parameter integer TICK_CYCLES = 10_000_000
) (
    input  wire        cpu_clk,
    input  wire        pixel_clk,
    input  wire        reset,
    input  wire [7:0]  buttons,
    output wire [9:0]  paddle_x,
    output wire [31:0] debug_pc,
    output wire        vid_active,
    output wire [23:0] vid_data,
    output wire        vid_hblank,
    output wire        vid_hsync,
    output wire        vid_vblank,
    output wire        vid_vsync
);
    wire [31:0] tick_value;

    timer_100ms #(
        .TICK_CYCLES (TICK_CYCLES)
    ) u_timer (
        .clk        (cpu_clk),
        .reset      (reset),
        .tick_value (tick_value)
    );

    task16_pipeline_cpu u_cpu (
        .clk          (cpu_clk),
        .reset        (reset),
        .button_value (buttons),
        .tick_value   (tick_value),
        .paddle_x     (paddle_x),
        .debug_pc     (debug_pc)
    );

    vga_timing_640x480 u_vga (
        .pixel_clk  (pixel_clk),
        .reset      (reset),
        .paddle_x   (paddle_x),
        .vid_active (vid_active),
        .vid_data   (vid_data),
        .vid_hblank (vid_hblank),
        .vid_hsync  (vid_hsync),
        .vid_vblank (vid_vblank),
        .vid_vsync  (vid_vsync)
    );
endmodule
