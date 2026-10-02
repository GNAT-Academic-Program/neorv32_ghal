pragma Style_Checks (Off);

--  This spec has been automatically generated from neorv32.svd

pragma Restrictions (No_Elaboration_Code);

with System;

--  Serial Memory Controller
package NEORV32.SMC is
   pragma Preelaborate;

   ---------------
   -- Registers --
   ---------------

   subtype CSR0_SMC_CSR0_EN_Field is NEORV32.Bit;
   subtype CSR0_SMC_CSR0_IOEN_Field is NEORV32.Bit;
   subtype CSR0_SMC_CSR0_DUAL_Field is NEORV32.Bit;
   subtype CSR0_SMC_CSR0_BUSY_Field is NEORV32.Bit;
   subtype CSR0_SMC_CSR0_MSIZE_Field is NEORV32.UInt2;
   subtype CSR0_SMC_CSR0_CDIV_Field is NEORV32.UInt3;
   subtype CSR0_SMC_CSR0_RWAIT_Field is NEORV32.UInt4;
   subtype CSR0_SMC_CSR0_RCMD_Field is NEORV32.Byte;
   subtype CSR0_SMC_CSR0_WCMD_Field is NEORV32.Byte;

   --  Control and status register 0
   type CSR0_Register is record
      --  SMC enable, reset module when 0
      SMC_CSR0_EN    : CSR0_SMC_CSR0_EN_Field := 16#0#;
      --  Enable control of SMC IO pins
      SMC_CSR0_IOEN  : CSR0_SMC_CSR0_IOEN_Field := 16#0#;
      --  unspecified
      Reserved_2_2   : NEORV32.Bit := 16#0#;
      --  Enable dual-chip mode
      SMC_CSR0_DUAL  : CSR0_SMC_CSR0_DUAL_Field := 16#0#;
      --  Read-only. Memory operation in progress when set
      SMC_CSR0_BUSY  : CSR0_SMC_CSR0_BUSY_Field := 16#0#;
      --  unspecified
      Reserved_5_6   : NEORV32.UInt2 := 16#0#;
      --  Memory size select
      SMC_CSR0_MSIZE : CSR0_SMC_CSR0_MSIZE_Field := 16#0#;
      --  SPI clock divider
      SMC_CSR0_CDIV  : CSR0_SMC_CSR0_CDIV_Field := 16#0#;
      --  Memory read access dummy/wait cycles
      SMC_CSR0_RWAIT : CSR0_SMC_CSR0_RWAIT_Field := 16#0#;
      --  Memory read command
      SMC_CSR0_RCMD  : CSR0_SMC_CSR0_RCMD_Field := 16#0#;
      --  Memory write command
      SMC_CSR0_WCMD  : CSR0_SMC_CSR0_WCMD_Field := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CSR0_Register use record
      SMC_CSR0_EN    at 0 range 0 .. 0;
      SMC_CSR0_IOEN  at 0 range 1 .. 1;
      Reserved_2_2   at 0 range 2 .. 2;
      SMC_CSR0_DUAL  at 0 range 3 .. 3;
      SMC_CSR0_BUSY  at 0 range 4 .. 4;
      Reserved_5_6   at 0 range 5 .. 6;
      SMC_CSR0_MSIZE at 0 range 7 .. 8;
      SMC_CSR0_CDIV  at 0 range 9 .. 11;
      SMC_CSR0_RWAIT at 0 range 12 .. 15;
      SMC_CSR0_RCMD  at 0 range 16 .. 23;
      SMC_CSR0_WCMD  at 0 range 24 .. 31;
   end record;

   --  CSR1_SMC_CSR1_ICMD array element
   subtype CSR1_SMC_CSR1_ICMD_Element is NEORV32.Byte;

   --  CSR1_SMC_CSR1_ICMD array
   type CSR1_SMC_CSR1_ICMD_Field_Array is array (0 .. 2)
     of CSR1_SMC_CSR1_ICMD_Element
     with Component_Size => 8, Size => 24;

   --  Type definition for CSR1_SMC_CSR1_ICMD
   type CSR1_SMC_CSR1_ICMD_Field
     (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            --  SMC_CSR1_ICMD as a value
            Val : NEORV32.UInt24;
         when True =>
            --  SMC_CSR1_ICMD as an array
            Arr : CSR1_SMC_CSR1_ICMD_Field_Array;
      end case;
   end record
     with Unchecked_Union, Size => 24;

   for CSR1_SMC_CSR1_ICMD_Field use record
      Val at 0 range 0 .. 23;
      Arr at 0 range 0 .. 23;
   end record;

   subtype CSR1_SMC_CSR1_MEM_BASE_Field is NEORV32.UInt4;

   --  Control and status register 0
   type CSR1_Register is record
      --  Initialization command 0
      SMC_CSR1_ICMD     : CSR1_SMC_CSR1_ICMD_Field :=
                           (As_Array => False, Val => 16#0#);
      --  unspecified
      Reserved_24_27    : NEORV32.UInt4 := 16#0#;
      --  Read-only. Memory base address (top 4 bits / 256MB page)
      SMC_CSR1_MEM_BASE : CSR1_SMC_CSR1_MEM_BASE_Field := 16#0#;
   end record
     with Volatile_Full_Access, Object_Size => 32,
          Bit_Order => System.Low_Order_First;

   for CSR1_Register use record
      SMC_CSR1_ICMD     at 0 range 0 .. 23;
      Reserved_24_27    at 0 range 24 .. 27;
      SMC_CSR1_MEM_BASE at 0 range 28 .. 31;
   end record;

   -----------------
   -- Peripherals --
   -----------------

   --  Serial Memory Controller
   type SMC_Peripheral is record
      --  Control and status register 0
      CSR0 : aliased CSR0_Register;
      --  Control and status register 0
      CSR1 : aliased CSR1_Register;
   end record
     with Volatile;

   for SMC_Peripheral use record
      CSR0 at 16#0# range 0 .. 31;
      CSR1 at 16#4# range 0 .. 31;
   end record;

   --  Serial Memory Controller
   SMC_Periph : aliased SMC_Peripheral
     with Import, Address => SMC_Base;

end NEORV32.SMC;
