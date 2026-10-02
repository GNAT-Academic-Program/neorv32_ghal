with Usart_Types;
with NEORV32_System;
with System.Storage_Elements; use System.Storage_Elements;

--  NEORV32_UART models one physical UART of the SoC (UART0 or UART1).
--  The instantiation IS the bus. There is no Device type.
--
--  What the NEORV32 UART can do:
--    * Frame is fixed by the hardware: 8 data bits, no parity, 1 stop bit.
--      Any other request raises Usart_Types.USART_Unsupported.
--    * RTS/CTS flow control is supported.
--    * A baud rate the clock cannot produce within 2 % raises
--      Usart_Types.USART_Unsupported instead of sending garbage.
--    * There is no clock gate and no reset line: Reset clears the control
--      register, which disables the UART and empties its FIFOs.

generic
   Port : NEORV32_System.UART_Peripheral;
   with function Get_Clock return Natural is NEORV32_System.Clock_Hz;
package NEORV32_UART is

   --  Control-plane hooks

   procedure Init       (Cfg : Usart_Types.Usart_Config);
   procedure Enable;
   function  Is_Enabled return Boolean;
   procedure Disable;
   procedure Reset;

   --  Data-plane hooks

   procedure Tx_Push (B        : Storage_Element;
                      Accepted : out Boolean);
   procedure Rx_Pop  (B         : out Storage_Element;
                      Available : out Boolean);

end NEORV32_UART;
