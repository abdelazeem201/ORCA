----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY RESET_BLOCK IS
  
  PORT (
    pclk         : IN  std_logic;
    sys_clk      : IN  std_logic;
    sys_2x_clk   : IN  std_logic;
    sdram_clk    : IN  std_logic;

    prst_n       : IN  std_logic;

    test_mode    : IN  std_logic;

    pci_rst_n    : OUT std_logic;
    sdram_rst_n  : OUT std_logic;
    sys_rst_n    : OUT std_logic;
    sys_2x_rst_n : OUT std_logic
  );
END RESET_BLOCK;

ARCHITECTURE RTL OF RESET_BLOCK IS
  SIGNAL prst_ff           : std_logic;
  SIGNAL sdram_rst_ff      : std_logic;
  SIGNAL sys_rst_ff        : std_logic;
  SIGNAL sys_2x_rst_ff     : std_logic;

  SIGNAL pci_rst_n_buf     : std_logic;
  SIGNAL sys_rst_n_buf     : std_logic;
  SIGNAL sys_2x_rst_n_buf  : std_logic;
  SIGNAL sdram_rst_n_buf   : std_logic;

BEGIN  -- RTL

  -- Reset the PCI and SDRAM domains:

  PCI_RESET : PROCESS (prst_n, pclk, prst_ff)
  BEGIN
    IF prst_n = '0' THEN
      prst_ff <= '0';
      pci_rst_n_buf <= '0';
    ELSIF pclk'event AND pclk='1' THEN 
      prst_ff <= '1';
      pci_rst_n_buf <= prst_ff;
    END IF;
  END PROCESS;
  
  pci_rst_n <= pci_rst_n_buf WHEN test_mode='0'
          ELSE prst_n;

  SDRAM_RESET : PROCESS (prst_n, sdram_clk, sdram_rst_ff)
  BEGIN
    IF prst_n = '0' THEN
      sdram_rst_ff <= '0';
      sdram_rst_n_buf <= '0';
    ELSIF sdram_clk'event AND sdram_clk='1' THEN 
      sdram_rst_ff <= '1';
      sdram_rst_n_buf <= sdram_rst_ff;
    END IF;
  END PROCESS;

  sdram_rst_n <= sdram_rst_n_buf WHEN test_mode='0'
            ELSE prst_n;


  -- Reset the system clock domains.
  SYS_CLK_RESET : PROCESS (prst_n, sys_clk, sys_rst_ff)
  BEGIN
    IF prst_n = '0' THEN
      sys_rst_ff <= '0';
      sys_rst_n_buf <= '0';
    ELSIF sys_clk'event AND sys_clk='1' THEN 
      sys_rst_ff <= '1';
      sys_rst_n_buf <= sys_rst_ff;
    END IF;
  END PROCESS;

  sys_rst_n <= sys_rst_n_buf WHEN test_mode='0'
          ELSE prst_n;

  SYS_2X_CLK_RESET : PROCESS (prst_n, sys_2x_clk, sys_2x_rst_ff)
  BEGIN
    IF prst_n = '0' THEN
      sys_2x_rst_ff <= '0';
      sys_2x_rst_n_buf <= '0';
    ELSIF sys_2x_clk'event AND sys_2x_clk='1' THEN 
      sys_2x_rst_ff <= '1';
      sys_2x_rst_n_buf <= sys_2x_rst_ff;
    END IF;
  END PROCESS;

  sys_2x_rst_n <= sys_2x_rst_n_buf WHEN test_mode='0'
             ELSE prst_n;
  

END RTL;
