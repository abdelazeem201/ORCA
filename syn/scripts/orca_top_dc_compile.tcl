#######################################################################
####                                                               ####
####  The data contained in the file is created for educational    #### 
####  and training purposes only and is  not recommended           ####
####  for fabrication                                              ####
####                                                               ####
#######################################################################
####                                                               ####
####  Copyright (C) 2013 Synopsys, Inc.                            ####
####                                                               ####
#######################################################################
####                                                               ####
####  The 32/28nm Generic Library ("Library") is unsupported       ####    
####  Confidential Information of Synopsys, Inc. ("Synopsys")      ####    
####  provided to you as Documentation under the terms of the      ####    
####  End User Software License Agreement between you or your      ####    
####  employer and Synopsys ("License Agreement") and you agree    ####    
####  not to distribute or disclose the Library without the        ####    
####  prior written consent of Synopsys. The Library IS NOT an     ####    
####  item of Licensed Software or Licensed Product under the      ####    
####  License Agreement.  Synopsys and/or its licensors own        ####    
####  and shall retain all right, title and interest in and        ####    
####  to the Library and all modifications thereto, including      ####    
####  all intellectual property rights embodied therein. All       ####    
####  rights in and to any Library modifications you make are      ####    
####  hereby assigned to Synopsys. If you do not agree with        ####    
####  this notice, including the disclaimer below, then you        ####    
####  are not authorized to use the Library.                       ####    
####                                                               ####  
####                                                               ####      
####  THIS LIBRARY IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN   ####
####  "AS IS" BASIS, WITH NO INTELLECUTAL PROPERTY                 ####
####  INDEMNIFICATION AND NO SUPPORT. ANY EXPRESS OR IMPLIED       ####
####  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED       ####
####  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR   ####
####  PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS    ####
####  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     ####
####  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      ####
####  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;     ####
####  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)     ####
####  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN    ####
####  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE    ####
####  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS      ####
####  DOCUMENTATION, EVEN IF ADVISED OF THE POSSIBILITY OF         ####
####  SUCH DAMAGE.                                                 #### 
####                                                               ####  
#######################################################################

#
# DC compile script for ORCA
# by Amin Shehata
#
# Last modified on 2006-02-16
#


# No Tri's or assigns in any verilog output
set verilogout_no_tri true

set hdlin_enable_presto_for_vhdl true


reset_timer orca_timer

read_ddc ../output/mapped/ORCA_TOP.ddc
read_ddc ../output/mapped/CLOCK_GEN.ddc

read_vhdl ../rtl/ORCA.vhd
current_design ORCA
link

# Apply CHIP constraints
source ../scripts/orca_dc_constraints.tcl

# Don't touch the io pads, clock generators and clock tree sources
set_dont_touch [get_cells *_iopad*]
set_dont_touch [get_cells I_CLK_SOURCE*]
set_ideal_network [get_pins I_CLK_SOURCE*/Y]
set_ideal_network -no_propagate [get_nets s_*_rst_n]
set_ideal_network [get_ports scan_en]

#  set_dont_touch [get_cells I_CLOCK_GEN/I_PLL*]
#  set_dont_touch [get_cells I_CLOCK_GEN/I_CLKMUL]
set_dont_touch [get_designs CLOCK_GEN]
# protect the SD output muxes:
set_dont_touch [get_cells I_ORCA_TOP/I_SDRAM_TOP/I_SDRAM_IF/sd_mux*]
set_ideal_network [get_pins I_ORCA_TOP/I_SDRAM_TOP/I_SDRAM_IF/sd_mux*/Y]





group_path -name INS -from [all_inputs] -critical_range 10
group_path -name OUTS -to [all_outputs] -critical_range 10



set_critical_range 1.0 [current_design]

set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

#set_ultra_optimization true

set compile_implementation_selection false
compile -scan -incr

change_names -hierarchy -rule verilog

write -f verilog -h -o ../output/mapped/ORCA.v
write -f ddc -h -o ../output/mapped/ORCA.ddc
write_sdc -nosplit ../output/mapped/ORCA.sdc



report_constraint -all > ../output/dc.constraint-all
report_timing > ../output/dc.timing
report_qor > ../output/dc.qor



#exit
