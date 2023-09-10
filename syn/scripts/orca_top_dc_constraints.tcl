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

# Constraints for the ORCA TOP level design
# by AS on 4/10/03
#
# Last modified on 2005.02.22
#

# Time Unit: ns
# Cap Unit : pf

set io_lib saed32nm_max_0d95_125
set max_opcon max0d85v2d25v125T
set io_lib_cell IBUFFX2

#set_operating_conditions -min FF0p75v125T -max SS0p945vm40T

# PCI clock at 66 MHz
create_clock -period 15 -name PCI_CLK [get_ports pclk]
# System clock at 125 MHz
create_clock -period 4 -name SYS_CLK [get_ports sys_clk]
# System clock at 250 MHz
create_clock -period 2 -name SYS_2x_CLK [get_ports sys_2x_clk]
# SDRAM clock at 133 MHz
create_clock -period 7.5 -name SDRAM_CLK [get_ports sdram_clk]

set_clock_uncertainty -setup 0.2 [get_clocks SYS_CLK]
set_clock_uncertainty -setup 0.2 [get_clocks SYS_2x_CLK]
set_clock_uncertainty -setup 0.3 [get_clocks PCI_CLK]
set_clock_uncertainty -setup 0.2 [get_clocks SDRAM_CLK]
set_operating_conditions $max_opcon

# Filter out the clock ports, scan_en and test_mode
set inputs [remove_from_collection [all_inputs] [get_ports "*clk* scan_en test_mode"]]

set sdram_inputs  [get_ports sd_* -filter "port_direction == in"]
set sdram_outputs [get_ports sd_* -filter "port_direction == out"]

set pci_inputs  [remove_from_collection $inputs $sdram_inputs]
set pci_outputs [remove_from_collection [all_outputs] $sdram_outputs]

# Constrain mode ports

# Constrain PCI ports
set_input_delay 0.8 -clock PCI_CLK $pci_inputs
set_output_delay 7.0 -clock PCI_CLK $pci_outputs
set_driving_cell $pci_inputs\
    -library $io_lib \
    -lib_cell $io_lib_cell \
    -pin Y \
    -input_transition_rise 1.0 \
    -input_transition_fall 1.0 \
    -from_pin A 
set_load [load_of [get_lib_pins $io_lib/$io_lib_cell/A]] $pci_outputs

# Constrain SDRAM ports
set_input_delay 3.0 -clock SDRAM_CLK $sdram_inputs
set_output_delay 3.0 -clock SDRAM_CLK $sdram_outputs
set_driving_cell [get_ports sd_DQ_in] \
    -library $io_lib \
    -lib_cell  $io_lib_cell \
    -pin Y \
    -input_transition_rise 0.5 \
    -input_transition_fall 0.5 \
    -from_pin A
set_load [load_of [get_lib_pins $io_lib/$io_lib_cell/A]] $sdram_outputs
set_load [load_of [get_lib_pins $io_lib/$io_lib_cell/A]] [get_ports sd_DQ_out]
set_load [load_of [get_lib_pins $io_lib/$io_lib_cell/A]] [get_ports sd_DQ_en]

#set_load 2 [get_ports *]
#set_max_transition 1.5 *
#set_max_capacitance 150 *


# Set up constraints for clock gating
set_clock_gating_check -setup 0.300 -hold 0.300 [get_designs BLENDER*]

set_scan_configuration -style multiplexed_flip_flop
