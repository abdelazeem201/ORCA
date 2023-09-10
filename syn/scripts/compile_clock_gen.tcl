

# Script to pre-compile the clock_gen block

# These two are now implemented as a library: cb13special.lib
#read_verilog PLL.v
#read_verilog CLKMUL.v

read_vhdl ../rtl/CLOCK_GEN.vhd

create_clock -p 15 pclk
create_clock -p 7.5 sdram_clk
create_clock -p 4 sys_clk


set_propagated_clock [all_clocks]
#set_max_delay .3 -to [all_outputs]
#set_load 0.2 [all_outputs]
#set_case_analysis 0 test_mode
#set_case_analysis 0 powersave
#set_wire_load_model -name 40KGATES

compile -scan -exact_map

write -f ddc -h -o ../output/mapped/CLOCK_GEN.ddc

#exit
