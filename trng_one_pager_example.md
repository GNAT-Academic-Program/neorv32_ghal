What does the peripheral do? Give one concrete use case.
--> TRNG: True random number generator


Which registers and fields are needed for its simplest useful operation?
--> CTRL and DATA registers. Inside CTRL, EN and AVAIL fields are the most importants.
--> Data, the 8 lowest bits, are where I find a valid Random Number.

What starts that operation? How can software tell it has completed?
--> Set EN to 1
--> Read AVAIL. When we read 1, it means DATA (8 lowest bits) contain a valid RN.

Which reads or writes have side effects? How does failure or timeout appear?
--> Reading DATA removes one byte from the FIFO. The value cannot be read again.
--> Writing bit 1 of CTRL (FIFO_CLR) empties the FIFO and the bit clears itself.
--> Writing bit 0 of CTRL (EN) starts or stops the generator.

Which VHDL SoC generic enables it, and which physical pins or extra parts are needed?
--> IO_TRNG_EN       => true,
--> IO_TRNG_FIFO     => 4
--> no physical pin

Which generic Ada interface will this driver implement?
--> https://github.com/GNAT-Academic-Program/rng_generic

If it has an interrupt, which FIRQ source is involved? Is the Ada runtime ready to use it?
--> no interrupt at this time