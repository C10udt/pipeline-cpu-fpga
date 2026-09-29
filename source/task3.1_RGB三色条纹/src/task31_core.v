`timescale 1ns / 1ps

module task31_core #(
    parameter integer TICK_CYCLES = 10_000_000
) (
    input  wire        cpu_clk,
    input  wire        pixel_clk,
    input  wire        reset,
    output wire [31:0] debug_pc,
    output wire        vid_active,
    output wire [23:0] vid_data,
    output wire        vid_hblank,
    output wire        vid_hsync,
    output wire        vid_vblank,
    output wire        vid_vsync,
    output wire [6:0]  audio
);
    // Stripe colour registers — written by the CPU, read by VGA.
    wire [23:0] cpu_colour_top;
    wire [23:0] cpu_colour_middle;
    wire [23:0] cpu_colour_bottom;
    wire        cpu_audio_enable;

    task31_pipeline_cpu u_cpu (
        .clk           (cpu_clk),
        .reset         (reset),
        .colour_top    (cpu_colour_top),
        .colour_middle (cpu_colour_middle),
        .colour_bottom (cpu_colour_bottom),
        .audio_enable  (cpu_audio_enable),
        .debug_pc      (debug_pc)
    );

    vga_timing_640x480 u_vga (
        .pixel_clk        (pixel_clk),
        .reset            (reset),
        .cpu_colour_top   (cpu_colour_top),
        .cpu_colour_middle(cpu_colour_middle),
        .cpu_colour_bottom(cpu_colour_bottom),
        .vid_active       (vid_active),
        .vid_data         (vid_data),
        .vid_hblank       (vid_hblank),
        .vid_hsync        (vid_hsync),
        .vid_vblank       (vid_vblank),
        .vid_vsync        (vid_vsync)
    );

    tone_generator u_tone (
        .clk    (cpu_clk),
        .reset  (reset),
        .enable (cpu_audio_enable),
        .audio  (audio)
    );
endmodule
