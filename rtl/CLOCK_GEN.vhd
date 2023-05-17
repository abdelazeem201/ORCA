----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY CLOCK_GEN IS
  
  PORT (
      pclk              : IN  std_logic;
      sdram_clk         : IN  std_logic;
      sys_clk           : IN  std_logic;
      sys_clk_fb        : IN  std_logic;

      pclk_fb           : IN  std_logic;
      sdram_clk_fb      : IN  std_logic;

      test_mode         : IN  std_logic;
      scan_enable       : IN  std_logic;
      pll_bypass        : IN  std_logic;
      powersave         : IN  std_logic;

      o_pclk            : OUT std_logic;
      o_sdram_clk       : OUT std_logic;
      o_sys_clk         : OUT std_logic;
      o_sys_2x_clk      : OUT std_logic
  );

END CLOCK_GEN;

ARCHITECTURE RTL OF CLOCK_GEN IS


  COMPONENT PLL
    PORT (
      REF_CLK  : IN  std_logic;
      FB_CLK   : IN  std_logic;
      CLK_1X   : OUT std_logic;
      CLK_2X   : OUT std_logic;
      CLK_4X   : OUT std_logic
    );
  END COMPONENT;
  
---  COMPONENT CLKMUL
---    PORT (
---      CLK_IN  : IN  std_logic;
---      CLK_1X  : OUT std_logic;
---   CLK_2X  : OUT std_logic
---    );
---  END COMPONENT;

  COMPONENT CLKMUX
    PORT (
      FAST_CLK  : IN std_logic;
      SLOW_CLK  : IN std_logic;
      SEL       : IN std_logic;
      TESTMODE  : IN std_logic;
      BYPASS    : IN std_logic;
      CLK       : OUT std_logic
    );
  END COMPONENT;

  COMPONENT MUX21X2
    PORT (
      A1, A2, S0 : IN  std_logic;
      Y         : OUT std_logic
    );
  END COMPONENT;

  SIGNAL net_pclk, dft_pclk           : std_logic;
  SIGNAL net_sdram_clk, dft_sdram_clk : std_logic;
  SIGNAL PLL_CLKSEL        : std_logic_vector(0 to 1);
  SIGNAL net_sys_clk       : std_logic;
  SIGNAL net_sys_2x_clk    : std_logic;
  SIGNAL net_ps_sys_2x_clk : std_logic;
  
  
BEGIN  -- RTL

  I_PLL_PCI : PLL PORT MAP (
    REF_CLK     => pclk,
    FB_CLK      => pclk_fb,
    CLK_1X      => net_pclk,
    CLK_2X      => open,
    CLK_4X      => open
  );

  I_PLL_SD : PLL PORT MAP (
    REF_CLK     => sdram_clk,
    FB_CLK      => sdram_clk_fb,
    CLK_1X      => net_sdram_clk,
    CLK_2X      => open,
    CLK_4X      => open
  );

  I_CLKMUL : PLL PORT MAP (
    REF_CLK     => sys_clk,
    FB_CLK      => sys_clk_fb,
    CLK_1X      => net_sys_clk,
    CLK_2x      => net_sys_2x_clk,
    CLK_4X     => open
  );
    
  process
   -- One-hot at-speed clock selection registers
   -- Controlled only during scan shifting
   -- During capture cycle or in functional mode, merely hold value
  begin
    wait until sys_clk = '1';
      if (pll_bypass = '1') then
        PLL_CLKSEL <= "00";
      end if;
  end process;

  -- In powersave mode, the 2x clock runs at the same speed as the sys_clk
  net_ps_sys_2x_clk <= net_sys_clk when powersave = '1' else net_sys_2x_clk;

  -- These clocks are always driven by ATE clocks during capture 
  o_sys_clk    <= sys_clk when test_mode = '1' else net_sys_clk;
  o_sys_2x_clk <= sys_clk when test_mode = '1' else net_ps_sys_2x_clk;
 
  -- These clocks can be driven by PLLs for at-speed launch/capture 
  o_pclk       <= net_pclk      when pll_bypass = '0' else dft_pclk;
  o_sdram_clk  <= net_sdram_clk when pll_bypass = '0' else dft_sdram_clk;

  I_PCI_CLKMUX : CLKMUX PORT MAP (
      SLOW_CLK  => pclk,
      FAST_CLK  => net_pclk,
      SEL       => PLL_CLKSEL(0),
      TESTMODE  => test_mode,
      BYPASS    => pll_bypass,
      CLK       => dft_pclk
    );

  I_SDR_CLKMUX : CLKMUX PORT MAP (
      SLOW_CLK  => sdram_clk,
      FAST_CLK  => net_sdram_clk,
      SEL       => PLL_CLKSEL(1),
      TESTMODE  => test_mode,
      BYPASS    => pll_bypass,
      CLK       => dft_sdram_clk
    );

END RTL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- Glitch free clock switch.
-- Assume all clocks are off before one is active.

ENTITY CLKMUX is
    PORT (
      FAST_CLK  : IN std_logic;
      SLOW_CLK  : IN std_logic;
      SEL       : IN std_logic;
      TESTMODE  : IN std_logic;
      BYPASS    : IN std_logic;
      CLK       : OUT std_logic
    );
END;

ARCHITECTURE RTL of CLKMUX is
  SIGNAL FAST_EN : STD_LOGIC;
  SIGNAL SLOW_EN : STD_LOGIC;
  SIGNAL GATE_CLK : STD_LOGIC;
BEGIN

  process begin
    wait until FAST_CLK = '0';
    FAST_EN <= SEL AND NOT(SLOW_EN);
  end process;
     
  process begin
    wait until SLOW_CLK = '0';
    SLOW_EN <= NOT(SEL) AND NOT(FAST_EN);
  end process;
  
  GATE_CLK <= (FAST_CLK AND FAST_EN) OR (SLOW_CLK AND SLOW_EN);
  
  CLK <= SLOW_CLK when (TESTMODE = '1' AND BYPASS = '1') ELSE GATE_CLK;
END RTL;
