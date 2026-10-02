pragma Style_Checks (Off);

--  This spec has been automatically generated from neorv32.svd

pragma Restrictions (No_Elaboration_Code);

with System;

--  True random number generator
package NEORV32.TRNG is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype CTRL_TRNG_CTRL_EN_Field is NEORV32.Bit;
   subtype CTRL_TRNG_CTRL_FIFO_CLR_Field is NEORV32.Bit;
   subtype CTRL_TRNG_CTRL_SIM_MODE_Field is NEORV32.Bit;
   subtype CTRL_TRNG_CTRL_AVAIL_Field is NEORV32.Bit;
   subtype CTRL_TRNG_CTRL_FIFO_Field is NEORV32.UInt4;
   subtype CTRL_TRNG_CTRL_NBIT_Field is NEORV32.UInt4;
   subtype CTRL_TRNG_CTRL_NRO_Field is NEORV32.Byte;
   subtype CTRL_TRNG_CTRL_NINV_Field is NEORV32.UInt12;

   --  Control and data register
   type CTRL_Register is record
      --  TRNG enable flag
      TRNG_CTRL_EN       : CTRL_TRNG_CTRL_EN_Field := 16#0#;
      --  Write-only. Clear data FIFO when set (flag auto clears)
      TRNG_CTRL_FIFO_CLR : CTRL_TRNG_CTRL_FIFO_CLR_Field := 16#0#;
      --  Read-only. TRNG simulation mode (PRNG!) active
      TRNG_CTRL_SIM_MODE : CTRL_TRNG_CTRL_SIM_MODE_Field := 16#0#;
      --  Read-only. Random data available
      TRNG_CTRL_AVAIL    : CTRL_TRNG_CTRL_AVAIL_Field := 16#0#;
      --  Read-only. log2(TRNG FIFO depth)
      TRNG_CTRL_FIFO     : CTRL_TRNG_CTRL_FIFO_Field := 16#0#;
      --  Read-only. log2(number of raw bits) processed for one output byte
      TRNG_CTRL_NBIT     : CTRL_TRNG_CTRL_NBIT_Field := 16#0#;
      --  Read-only. Total number of ring-oscillators
      TRNG_CTRL_NRO      : CTRL_TRNG_CTRL_NRO_Field := 16#0#;
      --  Read-only. Number of inverters in first ring-oscillator
      TRNG_CTRL_NINV     : CTRL_TRNG_CTRL_NINV_Field := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CTRL_Register use record
      TRNG_CTRL_EN       at 0 range 0 .. 0;
      TRNG_CTRL_FIFO_CLR at 0 range 1 .. 1;
      TRNG_CTRL_SIM_MODE at 0 range 2 .. 2;
      TRNG_CTRL_AVAIL    at 0 range 3 .. 3;
      TRNG_CTRL_FIFO     at 0 range 4 .. 7;
      TRNG_CTRL_NBIT     at 0 range 8 .. 11;
      TRNG_CTRL_NRO      at 0 range 12 .. 19;
      TRNG_CTRL_NINV     at 0 range 20 .. 31;
   end record;

   subtype DATA_TRNG_DATA_Field is NEORV32.Byte;

   --  Random data
   type DATA_Register is record
      --  Read-only. *** This field is modified following a read operation ***.
      --  Random data
      TRNG_DATA     : DATA_TRNG_DATA_Field;
      --  unspecified
      Reserved_8_31 : NEORV32.UInt24;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for DATA_Register use record
      TRNG_DATA     at 0 range 0 .. 7;
      Reserved_8_31 at 0 range 8 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  True random number generator
   type TRNG_Peripheral is record
      --  Control and data register
      CTRL : aliased CTRL_Register;
      --  Random data
      DATA : aliased DATA_Register;
   end record
     with Volatile;

   for TRNG_Peripheral use record
      CTRL at 16#0# range 0 .. 31;
      DATA at 16#4# range 0 .. 31;
   end record;

   --  True random number generator
   TRNG_Periph : aliased TRNG_Peripheral
     with Import, Address => TRNG_Base;

end NEORV32.TRNG;
