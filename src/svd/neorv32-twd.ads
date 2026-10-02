pragma Style_Checks (Off);

--  This spec has been automatically generated from neorv32.svd

pragma Restrictions (No_Elaboration_Code);

with System;

--  Two-wire device controller
package NEORV32.TWD is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype CTRL_TWD_CTRL_EN_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_CLR_RX_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_CLR_TX_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_FSEL_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_DEV_ADDR_Field is NEORV32.UInt7;
   subtype CTRL_TWD_CTRL_IRQ_RX_AVAIL_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_IRQ_RX_FULL_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_IRQ_TX_EMPTY_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_IRQ_TX_NFULL_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_IRQ_COM_BEG_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_IRQ_COM_END_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_RX_FIFO_Field is NEORV32.UInt4;
   subtype CTRL_TWD_CTRL_TX_FIFO_Field is NEORV32.UInt4;
   subtype CTRL_TWD_CTRL_RX_AVAIL_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_RX_FULL_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_TX_EMPTY_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_TX_FULL_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_COM_BEG_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_COM_END_Field is NEORV32.Bit;
   subtype CTRL_TWD_CTRL_COM_Field is NEORV32.Bit;

   --  Control register
   type CTRL_Register is record
      --  TWD enable flag
      TWD_CTRL_EN           : CTRL_TWD_CTRL_EN_Field := 16#0#;
      --  Write-only. Clear RX FIFO, flag auto-clears
      TWD_CTRL_CLR_RX       : CTRL_TWD_CTRL_CLR_RX_Field := 16#0#;
      --  Write-only. Clear TX FIFO, flag auto-clears
      TWD_CTRL_CLR_TX       : CTRL_TWD_CTRL_CLR_TX_Field := 16#0#;
      --  Bus sample clock / filter select
      TWD_CTRL_FSEL         : CTRL_TWD_CTRL_FSEL_Field := 16#0#;
      --  Device address (7-bit)
      TWD_CTRL_DEV_ADDR     : CTRL_TWD_CTRL_DEV_ADDR_Field := 16#0#;
      --  IRQ if RX FIFO data available
      TWD_CTRL_IRQ_RX_AVAIL : CTRL_TWD_CTRL_IRQ_RX_AVAIL_Field := 16#0#;
      --  IRQ if RX FIFO full
      TWD_CTRL_IRQ_RX_FULL  : CTRL_TWD_CTRL_IRQ_RX_FULL_Field := 16#0#;
      --  IRQ if TX FIFO empty
      TWD_CTRL_IRQ_TX_EMPTY : CTRL_TWD_CTRL_IRQ_TX_EMPTY_Field := 16#0#;
      --  IRQ if TX FIFO is not full
      TWD_CTRL_IRQ_TX_NFULL : CTRL_TWD_CTRL_IRQ_TX_NFULL_Field := 16#0#;
      --  IRQ if begin of communication
      TWD_CTRL_IRQ_COM_BEG  : CTRL_TWD_CTRL_IRQ_COM_BEG_Field := 16#0#;
      --  IRQ if end of communication
      TWD_CTRL_IRQ_COM_END  : CTRL_TWD_CTRL_IRQ_COM_END_Field := 16#0#;
      --  Read-only. log2(TWD RX FIFO size)
      TWD_CTRL_RX_FIFO      : CTRL_TWD_CTRL_RX_FIFO_Field := 16#0#;
      --  Read-only. log2(TWD TX FIFO size)
      TWD_CTRL_TX_FIFO      : CTRL_TWD_CTRL_TX_FIFO_Field := 16#0#;
      --  Read-only. RX FIFO data available
      TWD_CTRL_RX_AVAIL     : CTRL_TWD_CTRL_RX_AVAIL_Field := 16#0#;
      --  Read-only. RX FIFO full
      TWD_CTRL_RX_FULL      : CTRL_TWD_CTRL_RX_FULL_Field := 16#0#;
      --  Read-only. TX FIFO empty
      TWD_CTRL_TX_EMPTY     : CTRL_TWD_CTRL_TX_EMPTY_Field := 16#0#;
      --  Read-only. TX FIFO full
      TWD_CTRL_TX_FULL      : CTRL_TWD_CTRL_TX_FULL_Field := 16#0#;
      --  communication has started; clear by writing 1
      TWD_CTRL_COM_BEG      : CTRL_TWD_CTRL_COM_BEG_Field := 16#0#;
      --  communication has ended; clear by writing 1
      TWD_CTRL_COM_END      : CTRL_TWD_CTRL_COM_END_Field := 16#0#;
      --  Read-only. active communication
      TWD_CTRL_COM          : CTRL_TWD_CTRL_COM_Field := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CTRL_Register use record
      TWD_CTRL_EN           at 0 range 0 .. 0;
      TWD_CTRL_CLR_RX       at 0 range 1 .. 1;
      TWD_CTRL_CLR_TX       at 0 range 2 .. 2;
      TWD_CTRL_FSEL         at 0 range 3 .. 3;
      TWD_CTRL_DEV_ADDR     at 0 range 4 .. 10;
      TWD_CTRL_IRQ_RX_AVAIL at 0 range 11 .. 11;
      TWD_CTRL_IRQ_RX_FULL  at 0 range 12 .. 12;
      TWD_CTRL_IRQ_TX_EMPTY at 0 range 13 .. 13;
      TWD_CTRL_IRQ_TX_NFULL at 0 range 14 .. 14;
      TWD_CTRL_IRQ_COM_BEG  at 0 range 15 .. 15;
      TWD_CTRL_IRQ_COM_END  at 0 range 16 .. 16;
      TWD_CTRL_RX_FIFO      at 0 range 17 .. 20;
      TWD_CTRL_TX_FIFO      at 0 range 21 .. 24;
      TWD_CTRL_RX_AVAIL     at 0 range 25 .. 25;
      TWD_CTRL_RX_FULL      at 0 range 26 .. 26;
      TWD_CTRL_TX_EMPTY     at 0 range 27 .. 27;
      TWD_CTRL_TX_FULL      at 0 range 28 .. 28;
      TWD_CTRL_COM_BEG      at 0 range 29 .. 29;
      TWD_CTRL_COM_END      at 0 range 30 .. 30;
      TWD_CTRL_COM          at 0 range 31 .. 31;
   end record;

   subtype DATA_TWI_DATA_Field is NEORV32.Byte;

   --  RX/TX data register
   type DATA_Register is record
      --  *** This field is modified following a read operation ***. RX/TX data
      --  FIFO access
      TWI_DATA      : DATA_TWI_DATA_Field := 16#0#;
      --  unspecified
      Reserved_8_31 : NEORV32.UInt24 := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for DATA_Register use record
      TWI_DATA      at 0 range 0 .. 7;
      Reserved_8_31 at 0 range 8 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  Two-wire device controller
   type TWD_Peripheral is record
      --  Control register
      CTRL : aliased CTRL_Register;
      --  RX/TX data register
      DATA : aliased DATA_Register;
   end record
     with Volatile;

   for TWD_Peripheral use record
      CTRL at 16#0# range 0 .. 31;
      DATA at 16#4# range 0 .. 31;
   end record;

   --  Two-wire device controller
   TWD_Periph : aliased TWD_Peripheral
     with Import, Address => TWD_Base;

end NEORV32.TWD;
