`timescale 1ns / 1ps

// Renders three equal-width horizontal colour stripes.
// Stripe boundaries are hard-coded (each 160 lines); the colours can be
// overridden by the CPU through the stripe_colour bus, otherwise the
// defaults RGB are used.
module stripe_renderer #(
    // Defaults in G_B_R_444 packing: vid_data[7:0]=G, [15:8]=B, [23:16]=R.
    parameter [23:0] DEFAULT_TOP    = 24'hFF0000,  // Red
    parameter [23:0] DEFAULT_MIDDLE = 24'h0000FF,  // Green
    parameter [23:0] DEFAULT_BOTTOM = 24'h00FF00   // Blue
) (
    input  wire        active_video,
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,
    input  wire [23:0] colour_top,
    input  wire [23:0] colour_middle,
    input  wire [23:0] colour_bottom,
    output reg  [23:0] pixel_rgb
);
    localparam [9:0] STRIPE_HEIGHT = 10'd160;
    localparam [9:0] MID_START     = STRIPE_HEIGHT;       // 160
    localparam [9:0] BOT_START     = STRIPE_HEIGHT * 2;   // 320

    always @* begin
        if (!active_video)
            pixel_rgb = 24'h000000;
        else if (pixel_y < MID_START)
            pixel_rgb = colour_top;
        else if (pixel_y < BOT_START)
            pixel_rgb = colour_middle;
        else
            pixel_rgb = colour_bottom;
    end
endmodule
