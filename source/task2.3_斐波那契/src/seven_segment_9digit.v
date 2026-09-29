`timescale 1ns / 1ps

// Nine-digit display driver for the online platform.
// seg_data is {dp,g,f,e,d,c,b,a}; a zero bit lights the corresponding
// segment, so all digit patterns and the blanking value are active-low.
module seven_segment_9digit #(
    parameter integer SCAN_DIV = 100000
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        zero_fill,
    input  wire [31:0] value,
    output reg  [3:0]  seg_cs,
    output reg  [7:0]  seg_data
);
    reg [31:0] scan_count;
    reg [3:0]  digit_index;
    wire [35:0] bcd_value;

    function [35:0] to_bcd9;
        input [31:0] binary;
        reg [67:0] shift;
        integer i;
        integer j;
        begin
            shift = 68'd0;
            shift[31:0] = binary;
            for (i = 0; i < 32; i = i + 1) begin
                for (j = 0; j < 9; j = j + 1) begin
                    if (shift[32 + j*4 +: 4] >= 4'd5)
                        shift[32 + j*4 +: 4] = shift[32 + j*4 +: 4] + 4'd3;
                end
                shift = shift << 1;
            end
            to_bcd9 = shift[67:32];
        end
    endfunction

    function [7:0] encode_digit;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: encode_digit = 8'hC0;
                4'd1: encode_digit = 8'hF9;
                4'd2: encode_digit = 8'hA4;
                4'd3: encode_digit = 8'hB0;
                4'd4: encode_digit = 8'h99;
                4'd5: encode_digit = 8'h92;
                4'd6: encode_digit = 8'h82;
                4'd7: encode_digit = 8'hF8;
                4'd8: encode_digit = 8'h80;
                4'd9: encode_digit = 8'h90;
                default: encode_digit = 8'hFF;
            endcase
        end
    endfunction

    assign bcd_value = to_bcd9(value);

    always @(posedge clk) begin
        if (reset) begin
            scan_count  <= 32'd0;
            digit_index <= 4'd0;
        end else if (scan_count == SCAN_DIV - 1) begin
            scan_count <= 32'd0;
            if (digit_index == 4'd8)
                digit_index <= 4'd0;
            else
                digit_index <= digit_index + 4'd1;
        end else begin
            scan_count <= scan_count + 32'd1;
        end
    end

    always @* begin
        seg_cs = digit_index;
        if (reset || zero_fill) begin
            seg_data = encode_digit(4'd0);
        end else begin
            case (digit_index)
                4'd0: seg_data = encode_digit(bcd_value[3:0]);
                4'd1: seg_data = |bcd_value[35:4]  ? encode_digit(bcd_value[7:4])   : 8'hFF;
                4'd2: seg_data = |bcd_value[35:8]  ? encode_digit(bcd_value[11:8])  : 8'hFF;
                4'd3: seg_data = |bcd_value[35:12] ? encode_digit(bcd_value[15:12]) : 8'hFF;
                4'd4: seg_data = |bcd_value[35:16] ? encode_digit(bcd_value[19:16]) : 8'hFF;
                4'd5: seg_data = |bcd_value[35:20] ? encode_digit(bcd_value[23:20]) : 8'hFF;
                4'd6: seg_data = |bcd_value[35:24] ? encode_digit(bcd_value[27:24]) : 8'hFF;
                4'd7: seg_data = |bcd_value[35:28] ? encode_digit(bcd_value[31:28]) : 8'hFF;
                4'd8: seg_data = |bcd_value[35:32] ? encode_digit(bcd_value[35:32]) : 8'hFF;
                default: seg_data = 8'hFF;
            endcase
        end
    end
endmodule
