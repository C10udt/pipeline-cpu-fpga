`timescale 1ns / 1ps

module paddle_renderer (
    input  wire        active_video,
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,
    input  wire [9:0]  paddle_x,
    output reg  [23:0] pixel_rgb
);
    localparam [9:0] PADDLE_Y      = 10'd456;
    localparam [9:0] PADDLE_WIDTH  = 10'd84;
    localparam [9:0] PADDLE_HEIGHT = 10'd24;
    // cg_fpga's Video In to AXI4-Stream IP is configured as G_B_R_444:
    // vid_data[7:0]=G, [15:8]=B and [23:16]=R.  These are therefore
    // packed platform words, not conventional 0xRRGGBB constants.
    localparam [23:0] BLUE_GBR     = 24'h00FF00;
    localparam [23:0] GREEN_GBR    = 24'h0000FF;

    wire inside_paddle =
        (pixel_x >= paddle_x) &&
        (pixel_x < paddle_x + PADDLE_WIDTH) &&
        (pixel_y >= PADDLE_Y) &&
        (pixel_y < PADDLE_Y + PADDLE_HEIGHT);

    always @* begin
        if (!active_video)
            pixel_rgb = 24'h000000;
        else if (inside_paddle)
            pixel_rgb = GREEN_GBR;
        else
            pixel_rgb = BLUE_GBR;
    end
endmodule
