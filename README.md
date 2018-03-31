# Bitstream decoder for 68000

3-bit stream decoder, optimized for 68000.

Each value is transformed through a lookup table, and output as 16-bit word.

Performance tends toward 22 cycles/entry when decoding long runs.

