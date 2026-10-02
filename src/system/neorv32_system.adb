with System.Machine_Code;
with NEORV32.SYSINFO;

package body NEORV32_System is

   use NEORV32;
   use NEORV32.SYSINFO;

   function Hardware_Version return Interfaces.Unsigned_32 is
      use ASCII;
      Value : Interfaces.Unsigned_32;
   begin
      --  The CSR instructions belong to the Zicsr extension. The option
      --  lines enable it for this one instruction, so this compiles
      --  whatever -march string the runtime was built with.
      System.Machine_Code.Asm
        (".option push"          & LF & HT &
         ".option arch, +zicsr"  & LF & HT &
         "csrr %0, mimpid"       & LF & HT &
         ".option pop",
         Outputs  => Interfaces.Unsigned_32'Asm_Output ("=r", Value),
         Volatile => True);
      return Value;
   end Hardware_Version;

   function Version_Matches return Boolean is
      use type Interfaces.Unsigned_32;
   begin
      return Hardware_Version = Expected_Version;
   end Version_Matches;

   function Clock_Hz return Natural is
   begin
      return Natural (SYSINFO_Periph.CLK);
   end Clock_Hz;

   --  SYSINFO stores both memory sizes as log2 (size in bytes).

   function IMEM_Size return Natural is
   begin
      return 2 ** Natural (SYSINFO_Periph.MISC.SYSINFO_MISC_IMEM);
   end IMEM_Size;

   function DMEM_Size return Natural is
   begin
      return 2 ** Natural (SYSINFO_Periph.MISC.SYSINFO_MISC_DMEM);
   end DMEM_Size;

   function Is_Implemented (P : Peripheral) return Boolean is
      SoC  : constant SOC_Register := SYSINFO_Periph.SOC;
      Flag : Bit;
   begin
      case P is
         when GPIO    => Flag := SoC.SYSINFO_SOC_IO_GPIO;
         when CLINT   => Flag := SoC.SYSINFO_SOC_IO_CLINT;
         when UART0   => Flag := SoC.SYSINFO_SOC_IO_UART0;
         when UART1   => Flag := SoC.SYSINFO_SOC_IO_UART1;
         when SPI     => Flag := SoC.SYSINFO_SOC_IO_SPI;
         when SDI     => Flag := SoC.SYSINFO_SOC_IO_SDI;
         when TWI     => Flag := SoC.SYSINFO_SOC_IO_TWI;
         when TWD     => Flag := SoC.SYSINFO_SOC_IO_TWD;
         when PWM     => Flag := SoC.SYSINFO_SOC_IO_PWM;
         when WDT     => Flag := SoC.SYSINFO_SOC_IO_WDT;
         when TRNG    => Flag := SoC.SYSINFO_SOC_IO_TRNG;
         when CFS     => Flag := SoC.SYSINFO_SOC_IO_CFS;
         when NEOLED  => Flag := SoC.SYSINFO_SOC_IO_NEOLED;
         when GPTMR   => Flag := SoC.SYSINFO_SOC_IO_GPTMR;
         when ONEWIRE => Flag := SoC.SYSINFO_SOC_IO_ONEWIRE;
         when DMA     => Flag := SoC.SYSINFO_SOC_IO_DMA;
         when SLINK   => Flag := SoC.SYSINFO_SOC_IO_SLINK;
         when TRACER  => Flag := SoC.SYSINFO_SOC_IO_TRACER;
      end case;
      return Flag = 1;
   end Is_Implemented;

end NEORV32_System;
