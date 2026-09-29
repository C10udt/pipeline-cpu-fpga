`timescale 1ns / 1ps

// Visit all nine digit addresses and write the platform's active-low blank code.
module blank_seven_segment #(
    parameter integer SCAN_DIV = 100_000
) (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] seg_cs,
    output wire [7:0] seg_data
);
    reg [31:0] divider;
    assign seg_data = 8'hFF;

    always @(posedge clk) begin
        if (reset) begin
            divider <= 32'd0;
            seg_cs  <= 4'd0;
        end else if (divider == SCAN_DIV - 1) begin
            divider <= 32'd0;
            if (seg_cs == 4'd8)
                seg_cs <= 4'd0;
            else
                seg_cs <= seg_cs + 4'd1;
        end else begin
            divider <= divider + 32'd1;
        end
    end
endmodule
