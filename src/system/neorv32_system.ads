with Interfaces;

--  Facts the SoC reports about itself: hardware version, clock, memory
--  sizes, and which peripherals are in the bitstream.
--
--  Nothing here is configured by software. Every value is read from the
--  hardware (the mimpid CSR and the SYSINFO peripheral).

package NEORV32_System is

   --  NEORV32 release this crate is written against. The registers in
   --  src/svd are generated from the SVD file of this release.
   --  Encoding is the one of the mimpid CSR: v1.13.6 reads 16#0113_0600#.
   Expected_Version : constant Interfaces.Unsigned_32 := 16#0113_0600#;

   function Hardware_Version return Interfaces.Unsigned_32;
   --  Version of the NEORV32 core in the loaded bitstream (mimpid CSR).

   function Version_Matches return Boolean;
   --  True when Hardware_Version = Expected_Version. The board calls this
   --  first and stops with a clear message when it is False: drivers built
   --  for one NEORV32 release are not safe on another.

   function Clock_Hz return Natural;
   --  Frequency of the single SoC clock, in Hz.

   function IMEM_Size return Natural;
   --  Size of the internal instruction memory, in bytes.

   function DMEM_Size return Natural;
   --  Size of the internal data memory, in bytes.

   type Peripheral is
     (GPIO, CLINT, UART0, UART1, SPI, SDI, TWI, TWD, PWM, WDT, TRNG, CFS,
      NEOLED, GPTMR, ONEWIRE, DMA, SLINK, TRACER);

   subtype UART_Peripheral is Peripheral range UART0 .. UART1;

   function Is_Implemented (P : Peripheral) return Boolean;
   --  True when the peripheral was enabled in the bitstream. Touching the
   --  registers of a peripheral that is not implemented traps (bus error),
   --  so drivers check this before their first register access.

end NEORV32_System;
