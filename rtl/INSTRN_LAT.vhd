----------------------------------------------------------------------/
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY INSTRN_LAT IS
  PORT (
    clk                                 -- CPU Clock
      : IN std_logic;
    Instrn                              -- Instrn for 
      : IN std_logic_vector (31 DOWNTO 0);

    Latch_Instr                         -- Enable for latching instruction
      : IN  std_logic;
    Crnt_Instrn_1
      : OUT std_logic_vector(31 DOWNTO 0);
    Crnt_Instrn_2                       -- Instrn under/about to be processed
      : OUT std_logic_vector(31 DOWNTO 0)
    );
END INSTRN_LAT;

ARCHITECTURE RTL OF INSTRN_LAT IS

BEGIN
  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';
    IF (Latch_Instr = '1') THEN
      Crnt_Instrn_1 <= Instrn;
      Crnt_Instrn_2 <= Instrn;
    END IF;
  END PROCESS;

END RTL;
