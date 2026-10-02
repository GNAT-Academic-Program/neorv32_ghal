with System;
with NEORV32.GPIO;
with NEORV32_System;

package body NEORV32_GPIO is

   use NEORV32;
   use NEORV32.GPIO;
   use type Gpio_Types.Pin_Mode;
   use type Gpio_Types.Pull_Resistor;
   use type Gpio_Types.Drive_Type;
   use type Gpio_Types.Logic_Level;

   --  The port has no set/clear registers: changing one pin means reading
   --  the whole register, changing one bit and writing it back. Done in
   --  three instructions, an interrupt or another task landing in the
   --  middle loses its own change to a different pin.
   --
   --  The three operations below do read-modify-write in ONE instruction
   --  (amoor.w / amoand.w / amoxor.w, RISC-V Zaamo extension), which
   --  cannot be interrupted.

   Seq_Cst : constant := 5;

   function Atomic_Or
     (Ptr : System.Address; Val : UInt32; Model : Integer := Seq_Cst)
      return UInt32
     with Import, Convention => Intrinsic,
          External_Name => "__atomic_fetch_or_4";

   function Atomic_And
     (Ptr : System.Address; Val : UInt32; Model : Integer := Seq_Cst)
      return UInt32
     with Import, Convention => Intrinsic,
          External_Name => "__atomic_fetch_and_4";

   function Atomic_Xor
     (Ptr : System.Address; Val : UInt32; Model : Integer := Seq_Cst)
      return UInt32
     with Import, Convention => Intrinsic,
          External_Name => "__atomic_fetch_xor_4";

   function Mask (Dev : Pin) return UInt32 is
     (Shift_Left (UInt32'(1), Dev.Nbr));

   procedure Set_Bits (Reg : System.Address; Bits : UInt32) is
      Unused : UInt32;
   begin
      Unused := Atomic_Or (Reg, Bits);
   end Set_Bits;

   procedure Clear_Bits (Reg : System.Address; Bits : UInt32) is
      Unused : UInt32;
   begin
      Unused := Atomic_And (Reg, not Bits);
   end Clear_Bits;

   procedure Toggle_Bits (Reg : System.Address; Bits : UInt32) is
      Unused : UInt32;
   begin
      Unused := Atomic_Xor (Reg, Bits);
   end Toggle_Bits;

   --------------
   -- Make_Pin --
   --------------

   function Make_Pin (Nbr : Pin_Number) return Pin is
   begin
      return (Nbr => Nbr);
   end Make_Pin;

   ----------------------
   -- Driver_Configure --
   ----------------------

   procedure Driver_Configure
     (Dev : Pin;
      Cfg : Gpio_Types.Gpio_Config) is
   begin
      if not NEORV32_System.Is_Implemented (NEORV32_System.GPIO) then
         raise Gpio_Types.GPIO_Error
           with "GPIO is not implemented in this bitstream";
      end if;

      if Cfg.Mode in Gpio_Types.Alternate | Gpio_Types.Analog then
         raise Gpio_Types.GPIO_Unsupported
           with "NEORV32 GPIO has no alternate or analog mode";
      end if;

      if Cfg.Pull /= Gpio_Types.None then
         raise Gpio_Types.GPIO_Unsupported
           with "NEORV32 GPIO has no pull resistors, set them in the FPGA constraints";
      end if;

      case Cfg.Mode is
         when Gpio_Types.Output =>
            if Cfg.Drive /= Gpio_Types.Push_Pull then
               raise Gpio_Types.GPIO_Unsupported
                 with "NEORV32 GPIO outputs are push-pull only";
            end if;

            --  Level first, direction second: the pin never drives a
            --  level the caller did not ask for. Speed has no meaning
            --  here and is ignored.
            if Cfg.Init_State = Gpio_Types.High then
               Set_Bits (GPIO_Periph.PORT_OUT'Address, Mask (Dev));
            else
               Clear_Bits (GPIO_Periph.PORT_OUT'Address, Mask (Dev));
            end if;

            --  PORT_DIR only exists when the gateware enables direction
            --  control (IO_GPIO_DIR_EN). Without it the write is ignored
            --  and output N is always driven.
            Set_Bits (GPIO_Periph.PORT_DIR'Address, Mask (Dev));

         when Gpio_Types.Input =>
            Clear_Bits (GPIO_Periph.PORT_DIR'Address, Mask (Dev));

         when Gpio_Types.Alternate | Gpio_Types.Analog =>
            null;  --  rejected above
      end case;
   end Driver_Configure;

   ----------------
   -- Driver_Set --
   ----------------

   procedure Driver_Set (Dev : Pin) is
   begin
      Set_Bits (GPIO_Periph.PORT_OUT'Address, Mask (Dev));
   end Driver_Set;

   ----------------
   -- Driver_Clr --
   ----------------

   procedure Driver_Clr (Dev : Pin) is
   begin
      Clear_Bits (GPIO_Periph.PORT_OUT'Address, Mask (Dev));
   end Driver_Clr;

   -------------------
   -- Driver_Toggle --
   -------------------

   procedure Driver_Toggle (Dev : Pin) is
   begin
      Toggle_Bits (GPIO_Periph.PORT_OUT'Address, Mask (Dev));
   end Driver_Toggle;

   -----------------
   -- Driver_Read --
   -----------------

   function Driver_Read (Dev : Pin) return MT.Bit is
   begin
      return (if (GPIO_Periph.PORT_IN and Mask (Dev)) /= 0 then 1 else 0);
   end Driver_Read;

end NEORV32_GPIO;
