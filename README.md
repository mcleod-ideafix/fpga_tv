# FPGA television

Some crazy experiments about using a FPGA to transmit a TV signal old-style.

"v1" directory contains a design which reads a still image from FPGA memory. Format is 384x288, 1bpp. The image is rendered using a PAL progressive signaling and outputted to the RGB output of the ZX-UNO board ( http://www.zxuno.com ) for monitoring purposes.

At the same time, the RGB output (actually, black/white) is passed onto a AM transmitting module, which uses a phase-acummulating oscillator with a 200 MHz clock to generate two frecuencies:
- 62.25 MHz, used to transmit the sync portion of a TV signal (TV uses negative modulation, so the sync is outputted at the maximum wave energy).
- 20.75 MHz. This signal, being a square wave, has its first harmonic at precisely 62.25 MHz, and with an amplitud of roughly 33% of the original signal. This one is used to encode a black pixel (or blanking period) when it is enabled, or a white pixel, when it is not.

So the TV emitter is actually an AM modulator that outputs these signals:
- 62.25 MHz fundamental frequency, gretest energy, for syncs.
- 20.75 MHz fundamental frequency, 62.25 MHz first harmonic (33% of energy) for black level
- OFF for white level.

Along with the TV emitter, there is an audio emitter, which is a FM modulator. (to be continued...)
