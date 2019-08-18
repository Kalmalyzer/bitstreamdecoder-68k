# Bitstream decoder for 68000

3-bit stream decoder, optimized for 68000.

Each value is transformed through a lookup table, and output as 16-bit word.

Performance tends toward 22 cycles/entry when decoding long runs.

# How to use

Include DecodeBitStream_3Bits.* into your application.

# How to develop

Install dev tools:
* [vasmm68k_mot](http://sun.hasenbraten.de/vasm/)
* [vlink](http://sun.hasenbraten.de/vlink/)
* [testrunner-68k](https://github.com/Kalmalyzer/testrunner-68k)

Hack on the code, then run tests: `make test`
