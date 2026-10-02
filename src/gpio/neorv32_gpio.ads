with Gpio_Types;
with MT;

--  NEORV32 GPIO port: up to 32 pins, numbered 0 .. 31.
--
--  What "pin N" means on NEORV32:
--    * Output N and input N are two separate wires of the SoC
--      (gpio_o (N) and gpio_i (N)). Set, Clr and Toggle drive output N.
--      Read samples input N. They are the same physical pin only when the
--      gateware joins them.
--    * How many pins exist, and where they go, is decided by the gateware.
--    * There are no pull resistors, no open drain and no alternate
--      functions in the peripheral. Asking for one raises
--      Gpio_Types.GPIO_Unsupported.

package NEORV32_GPIO is

   type Pin is private;

   subtype Pin_Number is Natural range 0 .. 31;

   function Make_Pin (Nbr : Pin_Number) return Pin;

   procedure Driver_Configure
     (Dev : Pin;
      Cfg : Gpio_Types.Gpio_Config);

   procedure Driver_Set (Dev : Pin);

   procedure Driver_Clr (Dev : Pin);

   procedure Driver_Toggle (Dev : Pin);

   function Driver_Read (Dev : Pin) return MT.Bit;

private

   type Pin is record
      Nbr : Pin_Number;
   end record;

end NEORV32_GPIO;
