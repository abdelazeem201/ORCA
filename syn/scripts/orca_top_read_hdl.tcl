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
