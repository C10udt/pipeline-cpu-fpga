`timescale 1ns / 1ps

// Instruction ROM for program/led_blink.asm.
// LED blink program: toggle LED0 with software delay loops.
module instruction_rom (
    input  wire [7:0]  addr,
    output reg  [31:0] instr
);
    always @* begin
        case (addr)
            8'd0:  instr = 32'h2001_0001; // addi $1, $0, 1
            8'd1:  instr = 32'hAC01_4004; // sw   $1, 0x4004($0)
            8'd2:  instr = 32'h2002_0800; // addi $2, $0, 2048
            8'd3:  instr = 32'h2003_3000; // addi $3, $0, 0x3000
            8'd4:  instr = 32'h2063_FFFF; // inner1: addi $3, $3, -1
            8'd5:  instr = 32'h1460_FFFE; // bne  $3, $0, inner1
            8'd6:  instr = 32'h2042_FFFF; // addi $2, $2, -1
            8'd7:  instr = 32'h1440_FFFB; // bne  $2, $0, outer1
            8'd8:  instr = 32'hAC00_4004; // sw   $0, 0x4004($0)
            8'd9:  instr = 32'h2002_0800; // addi $2, $0, 2048
            8'd10: instr = 32'h2003_3000; // addi $3, $0, 0x3000
            8'd11: instr = 32'h2063_FFFF; // inner2: addi $3, $3, -1
            8'd12: instr = 32'h1460_FFFE; // bne  $3, $0, inner2
            8'd13: instr = 32'h2042_FFFF; // addi $2, $2, -1
            8'd14: instr = 32'h1440_FFFB; // bne  $2, $0, outer2
            8'd15: instr = 32'h0800_0000; // j    start
            default: instr = 32'h0000_0000; // nop
        endcase
    end
endmodule
