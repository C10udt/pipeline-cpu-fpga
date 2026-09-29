`timescale 1ns / 1ps

module task12_core (
    input  wire        clk,
    input  wire        reset,
    input  wire [3:0]  switch_n,
    output wire [3:0]  seg_cs,
    output wire [7:0]  seg_data,
    output wire [31:0] debug_pc
);
    wire [31:0] display_raw;

    // The platform reports an untouched DIP switch as logic 1.
    // Invert so that all switches off = 0x0.
    wire [31:0] switch_value = {28'd0, ~switch_n};

    pipeline_cpu u_cpu (
        .clk           (clk),
        .reset         (reset),
        .switch_value  (switch_value),
        .display_value (display_raw),
        .debug_pc      (debug_pc)
    );

    // Drive only the rightmost digit (seg_cs = 0).
    assign seg_cs = 4'd0;

    // Encode lower 4 bits of display value to 7-segment hex.
    hex_segment u_hex_segment (
        .hex_digit (display_raw[3:0]),
        .seg_data  (seg_data)
    );
endmodule
