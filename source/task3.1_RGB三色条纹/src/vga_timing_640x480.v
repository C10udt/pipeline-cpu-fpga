`timescale 1ns / 1ps

// 640x480 @ approximately 60 Hz with a 25 MHz pixel clock.
// The supplied cg_fpga video input expects active-high control signals.
// Stripe colours are double-synchronised from the CPU clock domain and
// latched once per frame to avoid tearing.
module vga_timing_640x480 (
    input  wire        pixel_clk,
    input  wire        reset,
    input  wire [23:0] cpu_colour_top,
    input  wire [23:0] cpu_colour_middle,
    input  wire [23:0] cpu_colour_bottom,
    output wire        vid_active,
    output wire [23:0] vid_data,
    output wire        vid_hblank,
    output wire        vid_hsync,
    output wire        vid_vblank,
    output wire        vid_vsync
);
    localparam integer H_ACTIVE = 640;
    localparam integer H_FRONT  = 16;
    localparam integer H_SYNC   = 96;
    localparam integer H_BACK   = 48;
    localparam integer H_TOTAL  = H_ACTIVE + H_FRONT + H_SYNC + H_BACK;

    localparam integer V_ACTIVE = 480;
    localparam integer V_FRONT  = 10;
    localparam integer V_SYNC   = 2;
    localparam integer V_BACK   = 33;
    localparam integer V_TOTAL  = V_ACTIVE + V_FRONT + V_SYNC + V_BACK;

    reg [9:0] pixel_x;
    reg [9:0] pixel_y;

    // Synchronisers for the three 24-bit colour registers.
    (* ASYNC_REG = "TRUE" *) reg [23:0] top_meta, mid_meta, bot_meta;
    (* ASYNC_REG = "TRUE" *) reg [23:0] top_sync, mid_sync, bot_sync;
    reg [23:0] top_frame, mid_frame, bot_frame;

    always @(posedge pixel_clk) begin
        if (reset) begin
            pixel_x  <= 10'd0;
            pixel_y  <= 10'd0;
            top_meta  <= 24'hFF0000;   // Red
            top_sync  <= 24'hFF0000;
            top_frame <= 24'hFF0000;
            mid_meta  <= 24'h0000FF;   // Green
            mid_sync  <= 24'h0000FF;
            mid_frame <= 24'h0000FF;
            bot_meta  <= 24'h00FF00;   // Blue
            bot_sync  <= 24'h00FF00;
            bot_frame <= 24'h00FF00;
        end else begin
            top_meta <= cpu_colour_top;
            top_sync <= top_meta;
            mid_meta <= cpu_colour_middle;
            mid_sync <= mid_meta;
            bot_meta <= cpu_colour_bottom;
            bot_sync <= bot_meta;

            // Update once per frame so a CPU write cannot tear the display.
            if ((pixel_x == 10'd0) && (pixel_y == 10'd0)) begin
                top_frame  <= top_sync;
                mid_frame  <= mid_sync;
                bot_frame  <= bot_sync;
            end

            if (pixel_x == H_TOTAL - 1) begin
                pixel_x <= 10'd0;
                if (pixel_y == V_TOTAL - 1)
                    pixel_y <= 10'd0;
                else
                    pixel_y <= pixel_y + 10'd1;
            end else begin
                pixel_x <= pixel_x + 10'd1;
            end
        end
    end

    assign vid_active = (pixel_x < H_ACTIVE) && (pixel_y < V_ACTIVE);
    assign vid_hblank = (pixel_x >= H_ACTIVE);
    assign vid_vblank = (pixel_y >= V_ACTIVE);
    assign vid_hsync  = (pixel_x >= H_ACTIVE + H_FRONT) &&
                        (pixel_x <  H_ACTIVE + H_FRONT + H_SYNC);
    assign vid_vsync  = (pixel_y >= V_ACTIVE + V_FRONT) &&
                        (pixel_y <  V_ACTIVE + V_FRONT + V_SYNC);

    stripe_renderer u_renderer (
        .active_video  (vid_active),
        .pixel_x       (pixel_x),
        .pixel_y       (pixel_y),
        .colour_top    (top_frame),
        .colour_middle (mid_frame),
        .colour_bottom (bot_frame),
        .pixel_rgb     (vid_data)
    );
endmodule
