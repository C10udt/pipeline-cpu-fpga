# Task 16 paddle controller for the five-stage MIPS-like pipeline CPU.
#
# Memory map:
#   0x00004000  logical active-high buttons (BTN4=bit 3, BTN2=bit 1)
#   0x00004004  100 ms monotonically increasing tick counter
#   0x00004008  paddle left-edge x coordinate
#
# The paddle starts at x=(640-84)/2=278. Every new timer tick moves it
# by eight pixels while a direction button is held. Coordinates are
# clamped to 0..556 so the entire 84-pixel paddle remains visible.

start:
    addi $1, $0, 278
    sw   $1, 0x4008($0)
    lw   $2, 0x4004($0)        # last_tick

wait_tick:
    lw   $3, 0x4004($0)        # current_tick
    beq  $3, $2, wait_tick
    add  $2, $3, $0
    lw   $4, 0x4000($0)        # buttons

    addi $5, $0, 8             # BTN4 mask
    and  $6, $4, $5
    beq  $6, $0, check_right

    addi $7, $0, 8
    slt  $8, $1, $7
    beq  $8, $0, left_step
    add  $1, $0, $0            # clamp at x=0
    j    store

left_step:
    addi $1, $1, -8
    j    store

check_right:
    addi $5, $0, 2             # BTN2 mask
    and  $6, $4, $5
    beq  $6, $0, store

    addi $7, $0, 549
    slt  $8, $1, $7
    beq  $8, $0, right_limit
    addi $1, $1, 8
    j    store

right_limit:
    addi $1, $0, 556           # 640 - 84

store:
    sw   $1, 0x4008($0)
    j    wait_tick
