`timescale 1ns / 1ps

// Instruction ROM for program/paddle.asm.
module task16_instruction_rom (
    input  wire [7:0]  addr,
    output reg  [31:0] instr
);
    always @* begin
        case (addr)
            8'd0:  instr = 32'h2001_0116; // addi $1, $0, 278
            8'd1:  instr = 32'hAC01_4008; // sw   $1, 0x4008($0)
            8'd2:  instr = 32'h8C02_4004; // lw   $2, 0x4004($0)
            8'd3:  instr = 32'h8C03_4004; // wait_tick: lw $3, 0x4004($0)
            8'd4:  instr = 32'h1062_FFFE; // beq  $3, $2, wait_tick
            8'd5:  instr = 32'h0060_1020; // add  $2, $3, $0
            8'd6:  instr = 32'h8C04_4000; // lw   $4, 0x4000($0)
            8'd7:  instr = 32'h2005_0008; // addi $5, $0, 8 (BTN4 mask)
            8'd8:  instr = 32'h0085_3024; // and  $6, $4, $5
            8'd9:  instr = 32'h10C0_0007; // beq  $6, $0, check_right
            8'd10: instr = 32'h2007_0008; // addi $7, $0, 8
            8'd11: instr = 32'h0027_402A; // slt  $8, $1, $7
            8'd12: instr = 32'h1100_0002; // beq  $8, $0, left_step
            8'd13: instr = 32'h0000_0820; // add  $1, $0, $0 (left clamp)
            8'd14: instr = 32'h0800_001A; // j    store
            8'd15: instr = 32'h2021_FFF8; // left_step: addi $1, $1, -8
            8'd16: instr = 32'h0800_001A; // j    store
            8'd17: instr = 32'h2005_0002; // check_right: BTN2 mask
            8'd18: instr = 32'h0085_3024; // and  $6, $4, $5
            8'd19: instr = 32'h10C0_0006; // beq  $6, $0, store
            8'd20: instr = 32'h2007_0225; // addi $7, $0, 549
            8'd21: instr = 32'h0027_402A; // slt  $8, $1, $7
            8'd22: instr = 32'h1100_0002; // beq  $8, $0, right_limit
            8'd23: instr = 32'h2021_0008; // addi $1, $1, 8
            8'd24: instr = 32'h0800_001A; // j    store
            8'd25: instr = 32'h2001_022C; // right_limit: x = 556
            8'd26: instr = 32'hAC01_4008; // store: sw $1, 0x4008($0)
            8'd27: instr = 32'h0800_0003; // j    wait_tick
            default: instr = 32'h0000_0000; // nop
        endcase
    end
endmodule
