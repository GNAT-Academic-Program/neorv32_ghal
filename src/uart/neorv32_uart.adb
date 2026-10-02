with NEORV32;
with NEORV32.UART0;

package body NEORV32_UART is

   use NEORV32;
   use NEORV32.UART0;
   use type NEORV32_System.Peripheral;
   use type Usart_Types.Data_Bits_Kind;
   use type Usart_Types.Parity_Kind;
   use type Usart_Types.Stop_Bits_Kind;
   use type Usart_Types.Flow_Control_Kind;

   --  UART0 and UART1 have the same register layout. svd2ada generates one
   --  type per peripheral, so the UART0 type is laid over whichever port
   --  this instance drives.
   Periph : UART0_Peripheral
     with Import,
          Address => (if Port = NEORV32_System.UART0
                      then UART0_Base
                      else UART1_Base);

   Initialized : Boolean := False;

   TX_Wait_Timeout : constant Natural := 1_000_000;

   --  Clock dividers the UART can select with CTRL.PRSC (0 .. 7).
   Prescalers : constant array (UInt3) of Positive :=
     (2, 4, 8, 64, 128, 1024, 2048, 4096);

   --  CTRL.BAUD is 10 bits wide and holds (divisor - 1).
   Max_Divisor : constant := 1024;

   --  Largest accepted gap between requested and produced baud rate, as a
   --  fraction: 1 / 50 = 2 %.
   Max_Error_Fraction : constant := 50;

   function Baud_To_Int (B : Usart_Types.Baud_Rate) return Positive is
   begin
      case B is
         when Usart_Types.B1200   => return 1_200;
         when Usart_Types.B2400   => return 2_400;
         when Usart_Types.B4800   => return 4_800;
         when Usart_Types.B9600   => return 9_600;
         when Usart_Types.B19200  => return 19_200;
         when Usart_Types.B38400  => return 38_400;
         when Usart_Types.B57600  => return 57_600;
         when Usart_Types.B115200 => return 115_200;
         when Usart_Types.B230400 => return 230_400;
         when Usart_Types.B460800 => return 460_800;
         when Usart_Types.B921600 => return 921_600;
         when Usart_Types.B1M     => return 1_000_000;
         when Usart_Types.B2M     => return 2_000_000;
      end case;
   end Baud_To_Int;

   --  Baud rate = Clock / (Prescaler * Divisor).
   --  Picks the smallest prescaler whose divisor fits in CTRL.BAUD, which
   --  gives the finest resolution. Found is False when no pair reaches
   --  the requested rate within Max_Error_Fraction.
   procedure Compute_Divider
     (Clock   : Natural;
      Baud    : Positive;
      Prsc    : out UInt3;
      Divisor : out Positive;
      Found   : out Boolean)
   is
      Tick   : Natural;   --  Clock / Prescaler
      Div    : Natural;
      Actual : Natural;
   begin
      Prsc    := 0;
      Divisor := 1;
      Found   := False;

      for P in Prescalers'Range loop
         Tick := Clock / Prescalers (P);
         Div  := (Tick + Baud / 2) / Baud;   --  rounded to nearest

         if Div in 1 .. Max_Divisor then
            Actual  := Tick / Div;
            Prsc    := P;
            Divisor := Div;
            Found   := abs (Actual - Baud) * Max_Error_Fraction <= Baud;
            return;
         end if;

         exit when Div = 0;   --  larger prescalers only make it worse
      end loop;
   end Compute_Divider;

   procedure Check_Implemented is
   begin
      if not NEORV32_System.Is_Implemented (Port) then
         raise Usart_Types.USART_Error
           with "this UART is not implemented in this bitstream";
      end if;
   end Check_Implemented;

   ----------------
   -- Is_Enabled --
   ----------------

   function Is_Enabled return Boolean is
   begin
      return Initialized and then Periph.CTRL.UART_CTRL_EN = 1;
   end Is_Enabled;

   ----------
   -- Init --
   ----------

   procedure Init (Cfg : Usart_Types.Usart_Config) is
      Prsc    : UInt3;
      Divisor : Positive;
      Found   : Boolean;
   begin
      Check_Implemented;

      if Cfg.Data_Bits /= Usart_Types.Data_8
        or else Cfg.Parity /= Usart_Types.None
        or else Cfg.Stop_Bits /= Usart_Types.Stop_1
      then
         raise Usart_Types.USART_Unsupported
           with "NEORV32 UART frame is 8 data bits, no parity, 1 stop bit";
      end if;

      Compute_Divider
        (Clock   => Get_Clock,
         Baud    => Baud_To_Int (Cfg.Baud),
         Prsc    => Prsc,
         Divisor => Divisor,
         Found   => Found);

      if not Found then
         raise Usart_Types.USART_Unsupported
           with "baud rate cannot be produced from the SoC clock";
      end if;

      --  One write of the whole register. The UART stays disabled
      --  (UART_CTRL_EN = 0) until Enable.
      Periph.CTRL :=
        (UART_CTRL_PRSC    => Prsc,
         UART_CTRL_BAUD    => UInt10 (Divisor - 1),
         UART_CTRL_HWFC_EN =>
           (if Cfg.Flow = Usart_Types.RTS_CTS then 1 else 0),
         others            => <>);

      Initialized := True;
   end Init;

   ------------
   -- Enable --
   ------------

   procedure Enable is
   begin
      if not Initialized then
         raise Usart_Types.USART_Error with "Enable: peripheral not initialized";
      end if;

      Periph.CTRL.UART_CTRL_EN := 1;
   end Enable;

   -------------
   -- Disable --
   -------------

   procedure Disable is
   begin
      if Initialized then
         Periph.CTRL.UART_CTRL_EN := 0;
      end if;
   end Disable;

   -----------
   -- Reset --
   -----------

   procedure Reset is
   begin
      Check_Implemented;
      Periph.CTRL := (others => <>);
      Initialized := False;
   end Reset;

   -------------
   -- Tx_Push --
   -------------

   procedure Tx_Push
     (B        : Storage_Element;
      Accepted : out Boolean)
   is
      Wait_Count : Natural := 0;
   begin
      if not Is_Enabled then
         Accepted := False;
         return;
      end if;

      while Periph.CTRL.UART_CTRL_TX_NFULL = 0 loop
         Wait_Count := Wait_Count + 1;
         if Wait_Count >= TX_Wait_Timeout then
            Accepted := False;
            return;
         end if;
      end loop;

      --  The whole register is written in one store. Do NOT turn this into
      --  "Periph.DATA.UART_DATA_RTX := ...": a field assignment reads the
      --  register first, and reading DATA removes a byte from the RX FIFO.
      Periph.DATA := (UART_DATA_RTX => Byte (B), others => <>);
      Accepted := True;
   end Tx_Push;

   ------------
   -- Rx_Pop --
   ------------

   procedure Rx_Pop
     (B         : out Storage_Element;
      Available : out Boolean)
   is
   begin
      B := 0;

      if not Is_Enabled then
         Available := False;
         return;
      end if;

      if Periph.CTRL.UART_CTRL_RX_NEMPTY = 1 then
         --  Reading DATA removes the byte from the RX FIFO.
         B         := Storage_Element (Periph.DATA.UART_DATA_RTX);
         Available := True;
      else
         Available := False;
      end if;
   end Rx_Pop;

end NEORV32_UART;
