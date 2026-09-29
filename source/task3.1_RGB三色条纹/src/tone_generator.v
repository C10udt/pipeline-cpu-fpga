`timescale 1ns / 1ps

// Fixed-frequency tone generator for the cg_fpga audio DAC.
// Produces a 1 kHz square wave by toggling between two 7-bit PWM levels.
// The audio output is muted when `enable` is deasserted.
module tone_generator #(
    parameter integer CLOCK_HZ    = 100_000_000,
    parameter integer TONE_HZ     = 1000
) (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [6:0] audio
);
    localparam integer HALF_PERIOD = (CLOCK_HZ / TONE_HZ) / 2;
    localparam integer CNT_WIDTH   = $clog2(HALF_PERIOD);

    reg [CNT_WIDTH-1:0] counter;
    reg                  phase;

    always @(posedge clk) begin
        if (reset) begin
            counter <= {CNT_WIDTH{1'b0}};
            phase   <= 1'b0;
            audio   <= 7'd0;
        end else if (!enable) begin
            counter <= {CNT_WIDTH{1'b0}};
            phase   <= 1'b0;
            audio   <= 7'd0;
        end else if (counter == HALF_PERIOD - 1) begin
            counter <= {CNT_WIDTH{1'b0}};
            phase   <= ~phase;
            audio   <= ~phase ? 7'h7F : 7'h00;
        end else begin
            counter <= counter + {{(CNT_WIDTH-1){1'b0}}, 1'b1};
        end
    end
endmodule
