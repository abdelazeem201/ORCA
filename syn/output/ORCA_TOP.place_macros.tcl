################################################################################
#
# Created by icc2 write_floorplan on Sun Nov  1 22:41:32 2020
#
################################################################################


set _dirName__0 [file dirname [file normalize [info script]]]

################################################################################
# Cells
################################################################################

set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_8 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 680.0630 81.2330 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_7 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 680.0630 10.5130 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_6 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 755.3670 76.1580 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_5 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 755.3670 10.5130 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_4 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 923.1250 338.7380 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 903.9770 338.7380 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 923.1250 273.0930 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_READ_FIFO/PCI_FIFO_RAM_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 903.9770 273.0930 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_8 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 923.1250 66.1580 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_7 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 903.9770 207.4480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_6 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 903.9770 66.1580 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_5 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 923.1250 207.4480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_4 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 903.9770 76.1580 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 923.1250 76.1580 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 903.9770 197.4480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_PCI_TOP/I_PCI_WRITE_FIFO/PCI_FIFO_RAM_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 923.1250 197.4480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_0_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 220.6440 224.3230 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_0_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 241.2850 224.3230 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_0_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 440.0720 224.3230 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_0_4 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 126.9620 315.0350 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_1_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 883.9090 830.5430 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_1_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 883.9090 748.6690 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_1_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 885.3070 662.9370 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_1_4 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 878.3890 989.5480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_2_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 107.6810 321.8680 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_2_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 107.6810 239.7220 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_2_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 107.6810 159.5930 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_2_4 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 332.2350 315.0350 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_3_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 854.3830 989.5480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_3_2 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 657.8470 989.5480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_3_3 }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 635.9850 989.5480 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_CONTEXT_MEM/I_CONTEXT_RAM_3_4 }]
set_attribute -quiet -objects $cellInst -name orientation -value R270
set_attribute -quiet -objects $cellInst -name origin -value { 768.7790 897.1990 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_RISC_CORE/I_REG_FILE/REG_FILE_D_RAM }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 156.2890 991.3020 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_RISC_CORE/I_REG_FILE/REG_FILE_C_RAM }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 315.3630 902.4810 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_RISC_CORE/I_REG_FILE/REG_FILE_B_RAM }]
set_attribute -quiet -objects $cellInst -name orientation -value MYR90
set_attribute -quiet -objects $cellInst -name origin -value { 156.2890 886.0830 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_RISC_CORE/I_REG_FILE/REG_FILE_A_RAM }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 156.2890 684.9050 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_SDRAM_TOP/I_SDRAM_READ_FIFO/SD_FIFO_RAM_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 362.5440 8.5850 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_SDRAM_TOP/I_SDRAM_READ_FIFO/SD_FIFO_RAM_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value MXR90
set_attribute -quiet -objects $cellInst -name origin -value { 130.2040 8.5850 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_SDRAM_TOP/I_SDRAM_WRITE_FIFO/SD_FIFO_RAM_1 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 489.4690 8.5850 }
set_attribute -quiet -objects $cellInst -name status -value fixed


set cellInst [get_cells { I_SDRAM_TOP/I_SDRAM_WRITE_FIFO/SD_FIFO_RAM_0 }]
set_attribute -quiet -objects $cellInst -name orientation -value R90
set_attribute -quiet -objects $cellInst -name origin -value { 117.4470 8.5850 }
set_attribute -quiet -objects $cellInst -name status -value fixed


