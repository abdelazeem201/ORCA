# Abstract
This repository contains low power multi-voltage and multi-threshold techniques implementation based on 32-nanometer ORCA design with RISC core for reducing both static and dynamic power. The designed processor was compared with previous 32-nanometer low power based research and regular
(without using low power techniques) 14-nanometer design to show the differences in power consumption after implementing
multi-voltage and multi-threshold techniques.

# ORCA
ORCA processor is a 32-bit CPU microprocessor core. Microprocessor has two main interfaces: PCI interface and source synchronous DDR interface for SDRAM. The subblock CLOCK_GEN contains two PLLs (Phase Locked Loop) and a clock multiplier for the functional clocks. These two PLLs cancel the clock tree insertion delay for the PCI I/O interface timing and for the SDRAM input interface timing. The sub-block RESET_BLOCK has a synchronizing reset circuitry for the global, asynchronous prst_n signal. The synchronizing reset circuitry is used during functional mode, but bypassed in test mode. The design has two main interfaces, a PCI interface and an SDRAM with a source synchronous double data rate interface (DDR). The SDRAM bus is capable of addressing PC266 type memory. The DDR data bus is
synchronous with both edges of the incoming and outgoing clocks. The processor core consists of a high-speed RISC machine with a power save mode. The BLENDER block is shut down during power save mode and RISC_CORE is slowed down to half its frequency. All asynchronous interfaces between clock domains are isolated with dual-port FIFOs.

<p align="center">
 <img src="https://github.com/abdelazeem201/ORCA/assets/58098260/df4030b6-2a2e-4f64-9a1f-72402e71b86c">
</p>

| .............       | Information   |
| -------------       | ------------- |
| Technology Node     | SAED32nm      |
| Number of Instances  | 52k Instances |
| Memory Quantity     | 40            |
| Frequency           | 133MHz & 244MHz @ss0p75v |
| MMMC                | 2 modes "Func and Test " |
| Voltage Area        | 2 |
| Floorplan size      | 999.856um x 1003.2um |
| Number of Ports     | 240 |
| metal layer         | 9 |
