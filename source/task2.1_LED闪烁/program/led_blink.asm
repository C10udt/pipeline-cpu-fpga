# LED blink program for the five-stage CPU in src/pipeline_cpu.v
#
# Memory map:
#   0x00004000  switch input (unused in this program)
#   0x00004004  LED output (32-bit, drives gpio_led)
#
# Register allocation:
#   $1 = LED value (1 = on), $2 = outer delay counter, $3 = inner delay counter
#
# Behaviour:
#   Writes 1 to LEDs → software delay (~0.5 s @ 100 MHz) →
#   writes 0 to LEDs → software delay → repeats forever.
#   LED0 blinks at approximately 1 Hz.

start:
    addi $1, $0, 1
    sw   $1, 0x4004($0)

    addi $2, $0, 0x800
outer_on:
    addi $3, $0, 0x3000
inner_on:
    addi $3, $3, -1
    bne  $3, $0, inner_on
    addi $2, $2, -1
    bne  $2, $0, outer_on

    sw   $0, 0x4004($0)

    addi $2, $0, 0x800
outer_off:
    addi $3, $0, 0x3000
inner_off:
    addi $3, $3, -1
    bne  $3, $0, inner_off
    addi $2, $2, -1
    bne  $2, $0, outer_off

    j    start
