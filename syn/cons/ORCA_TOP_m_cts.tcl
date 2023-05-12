# 
# ORCA_TOP
# Functional mode constraints
# Requires the file ORCA_TOP_port_lists.tcl to be sourced first
#

set_case_analysis 0 test_mode
set_case_analysis 0 scan_enable

# PCI clock at 133 MHz (default)
create_clock -period 7.5 -name PCI_CLK [get_ports pclk]
create_clock -period 7.5 -name v_PCI_CLK

# SYSTEM clocks
#create_clock -period 2.3 -name SYS_2x_CLK [get_ports sys_2x_clk]
create_clock -period 1.0 -name SYS_2x_CLK [get_ports sys_2x_clk]
create_generated_clock -add -master_clock SYS_2x_CLK -source [get_ports sys_2x_clk] -name SYS_CLK \
    -divide_by 2 [get_pins I_CLOCKING/sys_clk_in_reg/Q]

# SDRAM clock
create_clock -period 4.1 -name SDRAM_CLK [get_ports sdram_clk]
create_clock -period 4.1 -name v_SDRAM_CLK

# test clock
create_clock -period 30 [get_ports ate_clk]

create_generated_clock -add -master_clock SDRAM_CLK -source [get_ports sdram_clk] -name SD_DDR_CLK \
    -combinational [get_ports sd_CK]
create_generated_clock -add -master_clock SDRAM_CLK -source [get_ports sdram_clk] -name SD_DDR_CLKn \
    -combinational -invert [get_ports sd_CKn]

set_clock_groups -asynchronous \
    -name func_async \
    -group [get_clocks SYS*] \
    -group [get_clocks *PCI*] \
    -group [get_clocks *SD*]
