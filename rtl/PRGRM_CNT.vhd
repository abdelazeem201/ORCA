----------------------------------------------------------------------/
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_signed.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY PRGRM_CNT IS
  PORT (
    reset_n,                            -- Reset for the PC
    clk,                                -- CPU Clock
    Incrmnt_PC,                         -- Increment PC
    Ld_Brnch_Addr,                      -- Load Jmp/Call Addr from instruction
    Ld_Rtn_Addr                         -- Load Return Addr
      : IN std_logic;
    Imm_Addr,                           -- Immediate Addr for Jmp/Call
    Return_Addr                         -- Return addr from Stack
      : IN std_logic_vector (7 DOWNTO 0);

    PC                                  -- Addr of instruction to be fetched in
    -- the next Fetch Cycle
      : OUT std_logic_vector (7 DOWNTO 0)
    );

END PRGRM_CNT;

ARCHITECTURE RTL OF PRGRM_CNT IS

  SIGNAL PCint : std_logic_vector (7 DOWNTO 0);

BEGIN

  PROCESS (reset_n, clk, PCint, Return_Addr, Imm_Addr)
  BEGIN
    IF reset_n = '0' THEN
      PCint <= "00000000";
    ELSIF clk'event AND clk = '1' THEN
      IF Incrmnt_PC = '1' THEN          -- Occurs in WRITEBACK cycle
        PCint <= unsigned(PCint) + unsigned ' ("001");
      ELSIF (Ld_Rtn_Addr = '1') THEN    -- Occurs in WRITEBACK cycle
        PCint <= Return_Addr;
      ELSIF (Ld_Brnch_Addr = '1') THEN  -- Occurs in WRITEBACK cycle
        PCint <= Imm_Addr;
      END IF;
    END IF;
  END PROCESS;

  PC <= PCint;

END RTL;
