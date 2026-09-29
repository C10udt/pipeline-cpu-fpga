# Fibonacci program for the five-stage CPU in src/pipeline_cpu.v
#
# Memory map:
#   0x00004000  switch input n (low six bits are used)
#   0x00004004  nine-digit decimal display output
#
# Register allocation:
#   $1 = n, $2 = a, $3 = b, $4 = i, $5 = next

start:
    lw   $1, 0x4000($0)
    beq  $1, $0, input_zero
    addi $2, $0, 1
    addi $3, $0, 1
    addi $4, $0, 2
    beq  $1, $2, done_a
    beq  $1, $4, done_b

fib_loop:
    add  $5, $2, $3
    add  $2, $3, $0
    add  $3, $5, $0
    addi $4, $4, 1
    bne  $4, $1, fib_loop

done_b:
    sw   $3, 0x4004($0)
    j    start

input_zero:
    sw   $0, 0x4004($0)
    j    start

done_a:
    sw   $2, 0x4004($0)
    j    start
