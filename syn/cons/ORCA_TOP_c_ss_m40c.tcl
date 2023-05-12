set_parasitic_parameters -early_spec minTLU -late_spec minTLU
set_temperature -40
set_process_number 0.99
set_process_label slow
set_voltage 0.75  -object_list VDD
set_voltage 0.95  -object_list VDDH
set_voltage 0.00  -object_list VSS

set_timing_derate -early 0.95 -cell_delay -net_delay

set_load 80 $orca_ports(pci_outputs)
set_load 5 $orca_ports(sdram_outputs)
set_load 5 $orca_ports(sd_ddr_outputs)
set_load 20 $orca_ports(test_so)
