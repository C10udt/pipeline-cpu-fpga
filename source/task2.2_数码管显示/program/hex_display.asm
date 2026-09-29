# Hex display program for the five-stage CPU in src/pipeline_cpu.v
#
# Memory map:
#   0x00004000  switch input (lower 4 bits used)
#   0x00004004  display output (lower 4 bits → rightmost 7-segment digit)
#
# Register allocation:
#   $1 = switch value (masked to lower 4 bits)
#
# Behaviour:
#   Reads DIP switch lower 4 bits as binary 0-F,
#   writes the raw value to the display port.
#   The hex-to-7-segment encoder in task12_core drives the rightmost digit.

start:
    lw   $1, 0x4000($0)
    andi $1, $1, 0xF
    sw   $1, 0x4004($0)
    j    start
