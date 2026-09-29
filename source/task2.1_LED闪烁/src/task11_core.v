`timescale 1ns / 1ps

module task11_core (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] led_value,
    output wire [31:0] debug_pc
);
    wire [31:0] switch_unused;
    assign switch_unused = 32'd0;

    pipeline_cpu u_cpu (
        .clk           (clk),
        .reset         (reset),
        .switch_value  (switch_unused),
        .display_value (led_value),
        .debug_pc      (debug_pc)
    );
endmodule
