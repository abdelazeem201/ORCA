----------------------------------------------------------------------/
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY DATA_PATH IS
  PORT (
    clk,                                -- Clock
    reset_n,                            -- Reset for flags
    Reset_AluRegs,                      -- Reset alu port registers
    Rd_Oprnd_A,                         -- From CONTROL;Commands to read operand A & B
    Rd_Oprnd_B,                         -- into regs at i/p of ALU
    UseData_Imm_Or_RegB,                -- Selects Immediate Data(8-bit) from Instrn 
    -- Latch or from Reg File PortB for ALU input
    UseData_Imm_Or_ALU,                 -- Selects Immediate Data(16-bit) from Instrn
    -- Latch or from ALU Result
    Latch_Flags,                        -- Enable for latching flags
    ALU_Zro,                            -- ALU o/p 
    ALU_Neg,                            -- ALU o/p 
    ALU_Carry,                          -- ALU o/p 
    PSW_Zro,                            -- Stack value of Zro flag
    PSW_Neg,                            -- Stack value of Neg flag
    PSW_Carry                           -- Stack value of Carry flag
      : IN std_logic;

    Crnt_Instrn                         -- Instrn under execution from INSTRN_LAT
      : IN std_logic_vector (31 DOWNTO 0);

    RegPort_A,                          -- RegFile portA data o/p;latched & fed to ALU
    RegPort_B,                          -- RegFile portB data o/p;latched & fed to ALU
    Op_Result                           -- ALU result; latched, then  muxed with 
    -- DataImmediate from INSTRN_LAT to feed 
    -- the RegFile as RegPort_C
      : IN std_logic_vector (15 DOWNTO 0);

    Zro_Flag,                           -- Latched flag 
    Neg_Flag,                           -- Latched flag
    Carry_Flag                          -- Latched flag (Not implemented )
      : OUT std_logic;
    Addr_A                              -- to calculate address for REG_FILE port A  
      : OUT std_logic_vector (6 DOWNTO 0);
    Oprnd_A,                            -- Fed to ALU portA
    Oprnd_B,                            -- Fed to ALU portB
    RegPort_C                           -- I/p to RegFile portC
      : OUT std_logic_vector (15 DOWNTO 0)
    );
END DATA_PATH;

ARCHITECTURE RTL OF DATA_PATH IS

  SIGNAL PSWL_Zro, PSWL_Carry, PSWL_Neg : std_logic;

BEGIN
  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';

-- Register at ALU input A
    IF (Reset_AluRegs = '1') THEN
      Oprnd_A <= "0000000000000000";
    ELSIF (Rd_Oprnd_A = '1') THEN
      Oprnd_A <= RegPort_A;
    END IF;

-- Register at ALU input B (Muxing with imm data included here)
    IF (Reset_AluRegs = '1') THEN
      Oprnd_B <= "0000000000000000";
    ELSIF (Rd_Oprnd_B = '1') THEN
      IF (UseData_Imm_Or_RegB = '1') THEN
        Oprnd_B <= "00000000" & Crnt_Instrn(7 DOWNTO 0);
      ELSIF (UseData_Imm_Or_RegB = '0') THEN
        Oprnd_B <= RegPort_B;
      END IF;
    END IF;

  END PROCESS;

  PROCESS (reset_n, clk, PSW_Zro, PSW_Neg, PSW_Carry)
  BEGIN
    IF reset_n = '0' THEN
      PSWL_Zro   <= '0';
      PSWL_Neg   <= '0';
      PSWL_Carry <= '0';
    ELSIF clk'event AND clk = '1' THEN
      IF Latch_Flags = '1' THEN
        PSWL_Zro   <= PSW_Zro;
        PSWL_Neg   <= PSW_Neg;
        PSWL_Carry <= PSW_Carry;
      END IF;
    END IF;
  END PROCESS;

-- Mux between latched ALU Result and Immediate data to be loaded into RegFile
  PROCESS (Crnt_Instrn, Op_Result, UseData_Imm_Or_ALU )
  BEGIN
    IF (UseData_Imm_Or_ALU = '1') THEN
      RegPort_C <= Crnt_Instrn (15 DOWNTO 0);
    ELSE
      RegPort_C <= Op_Result;
    END IF;
  END PROCESS;

-- Muxing of flags betn popped and ALU outputs - Return instrn alone requires popped flags
  PROCESS (Crnt_Instrn, PSWL_Zro, PSWL_Neg, PSWL_Carry, ALU_Zro, ALU_Neg, ALU_Carry)

  BEGIN
    IF (Crnt_Instrn(31 DOWNTO 24) = "00001000") THEN
      Zro_Flag   <= PSWL_Zro;
      Neg_Flag   <= PSWL_Neg;
      Carry_Flag <= PSWL_Carry;
    ELSE
      Zro_Flag   <= ALU_Zro;
      Neg_Flag   <= ALU_Neg;
      Carry_Flag <= ALU_Carry;
    END IF;
  END PROCESS;


-- Added by Anupam to calculate Address for port_A of REG_FILE

  PROCESS(Crnt_Instrn)
  BEGIN
    IF (Crnt_Instrn(31 DOWNTO 30) = "00" AND Crnt_Instrn(24) = '1') THEN
      Addr_A <= Crnt_Instrn(6 DOWNTO 0);
    ELSE
      Addr_A <= Crnt_Instrn(14 DOWNTO 8);
    END IF;
  END PROCESS;

END RTL;
