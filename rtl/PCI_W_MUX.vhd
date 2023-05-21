----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/

library IEEE;
use IEEE.std_logic_1164.all;

ENTITY PCI_W_MUX IS
  PORT (
    blender_data      : IN  std_logic_vector(31 DOWNTO 0);
    sdram_read_data   : IN  std_logic_vector(31 DOWNTO 0);
    risc_result_data  : IN  std_logic_vector(31 DOWNTO 0);
    pci_w_select      : IN  std_logic_vector(1 DOWNTO 0);
    pci_wfifo_data    : OUT std_logic_vector(31 DOWNTO 0)
  );

END PCI_W_MUX;

ARCHITECTURE RTL OF PCI_W_MUX IS
BEGIN

  WITH pci_w_select select
    pci_wfifo_data <= blender_data WHEN "01",
                      sdram_read_data WHEN "10",
                      risc_result_data WHEN OTHERS;

END RTL;
