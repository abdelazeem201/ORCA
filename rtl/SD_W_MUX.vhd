-----------------------------------------------------------------------
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ---- 
----                                                               ----  
----                                                               ----      		
----                                                               ----  
----------------------------------------------------------------------- 


library IEEE;
use IEEE.std_logic_1164.all;

ENTITY SD_W_MUX IS
  PORT (
    blender_data      : IN  std_logic_vector(31 DOWNTO 0);
    pci_read_data     : IN  std_logic_vector(31 DOWNTO 0);
    risc_result_data  : IN  std_logic_vector(31 DOWNTO 0);
    sd_w_select       : IN  std_logic_vector(1 DOWNTO 0);
    sd_wfifo_data     : OUT std_logic_vector(31 DOWNTO 0)
  );

END SD_W_MUX;

ARCHITECTURE RTL OF SD_W_MUX IS
BEGIN

  WITH sd_w_select select
    sd_wfifo_data <= blender_data WHEN "01",
                     risc_result_data WHEN "10",
                     pci_read_data WHEN OTHERS;

END RTL;
