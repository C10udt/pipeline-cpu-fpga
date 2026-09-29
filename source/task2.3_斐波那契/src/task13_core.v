`timescale 1ns / 1ps

module task13_core #(
    parameter integer SCAN_DIV = 100000
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [5:0]  switch_n,
    output wire [31:0] fib_value,
    output wire [31:0] debug_pc,
    output wire [3:0]  seg_cs,
    output wire [7:0]  seg_data
);
    pipeline_cpu u_cpu (
        .clk           (clk),
        .reset         (reset),
        .switch_value  ({26'd0, switch_n}),
        .display_value (fib_value),
        .debug_pc      (debug_pc)
    );

    seven_segment_9digit #(
        .SCAN_DIV (SCAN_DIV)
    ) u_display (
        .clk      (clk),
        .reset    (reset),
        .zero_fill (~|switch_n),
        .value    (fib_value),
        .seg_cs   (seg_cs),
        .seg_data (seg_data)
    );
endmodule
