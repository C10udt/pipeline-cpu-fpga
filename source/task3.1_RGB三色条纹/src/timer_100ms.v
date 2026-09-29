`timescale 1ns / 1ps

module timer_100ms #(
    parameter integer CLOCK_HZ    = 100_000_000,
    parameter integer PERIOD_MS   = 100,
    parameter integer TICK_CYCLES = (CLOCK_HZ / 1000) * PERIOD_MS
) (
    input  wire        clk,
    input  wire        reset,
    output reg  [31:0] tick_value
);
    localparam integer COUNTER_WIDTH = $clog2(TICK_CYCLES);
    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk) begin
        if (reset) begin
            counter    <= {COUNTER_WIDTH{1'b0}};
            tick_value <= 32'd0;
        end else if (counter == TICK_CYCLES - 1) begin
            counter    <= {COUNTER_WIDTH{1'b0}};
            tick_value <= tick_value + 32'd1;
        end else begin
            counter <= counter + {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};
        end
    end
endmodule
