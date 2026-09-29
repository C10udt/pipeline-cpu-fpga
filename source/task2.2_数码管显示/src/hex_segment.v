`timescale 1ns / 1ps

// Hex digit to 7-segment encoder (active-low, common anode).
// seg_data is {dp,g,f,e,d,c,b,a}.
// Supports 0-9 and A-F display.
module hex_segment (
    input  wire [3:0]  hex_digit,
    output reg  [7:0]  seg_data
);
    always @* begin
        case (hex_digit)
            4'h0: seg_data = 8'hC0;
            4'h1: seg_data = 8'hF9;
            4'h2: seg_data = 8'hA4;
            4'h3: seg_data = 8'hB0;
            4'h4: seg_data = 8'h99;
            4'h5: seg_data = 8'h92;
            4'h6: seg_data = 8'h82;
            4'h7: seg_data = 8'hF8;
            4'h8: seg_data = 8'h80;
            4'h9: seg_data = 8'h90;
            4'hA: seg_data = 8'h88;
            4'hB: seg_data = 8'h83;
            4'hC: seg_data = 8'hC6;
            4'hD: seg_data = 8'hA1;
            4'hE: seg_data = 8'h86;
            4'hF: seg_data = 8'h8E;
            default: seg_data = 8'hFF;
        endcase
    end
endmodule
