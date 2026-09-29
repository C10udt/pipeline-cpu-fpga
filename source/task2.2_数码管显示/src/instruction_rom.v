`timescale 1ns / 1ps

// Instruction ROM for program/hex_display.asm.
// Reads DIP switch lower 4 bits and displays hex digit on rightmost segment.
module instruction_rom (
    input  wire [7:0]  addr,
    output reg  [31:0] instr
);
    always @* begin
        case (addr)
            8'd0: instr = 32'h8C01_4000; // lw   $1, 0x4000($0)
            8'd1: instr = 32'h3021_000F; // andi $1, $1, 0xF
            8'd2: instr = 32'hAC01_4004; // sw   $1, 0x4004($0)
            8'd3: instr = 32'h0800_0000; // j    start
            default: instr = 32'h0000_0000; // nop
        endcase
    end
endmodule
