

#
# Read ORCA_TOP source files and save as unmapped DDC
#

# Let's use the Presto VHDL reader
set hdlin_enable_presto_for_vhdl true
# This enables the use of configurations - necessary for ORCA 2.4 and up!
set hdlin_enable_configurations true


# Read the entire vhdl tree:
acs_read_hdl -no_elaborate -hdl_source ../rtl ORCA_TOP
elaborate orca_config

# DC will add generic info to the name of the design!!
# This makes for hard to read timing reports.
# To remove that information, the design needs to be renamed.
#rename_design [get_designs SDRAM_RFIFO*] SDRAM_RFIFO
#rename_design [get_designs SDRAM_WFIFO*] SDRAM_WFIFO
#rename_design [get_designs PCI_RFIFO*] PCI_RFIFO
#rename_design [get_designs PCI_WFIFO*] PCI_WFIFO
#rename_design [get_designs SDRAM_IF*] SDRAM_IF
#rename_design [get_designs PCI_CORE*] PCI_CORE

current_design ORCA_TOP
link

write -format ddc -h -o ../output/unmapped/ORCA_TOP.ddc
#read_ddc unmapped/ORCA_TOP_hier.ddc

exit
