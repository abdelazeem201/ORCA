----------------------------------------------------------------------/
----                                                               ----
----  The data contained in the file is created for educational    ---- 
----  and training purposes only and is  not recommended           ----
----  for fabrication                                              ----
----                                                               ----
----------------------------------------------------------------------/
----                                                               ----
----  Copyright (C) 2013 Synopsys, Inc.                            ----
----                                                               ----
----------------------------------------------------------------------/
----                                                               ----
----  The 32/28nm Generic Library ("Library") is unsupported       ----    
----  Confidential Information of Synopsys, Inc. ("Synopsys")      ----    
----  provided to you as Documentation under the terms of the      ----    
----  End User Software License Agreement between you or your      ----    
----  employer and Synopsys ("License Agreement") and you agree    ----    
----  not to distribute or disclose the Library without the        ----    
----  prior written consent of Synopsys. The Library IS NOT an     ----    
----  item of Licensed Software or Licensed Product under the      ----    
----  License Agreement.  Synopsys and/or its licensors own        ----    
----  and shall retain all right, title and interest in and        ----    
----  to the Library and all modifications thereto, including      ----    
----  all intellectual property rights embodied therein. All       ----    
----  rights in and to any Library modifications you make are      ----    
----  hereby assigned to Synopsys. If you do not agree with        ----    
----  this notice, including the disclaimer below, then you        ----    
----  are not authorized to use the Library.                       ----    
----                                                               ----  
----                                                               ----      
----  THIS LIBRARY IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN   ----
----  "AS IS" BASIS, WITH NO INTELLECUTAL PROPERTY                 ----
----  INDEMNIFICATION AND NO SUPPORT. ANY EXPRESS OR IMPLIED       ----
----  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED       ----
----  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR   ----
----  PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS    ----
----  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     ----
----  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      ----
----  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;     ----
----  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)     ----
----  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN    ----
----  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE    ----
----  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS      ----
----  DOCUMENTATION, EVEN IF ADVISED OF THE POSSIBILITY OF         ----
----  SUCH DAMAGE.                                                 ---- 		
----                                                               ----  
----------------------------------------------------------------------- 


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
