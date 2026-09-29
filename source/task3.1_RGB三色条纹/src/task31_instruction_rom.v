`timescale 1ns / 1ps

// Instruction ROM for program/stripes.asm.
module task31_instruction_rom (
    input  wire [7:0]  addr,
    output reg  [31:0] instr
);
    always @* begin
        case (addr)
            8'd0:  instr = 32'h3C01_00FF; // lui  $1, 0x00FF  (Red in GBR)
            8'd1:  instr = 32'hAC01_4000; // sw   $1, 0x4000($0)
            8'd2:  instr = 32'h2001_00FF; // addi $1, $0, 255  (Green in GBR)
            8'd3:  instr = 32'hAC01_4004; // sw   $1, 0x4004($0)
            8'd4:  instr = 32'h3401_FF00; // ori  $1, $0, 0xFF00 (Blue in GBR)
            8'd5:  instr = 32'hAC01_4008; // sw   $1, 0x4008($0)
            8'd6:  instr = 32'h2001_0001; // addi $1, $0, 1
            8'd7:  instr = 32'hAC01_400C; // sw   $1, 0x400C($0)  enable audio
            8'd8:  instr = 32'h0800_0008; // loop: j loop
            default: instr = 32'h0000_0000; // nop
        endcase
    end
endmodule
