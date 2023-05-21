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
use IEEE.std_logic_unsigned.all;

ENTITY CONTEXT_MEM IS
  PORT (
    sys_clk          : IN  std_logic;
    sys_rst_n        : IN  std_logic;
    
    context_en       : IN  std_logic;
    cmd              : IN  std_logic_vector(7 DOWNTO 0);

    pci_data_in      : IN  std_logic_vector(31 DOWNTO 0);
    pci_context_data : OUT std_logic_vector(31 DOWNTO 0)

  );
END CONTEXT_MEM;

ARCHITECTURE RAMS_16 OF CONTEXT_MEM IS

  COMPONENT ram8x64
    PORT (A1   : IN  std_logic_vector(5 downto 0);
          A2   : IN  std_logic_vector(5 downto 0);
          CE1  : IN  std_logic;
          CE2  : IN  std_logic;
          WEB1 : IN  std_logic;
          WEB2 : IN  std_logic;
          OEB1 : IN  std_logic;
          OEB2 : IN  std_logic;
          CSB1 : IN  std_logic;
          CSB2 : IN  std_logic;
          I1   : IN  std_logic_vector(7 downto 0);
          O1   : OUT std_logic_vector(7 downto 0);
          I2   : IN  std_logic_vector(7 downto 0);
          O2   : OUT std_logic_vector(7 downto 0)
         );
  END COMPONENT;

  SIGNAL ti_hi, ti_low  : std_logic;

  SIGNAL pci_data_in_buf : std_logic_vector(31 DOWNTO 0);
  TYPE   cdata IS ARRAY (0 TO 3) OF std_logic_vector(31 DOWNTO 0);
  SIGNAL context_data : cdata;
  SIGNAL ram_write_addr : std_logic_vector(5 DOWNTO 0);
  SIGNAL ram_read_addr  : std_logic_vector(5 DOWNTO 0);
  SIGNAL read_op        : std_logic_vector(2 DOWNTO 0);
  SIGNAL write_op       : std_logic_vector(3 DOWNTO 0);
  SIGNAL ram_write_cs   : std_logic_vector(3 DOWNTO 0);
  SIGNAL we_n           : std_logic;

  SIGNAL bus_hi         : std_logic_vector(7 DOWNTO 0);

BEGIN

  ti_hi <= '1';
  ti_low <= '0';
  bus_hi <= (OTHERS => '1');
  
  read_op <= cmd(2 DOWNTO 0);
  write_op <= cmd(6 DOWNTO 3);
  we_n <= cmd(7);
  pci_data_in_buf <= pci_data_in;
  
  read_addr_gen : PROCESS ( sys_rst_n, sys_clk, context_en, read_op, ram_read_addr )
  BEGIN
    IF sys_rst_n='0' THEN
      ram_read_addr <= "000000";
    ELSIF sys_clk'event AND sys_clk='1' THEN
      IF context_en='1' AND read_op(2)='1' THEN
        ram_read_addr <= ram_read_addr + 1;
      ELSIF context_en='1' AND read_op(2)='0' THEN
        ram_read_addr <= ram_read_addr + 1;
      ELSE
        ram_read_addr <= ram_read_addr;
      END IF;
    END IF;
  END PROCESS;

  ram_chip_sel_decode: PROCESS ( write_op )
  BEGIN
    CASE write_op(1 DOWNTO 0) IS
      WHEN "00"   => ram_write_cs <= "1000";
      WHEN "01"   => ram_write_cs <= "0100";
      WHEN "10"   => ram_write_cs <= "0010";
      WHEN OTHERS => ram_write_cs <= "0001";
    END CASE;
  END PROCESS;

  write_addr_gen : PROCESS ( sys_rst_n, sys_clk, context_en, write_op, ram_write_addr )
  BEGIN
    IF sys_rst_n='0' THEN 
      ram_write_addr <= "000000";
    ELSIF sys_clk'event AND sys_clk='1' THEN
      IF write_op(3)='0' THEN
        ram_write_addr <= "000000";
      ELSIF context_en='1' AND write_op(2)='1' THEN
        ram_write_addr <= ram_write_addr + 1;
      ELSIF context_en='1' AND write_op(2)='0' THEN
        ram_write_addr <= ram_write_addr + 1;
      ELSE
        ram_write_addr <= ram_write_addr;
      END IF;
    END IF;
  END PROCESS;

  -- This is not needed if the bus works in tristate mode!!
  pci_context_selector : PROCESS(pci_data_in, context_en, read_op,
                                 context_data
                                 )
    
    VARIABLE sel : std_logic_vector(2 DOWNTO 0);
    
  BEGIN

    sel := context_en & read_op(1 DOWNTO 0);
    CASE sel IS
        WHEN "100" =>
          pci_context_data <= context_data(0);
        WHEN "101" =>
          pci_context_data <= context_data(1);
        WHEN "110" =>
          pci_context_data <= context_data(2);
        WHEN "111" =>
          pci_context_data <= context_data(3);
        WHEN OTHERS =>                  -- includes "0xx"
          pci_context_data <= pci_data_in;
    END CASE;
  END PROCESS;


  CONTEXT: FOR n IN 0 to 3 GENERATE
    CONTEXT_RAMS: FOR i IN 1 to 4 GENERATE
      I_CONTEXT_RAM : ram8x64
        PORT MAP (
          A1   => ram_write_addr,
          CE1  => sys_clk,
          WEB1 => we_n,
          OEB1 => ti_hi,
          CSB1 => ram_write_cs(n),
          I1   => pci_data_in_buf(i*8-1 DOWNTO (i-1)*8),
          O1   => open,
          
          A2   => ram_read_addr,
          CE2  => sys_clk,
          WEB2 => ti_hi,
          OEB2 => ti_low,
          CSB2 => ti_low,
          I2   => bus_hi,
          O2   => context_data(n)(i*8-1 DOWNTO (i-1)*8)
          );
    END GENERATE CONTEXT_RAMS;
  END GENERATE CONTEXT;

END RAMS_16;


ARCHITECTURE RAMS_8 OF CONTEXT_MEM IS

  COMPONENT ram8x64
    PORT (A1   : IN  std_logic_vector(5 downto 0);
          A2   : IN  std_logic_vector(5 downto 0);
          CE1  : IN  std_logic;
          CE2  : IN  std_logic;
          WEB1 : IN  std_logic;
          WEB2 : IN  std_logic;
          OEB1 : IN  std_logic;
          OEB2 : IN  std_logic;
          CSB1 : IN  std_logic;
          CSB2 : IN  std_logic;
          I1   : IN  std_logic_vector(7 downto 0);
          O1   : OUT std_logic_vector(7 downto 0);
          I2   : IN  std_logic_vector(7 downto 0);
          O2   : OUT std_logic_vector(7 downto 0)
         );
  END COMPONENT;

  SIGNAL ti_hi, ti_low  : std_logic;

  SIGNAL pci_data_in_buf : std_logic_vector(31 DOWNTO 0);
  TYPE   cdata IS ARRAY (0 TO 1) OF std_logic_vector(31 DOWNTO 0);
  SIGNAL context_data : cdata;
  SIGNAL ram_write_addr : std_logic_vector(5 DOWNTO 0);
  SIGNAL ram_read_addr  : std_logic_vector(5 DOWNTO 0);
  SIGNAL read_op        : std_logic_vector(2 DOWNTO 0);
  SIGNAL write_op       : std_logic_vector(3 DOWNTO 0);
  SIGNAL ram_write_cs   : std_logic_vector(3 DOWNTO 0);
  SIGNAL we_n           : std_logic;

  SIGNAL bus_hi         : std_logic_vector(7 DOWNTO 0);

BEGIN

  ti_hi <= '1';
  ti_low <= '0';
  bus_hi <= (OTHERS => '1');
  
  read_op <= cmd(2 DOWNTO 0);
  write_op <= cmd(6 DOWNTO 3);
  we_n <= cmd(7);
  pci_data_in_buf <= pci_data_in;
  
  read_addr_gen : PROCESS ( sys_rst_n, sys_clk, context_en, read_op, ram_read_addr )
  BEGIN
    IF sys_rst_n='0' THEN
      ram_read_addr <= "000000";
    ELSIF sys_clk'event AND sys_clk='1' THEN
      IF context_en='1' AND read_op(2)='1' THEN
        ram_read_addr <= ram_read_addr + 1;
      ELSIF context_en='1' AND read_op(2)='0' THEN
        ram_read_addr <= ram_read_addr + 1;
      ELSE
        ram_read_addr <= ram_read_addr;
      END IF;
    END IF;
  END PROCESS;

  ram_chip_sel_decode: PROCESS ( write_op )
  BEGIN
    CASE write_op(1 DOWNTO 0) IS
--      WHEN "00"   => ram_write_cs <= "1000";
--      WHEN "01"   => ram_write_cs <= "0100";
      WHEN "10"   => ram_write_cs <= "0010";
      WHEN OTHERS => ram_write_cs <= "0001";
    END CASE;
  END PROCESS;

  write_addr_gen : PROCESS ( sys_rst_n, sys_clk, context_en, write_op, ram_write_addr )
  BEGIN
    IF sys_rst_n='0' THEN 
      ram_write_addr <= "000000";
    ELSIF sys_clk'event AND sys_clk='1' THEN
      IF write_op(3)='0' THEN
        ram_write_addr <= "000000";
      ELSIF context_en='1' AND write_op(2)='1' THEN
        ram_write_addr <= ram_write_addr + 1;
      ELSIF context_en='1' AND write_op(2)='0' THEN
        ram_write_addr <= ram_write_addr + 1;
      ELSE
        ram_write_addr <= ram_write_addr;
      END IF;
    END IF;
  END PROCESS;

  -- This is not needed if the bus works in tristate mode!!
  pci_context_selector : PROCESS(pci_data_in, context_en, read_op,
                                 context_data
                                 )
    
    VARIABLE sel : std_logic_vector(2 DOWNTO 0);
    
  BEGIN

    sel := context_en & read_op(1 DOWNTO 0);
    CASE sel IS
        WHEN "100" =>
          pci_context_data <= context_data(0);
        WHEN "101" =>
          pci_context_data <= context_data(1);
--         WHEN "110" =>
--           pci_context_data <= context_data(2);
--         WHEN "111" =>
--           pci_context_data <= context_data(3);
        WHEN OTHERS =>                  -- includes "0xx"
          pci_context_data <= pci_data_in;
    END CASE;
  END PROCESS;


  CONTEXT: FOR n IN 0 to 1 GENERATE
    CONTEXT_RAMS: FOR i IN 1 to 4 GENERATE
      I_CONTEXT_RAM : ram8x64
        PORT MAP (
          A1   => ram_write_addr,
          CE1  => sys_clk,
          WEB1 => we_n,
          OEB1 => ti_hi,
          CSB1 => ram_write_cs(n),
          I1   => pci_data_in_buf(i*8-1 DOWNTO (i-1)*8),
          O1   => open,
          
          A2   => ram_read_addr,
          CE2  => sys_clk,
          WEB2 => ti_hi,
          OEB2 => ti_low,
          CSB2 => ti_low,
          I2   => bus_hi,
          O2   => context_data(n)(i*8-1 DOWNTO (i-1)*8)
          );
    END GENERATE CONTEXT_RAMS;
  END GENERATE CONTEXT;

END RAMS_8;

ARCHITECTURE NO_RAMS OF CONTEXT_MEM IS

BEGIN

  pci_context_data <= pci_data_in;
  
END NO_RAMS;