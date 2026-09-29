# Task 3.1: RGB three-colour equal-width horizontal stripes with 1 kHz audio.
#
# Memory map:
#   0x00004000  Stripe 1 colour (top)
#   0x00004004  Stripe 2 colour (middle)
#   0x00004008  Stripe 3 colour (bottom)
#   0x0000400C  Audio control (bit 0 = enable)
#
# Colours are packed in the cg_fpga G_B_R_444 format:
#   vid_data[7:0]=G, [15:8]=B, [23:16]=R.
#   Red    = 24'hFF0000    Green  = 24'h0000FF    Blue   = 24'h00FF00

start:
    lui  $1, 0x00FF       # $1 = 0x00FF0000  (Red in GBR)
    sw   $1, 0x4000($0)   # set stripe 1

    addi $1, $0, 255      # $1 = 0x000000FF  (Green in GBR)
    sw   $1, 0x4004($0)   # set stripe 2

    ori  $1, $0, 0xFF00   # $1 = 0x0000FF00  (Blue in GBR)
    sw   $1, 0x4008($0)   # set stripe 3

    addi $1, $0, 1
    sw   $1, 0x400C($0)   # enable audio

loop:
    j    loop             # spin forever
