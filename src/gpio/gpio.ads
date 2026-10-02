with Gpio_Interface;

with NEORV32_GPIO;

package Gpio is new Gpio_Interface
  (Pin_T            => NEORV32_GPIO.Pin,
   Driver_Configure => NEORV32_GPIO.Driver_Configure,
   Driver_Set       => NEORV32_GPIO.Driver_Set,
   Driver_Clr       => NEORV32_GPIO.Driver_Clr,
   Driver_Toggle    => NEORV32_GPIO.Driver_Toggle,
   Driver_Read      => NEORV32_GPIO.Driver_Read);
