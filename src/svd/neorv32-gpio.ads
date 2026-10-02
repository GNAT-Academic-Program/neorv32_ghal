pragma Style_Checks (Off);

--  This spec has been automatically generated from neorv32.svd

pragma Restrictions (No_Elaboration_Code);

with System;

--  General purpose input/output port
package NEORV32.GPIO is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   -----------------
   -- Peripherals --
   -----------------

   --  General purpose input/output port
   type GPIO_Peripheral is record
      --  Parallel input port
      PORT_IN      : aliased NEORV32.UInt32;
      --  Parallel output port
      PORT_OUT     : aliased NEORV32.UInt32;
      --  Port direction configuration: 0 = input, 1 = output
      PORT_DIR     : aliased NEORV32.UInt32;
      --  Interrupt trigger type (level/edge) for each input pin
      IRQ_TYPE     : aliased NEORV32.UInt32;
      --  Interrupt trigger polarity (rising/falling or high/low) for each
      --  input pin
      IRQ_POLARITY : aliased NEORV32.UInt32;
      --  Interrupt enable for each input pin
      IRQ_ENABLE   : aliased NEORV32.UInt32;
      --  Interrupt pending for each input pin; cleared by writing zero
      IRQ_PENDING  : aliased NEORV32.UInt32;
   end record
     with Volatile;

   for GPIO_Peripheral use record
      PORT_IN      at 16#0# range 0 .. 31;
      PORT_OUT     at 16#4# range 0 .. 31;
      PORT_DIR     at 16#8# range 0 .. 31;
      IRQ_TYPE     at 16#10# range 0 .. 31;
      IRQ_POLARITY at 16#14# range 0 .. 31;
      IRQ_ENABLE   at 16#18# range 0 .. 31;
      IRQ_PENDING  at 16#1C# range 0 .. 31;
   end record;

   --  General purpose input/output port
   GPIO_Periph : aliased GPIO_Peripheral
     with Import, Address => GPIO_Base;

end NEORV32.GPIO;
