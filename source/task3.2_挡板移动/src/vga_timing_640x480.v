`timescale 1ns / 1ps

// 640x480 @ approximately 60 Hz with a 25 MHz pixel clock.
// The supplied cg_fpga video input expects active-high control signals.
module vga_timing_640x480 (
    input  wire        pixel_clk,
    input  wire        reset,
    input  wire [9:0]  paddle_x,
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
    (* ASYNC_REG = "TRUE" *) reg [9:0] paddle_meta;
    (* ASYNC_REG = "TRUE" *) reg [9:0] paddle_sync;
    reg [9:0] paddle_frame;

    always @(posedge pixel_clk) begin
        if (reset) begin
            pixel_x      <= 10'd0;
            pixel_y      <= 10'd0;
            paddle_meta  <= 10'd278;
            paddle_sync  <= 10'd278;
            paddle_frame <= 10'd278;
        end else begin
            paddle_meta <= paddle_x;
            paddle_sync <= paddle_meta;
            // Update once per frame so a CPU write cannot tear the paddle.
            if ((pixel_x == 10'd0) && (pixel_y == 10'd0))
                paddle_frame <= paddle_sync;

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

    paddle_renderer u_renderer (
        .active_video (vid_active),
        .pixel_x      (pixel_x),
        .pixel_y      (pixel_y),
        .paddle_x     (paddle_frame),
        .pixel_rgb    (vid_data)
    );
endmodule
