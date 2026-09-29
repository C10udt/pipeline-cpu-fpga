`timescale 1ns / 1ps

// Instruction ROM for program/fibonacci.asm.
// The CPU implements the MIPS32 subset used by this program.
module instruction_rom (
    input  wire [7:0]  addr,
    output reg  [31:0] instr
);
    always @* begin
        case (addr)
            8'd0:  instr = 32'h8C01_4000; // lw   $1, 0x4000($0)
            8'd1:  instr = 32'h1020_000C; // beq  $1, $0, input_zero
            8'd2:  instr = 32'h2002_0001; // addi $2, $0, 1
            8'd3:  instr = 32'h2003_0001; // addi $3, $0, 1
            8'd4:  instr = 32'h2004_0002; // addi $4, $0, 2
            8'd5:  instr = 32'h1022_000A; // beq  $1, $2, done_a
            8'd6:  instr = 32'h1024_0005; // beq  $1, $4, done_b
            8'd7:  instr = 32'h0043_2820; // add  $5, $2, $3
            8'd8:  instr = 32'h0060_1020; // add  $2, $3, $0
            8'd9:  instr = 32'h00A0_1820; // add  $3, $5, $0
            8'd10: instr = 32'h2084_0001; // addi $4, $4, 1
            8'd11: instr = 32'h1481_FFFB; // bne  $4, $1, fib_loop
            8'd12: instr = 32'hAC03_4004; // sw   $3, 0x4004($0)
            8'd13: instr = 32'h0800_0000; // j    start
            8'd14: instr = 32'hAC00_4004; // sw   $0, 0x4004($0)
            8'd15: instr = 32'h0800_0000; // j    start
            8'd16: instr = 32'hAC02_4004; // sw   $2, 0x4004($0)
            8'd17: instr = 32'h0800_0000; // j    start
            default: instr = 32'h0000_0000; // nop
        endcase
    end
endmodule
