# 
# ORCA_TOP
# Test mode constraints worst case
# Requires the file ORCA_TOP_port_lists.tcl to be sourced first
#

# Enable DFT logic and OCC Controller:

set_case_analysis 1 test_mode
set_case_analysis 0 occ_bypass
set_case_analysis 0 occ_reset

# PCI clock at 133 MHz (default)
create_clock -period 7.5 -name PCI_CLK [get_ports pclk]
create_clock -period 7.5 -name v_PCI_CLK

# SYSTEM clocks
create_clock -period 2.4 -name SYS_2x_CLK [get_ports sys_2x_clk]
create_generated_clock -add -master_clock SYS_2x_CLK -source [get_ports sys_2x_clk] -name SYS_CLK \
    -divide_by 2 [get_pins I_CLOCKING/sys_clk_in_reg/Q]

# SDRAM clock at 266 MHz (default)
create_clock -period 4.1 -name SDRAM_CLK [get_ports sdram_clk]
create_clock -period 4.1 -name v_SDRAM_CLK

create_generated_clock -add -master_clock SDRAM_CLK -source [get_ports sdram_clk] -name SD_DDR_CLK \
    -combinational [get_ports sd_CK]
create_generated_clock -add -master_clock SDRAM_CLK -source [get_ports sdram_clk] -name SD_DDR_CLKn \
    -combinational -invert [get_ports sd_CKn]

create_clock -period 30 [get_ports ate_clk]

set_clock_groups -asynchronous \
    -name func_async \
    -group [get_clocks SYS*] \
    -group [get_clocks *PCI*] \
    -group [get_clocks *SD*]


# Set a false path constraint from the ScanEnable port (top-level)
# to the PLL clocks:

set_false_path -from scan_enable -to [get_clocks "PCI* SD* SYS*"]

# Specify the asynchronous relationship between the PLL clocks (the PLL outputs)
# and the ATE clock: 

set_clock_groups \
      -name my_occ_clock_groups \
      -asynchronous \
      -group [get_clocks ate_clk] \
      -group [get_clocks "*PCI* *SD* SYS*"]

# Set false paths from all ScanInput pins to the PLL clocks:

set_false_path -from [get_ports test_si*] -to [get_clocks "PCI* SD* SYS*"]

# Set false paths from all PLL clocks to scan_in port "SD" of registers

set_false_path -from PCI_CLK \
  -to [get_pins -of_objects [all_registers] -filter "name == SI"]

set_false_path -from SDRAM_CLK \
  -to [get_pins -of_objects [all_registers] -filter "name == SI"]

set_false_path -from SYS_CLK \
  -to [get_pins -of_objects [all_registers] -filter "name == SI"]

set_false_path -from SYS_2x_CLK \
  -to [get_pins -of_objects [all_registers] -filter "name == SI"]

# Set multicycle paths with setup value of 3 and hold value of 2 from the
# clock chain bits. The specific setup value of 3 applies to the DFTC-inserted
# OCC controller. There are three delay elements (pipeline registers) to
# synchronize the clock controller to prevent metastability. For
# other OCC controllers, the path is multicycle, but the design should
# be inspected to determine the actual number to be used. 

set_multicycle_path -setup 3 -from snps_clk_chain_0/U_shftreg_0/ff_0/q_reg
set_multicycle_path -setup 3 -from snps_clk_chain_0/U_shftreg_0/ff_1/q_reg

set_multicycle_path -hold 2 -start -from snps_clk_chain_0/U_shftreg_0/ff_0/q_reg
set_multicycle_path -hold 2 -start -from snps_clk_chain_0/U_shftreg_0/ff_1/q_reg
