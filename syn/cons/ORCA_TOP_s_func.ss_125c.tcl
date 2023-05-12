# 
# ORCA_TOP
# scenario constraints func @ ss/125c
# Requires the file ORCA_TOP_port_lists.tcl to be sourced first
#

set_driving_cell -lib_cell ${DRIVING_CELL_CLOCKS} $orca_ports(clocks)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $orca_ports(mode_reset)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS}  $orca_ports(pci_inputs)

set_driving_cell -lib_cell ${DRIVING_CELL_PORTS} $orca_ports(sdram_inputs)
set_driving_cell -lib_cell ${DRIVING_CELL_PORTS} $orca_ports(sd_ddr_inputs)

set_driving_cell $orca_ports(test_si) -lib_cell INVX4_RVT

set_clock_uncertainty -setup 0.2 [get_clocks SYS_*]
set_clock_uncertainty -hold  0.1 [get_clocks SYS_*]
set_clock_uncertainty -setup 0.3 [get_clocks PCI_CLK]
set_clock_uncertainty -hold  0.1 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.2 [get_clocks SDRAM_CLK]
set_clock_uncertainty -hold  0.1 [get_clocks SDRAM_CLK]

set real_clocks [remove_from_collection [get_clocks] [get_clocks "v_* SD_DDR_CLK*"]]

set_clock_transition 0.2 $real_clocks

set_input_delay  -add_delay -max 4.0 -clock v_PCI_CLK $orca_ports(pci_inputs)
set_input_delay  -add_delay -min 2.0 -clock v_PCI_CLK $orca_ports(pci_inputs)
set_output_delay -add_delay -max 3.0 -clock v_PCI_CLK $orca_ports(pci_outputs)
set_output_delay -add_delay -min 0.5 -clock v_PCI_CLK $orca_ports(pci_outputs)

# Constrain SDRAM ports
set_input_delay 0.600 -max -add_delay -clock v_SDRAM_CLK $orca_ports(sd_ddr_inputs)
set_input_delay 0.600 -max -add_delay -clock v_SDRAM_CLK -clock_fall $orca_ports(sd_ddr_inputs)
set_input_delay 0.200 -min -add_delay -clock v_SDRAM_CLK $orca_ports(sd_ddr_inputs)
set_input_delay 0.200 -min -add_delay -clock v_SDRAM_CLK -clock_fall $orca_ports(sd_ddr_inputs)

# Constrain DDR interface
set_output_delay 0.750 -max -add_delay -clock SD_DDR_CLK $orca_ports(sdram_outputs)
set_output_delay 0.750 -max -add_delay -clock SD_DDR_CLK -clock_fall $orca_ports(sd_ddr_outputs)
set_output_delay 0.100 -min -add_delay -clock SD_DDR_CLK $orca_ports(sdram_outputs)
set_output_delay 0.100 -min -add_delay -clock SD_DDR_CLK -clock_fall $orca_ports(sd_ddr_outputs)

