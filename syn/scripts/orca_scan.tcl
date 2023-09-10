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

# ORCA XG mode scan insertion script

read_ddc ../output/mapped/ORCA.ddc
current_design ORCA
link

# Leave optimization of the scan_en buffer tree to the physical tools
set_false_path -from [get_ports scan_en]
set_auto_disable_drc_nets -scan true


set_scan_state test_ready

#specify test components in preparation for create_test_protocol
set_dft_signal -view existing_dft -type TestClock -timing {45 55} -port {sdr_clk sys_clk pclk}
set_dft_signal -view existing_dft -port prst_n -type Reset -active_state 0
set_dft_signal -view existing_dft -port scan_en -type ScanEnable -active_state 1
set_dft_signal -view existing_dft -type Constant -active_state 1 -port test_mode

set test_default_delay 0
set test_default_bidir_delay 0
set test_default_strobe 40
set test_stil_netlist_format verilog

# no change to design names
set_dft_insertion_configuration -preserve_design_name true
# -synthesis none

set_scan_configuration \
    -internal_clocks single \
    -chain_count 6 \
    -clock_mixing mix_clocks \
    -add_lockup true

for {set i 0} {$i < 6} {incr i} {
    set_dft_signal -view spec -port pad[$i] -type ScanDataIn -hookup_pin [get_pins pad_iopad_$i/DOUT]
    set_dft_signal -view spec -port sd_A[$i]  -type ScanDataOut -hookup_pin [get_pins sdram_A_iopad_$i/A]
    set_scan_path chain$i -view spec -scan_data_in pad[$i] -scan_data_out sd_A[$i] 
}

report_dft_signal

create_test_protocol
dft_drc
write_test_protocol -output ../design_data/ORCA.spf

set old_prefix $compile_instance_name_prefix
set compile_instance_name_prefix "DFTC_"
preview_dft
insert_dft
#report_cell [get_cells -hier {LOCKUP* DFTC_*}]
set compile_instance_name_prefix $old_prefix
unset old_prefix

dft_drc -coverage_estimate

change_names -hierarchy -rules verilog

# Save scan chain layout for Astro/ICC to the mapped directory
###############################################################
write_scan_def -output ../output/mapped/ORCA.scandef

write -f ddc -hier -o ../output/mapped/ORCA_scan.ddc
write -f verilog -hier -o ../output/mapped/ORCA_scan.v

report_qor > ../output/dc.orca_scan.qor
report_constraint -all > ../output/dc.orca_scan.constraint-all
report_timing > ../output/dc.orca_scan.timing
# Custom report
report_design > ../output/dc.cell_sizes

exit
