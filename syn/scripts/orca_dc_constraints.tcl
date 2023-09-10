

#
# Constraints for the ORCA chip
# by AS on 2002.04.10
#
# Last modified: 2005-01-15

# Time Unit: ns
# Cap Unit : pf

set max_opcon saed32rvt_ff0p85v125c

set_operating_conditions -min ff1p16v125c  -max ss0p95v125c


# Test clocks
#  create_clock -period 20 [get_ports test_sys2x_clk]
#  create_clock -period 20 [get_ports test_mem_clk]
# IEEE 1149.1 TCK clock at 10 MHz
# create_clock -period 100 [get_ports TCK]

# PCI clock at 66 MHz
create_clock -period 15 -name pclk [get_ports pclk]
# System clock at 125 MHz
create_clock -period 4 -name sys_clk [get_ports sys_clk]
# sdram clock at 133 MHz
create_clock -period 7.5 -name sdr_clk [get_ports sdr_clk]

# Create PLL clocks
# Internal PCI clock
create_generated_clock \
    -name PCI_CLK \
    -source [get_pins I_CLOCK_GEN/I_PLL_PCI/REF_CLK] \
    -divide_by 2 \
    [get_pins I_CLOCK_GEN/I_PLL_PCI/CLK_1X] 

# SDRAM clock
create_generated_clock \
    -name SDRAM_CLK \
    -source [get_pins I_CLOCK_GEN/I_PLL_SD/REF_CLK] \
    -multiply_by 1 \
    [get_pins I_CLOCK_GEN/I_PLL_SD/CLK_1X]

# Create outgoing clocks for DDR interface
create_generated_clock \
    -name SD_DDR_CLK \
    -source [get_pins I_CLOCK_GEN/I_PLL_SD/CLK_1X] \
    -divide_by 1 \
    [get_ports sd_CK]

#  create_generated_clock \
#      -source [get_pins I_CLOCK_GEN/I_PLL_SD/CLK] \
#      -divide_by 1 -invert \
#      -name SD_DDR_CLKn \
#      [get_ports sd_CKn]

# System clocks
create_generated_clock \
    -name SYS_CLK \
    -source [get_pins I_CLOCK_GEN/I_CLKMUL/REF_CLK] \
    -multiply_by 1 \
    [get_pins I_CLOCK_GEN/I_CLKMUL/CLK_1X]

create_generated_clock \
    -name SYS_2x_CLK \
    -source [get_pins I_CLOCK_GEN/I_CLKMUL/REF_CLK] \
    -multiply_by 2 \
    [get_pins I_CLOCK_GEN/I_CLKMUL/CLK_2X]


# Set faster functional mode
set_case_analysis 0 [get_ports power_save]
set_case_analysis 1 [get_ports pm66en]
set_case_analysis 0 [get_ports test_mode]
set_case_analysis 0 [get_ports scan_en]
set_case_analysis 0 [get_ports pll_bypass]

#set_case_analysis 0 [get_pins I_CLOCK_GEN/I_CLKMUL/clk_2x]
#set_case_analysis 0 [get_ports test_*_clk]

set_load 2 [get_ports *]
#set_max_transition 1.5 *
set_max_capacitance 150 *
set_max_fanout 20 [all_inputs] 


set_clock_uncertainty -setup  0.2 [get_clocks SYS_CLK]
set_clock_uncertainty -setup 0.2 [get_clocks SYS_2x_CLK]
set_clock_uncertainty -setup 0.3 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.1 [get_clocks SDRAM_CLK]

# pre-CTS latency to compensate for mux and io-pad delay on SDRAM outgoing clock
set_clock_latency 2.0 [get_clocks SD_DDR_CLK]


# Constrain interface
set pci_io_ports [get_ports p* -filter "port_direction==inout"]
set pci_in_ports [add_to_collection [get_ports "pidsel pgnt_n pm66en"] $pci_io_ports]
set pci_out_ports [add_to_collection [get_ports "preq_n"] $pci_io_ports]
set pci_ports [add_to_collection $pci_io_ports [get_ports "pidsel pgnt_n pm66en preq_n"] ]

set sd_io_ddr_ports [get_ports "sd_DQ*"]
set sd_out_ports [remove_from_collection [get_ports sd_*] \
		      [add_to_collection $sd_io_ddr_ports [get_ports "sd_CK sd_CKn"]]]
set sd_ports [add_to_collection $sd_io_ddr_ports $sd_out_ports]

set mode_ports [get_ports "scan_en pll_bypass test_mode power_save"]

# Constrain PCI ports for functional clocks
set_input_delay 0.8 -max -clock PCI_CLK -add_delay $pci_in_ports
set_input_delay 2.0 -min -clock PCI_CLK -add_delay  $pci_in_ports
set_output_delay 4.0 -max -clock PCI_CLK -add_delay $pci_out_ports
set_output_delay -1.0 -min -clock PCI_CLK -add_delay $pci_out_ports
set_load 15 $pci_ports 

# Constrain SDRAM ports for functional clocks
set_input_delay 0.8 -max -add_delay -clock SDRAM_CLK $sd_io_ddr_ports
set_input_delay 0.8 -max -add_delay -clock SDRAM_CLK -clock_fall $sd_io_ddr_ports
set_input_delay 0.2 -min -add_delay -clock SDRAM_CLK $sd_io_ddr_ports
set_input_delay 0.2 -min -add_delay -clock SDRAM_CLK -clock_fall $sd_io_ddr_ports
set_output_delay 0.75 -max -add_delay -clock SD_DDR_CLK $sd_ports
set_output_delay 0.75 -max -add_delay -clock SD_DDR_CLK -clock_fall $sd_io_ddr_ports
set_output_delay -0.1 -min -add_delay -clock SD_DDR_CLK $sd_ports
set_output_delay -0.1 -min -add_delay -clock SD_DDR_CLK -clock_fall $sd_io_ddr_ports
set_load 20 $sd_ports
set_load 5 [get_ports "sd_CK sd_CKn"]

# Setup gating checks for DDR interface
set all_I0_mux_pins [get_pins I_ORCA_TOP/I_SDRAM_TOP/I_SDRAM_IF/sd_mux_dq_out_*/A1]
set all_I1_mux_pins [get_pins I_ORCA_TOP/I_SDRAM_TOP/I_SDRAM_IF/sd_mux_dq_out_*/A2]
set_clock_gating_check -low -setup 0 -hold 0 $all_I0_mux_pins
set_clock_gating_check -high -setup 0 -hold 0 $all_I1_mux_pins

# Set all input transitions
set_input_transition 0.5 [all_inputs]
set_input_transition 1.0 $pci_in_ports

# Set up constraints for clock gating in Blender design
#set_clock_gating_check -setup 0.2 -hold 0.2 -high [get_clocks SYS_CLK]

# Constrain mode inputs
set_input_delay 4.0 -max -clock PCI_CLK $mode_ports
set_input_delay 2.0 -min -clock PCI_CLK $mode_ports
set_load 10 $mode_ports

# Constraint TAP ports
# set TAP_ports [get_ports "TDI TDO TMS TRST"]
# set_input_delay 10 -clock TCK [get_ports "TDI TMS TRST"]
# set_output_delay 20 -clock TCK [get_ports "TDO"]
# set_load 10 $TAP_ports

# Set scan configuration
set_scan_configuration -style multiplexed_flip_flop

# Wire load models:
#  set_wire_load_mode top
#  set_wire_load_model -name 40KGATES

set_operating_conditions $max_opcon

# The IO2 ports are only used  as OUTPUTs, therefore the input paths are false paths! (BIDI ports!)
# set_false_path -to I_ORCA_TOP/I_RISC_CORE/I_REG_FILE/REG_FILE_A_RAM/IO2[*]
# set_false_path -to I_ORCA_TOP/I_RISC_CORE/I_REG_FILE/REG_FILE_B_RAM/IO2[*]
# set_false_path -to I_ORCA_TOP/I_CONTEXT_MEM/CONTEXT_RAM_0/IO2[*]
# set_false_path -to I_ORCA_TOP/I_CONTEXT_MEM/CONTEXT_RAM_1/IO2[*]
# set_false_path -to I_ORCA_TOP/I_CONTEXT_MEM/CONTEXT_RAM_2/IO2[*]
# set_false_path -to I_ORCA_TOP/I_CONTEXT_MEM/CONTEXT_RAM_3/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_0/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_1/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_2/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_3/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_4/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_5/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_6/IO2[*]
# set_false_path -to I_ORCA_TOP/I_PCI_TOP/I_PCI_READ_FIFO/PCI_RFIFO_RAM_7/IO2[*]
# set_false_path -to I_ORCA_TOP/I_SDRAM_READ_FIFO/SD_RFIFO_RAM/IO2[*]
