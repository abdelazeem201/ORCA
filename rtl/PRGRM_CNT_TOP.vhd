----------------------------------------------------------------------/
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----	
----                                                               ----  
----------------------------------------------------------------------- 


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.RISCTYPES.ALL;

ENTITY PRGRM_CNT_TOP IS
  PORT (
    clk           : IN  std_logic;
    reset_n       : IN  std_logic;
    Crnt_Instrn   : IN  std_logic_vector (31 DOWNTO 0);  -- Current Executing Inst
    Zro_Flag,                           -- Flags from ALU or Stack
    Carry_Flag,
    Neg_Flag      : IN  std_logic;
    Return_Addr   : IN  std_logic_vector (7 DOWNTO 0);
    Current_State : OUT State_Type;     -- CurrentState from Control FSM                       
    PC            : OUT std_logic_vector (7 DOWNTO 0)    -- Program Count
    );
END PRGRM_CNT_TOP;


ARCHITECTURE STRUCT OF PRGRM_CNT_TOP IS

  COMPONENT PRGRM_FSM PORT (
    clk          : IN  std_logic;
    reset_n      : IN  std_logic;
    CurrentState : OUT State_Type
    );
  END COMPONENT;

  COMPONENT PRGRM_DECODE PORT (
    Zro_Flag      : IN  std_logic;
    Carry_Flag    : IN  std_logic;
    Neg_Flag      : IN  std_logic;
    CurrentState  : IN  State_Type;
    Crnt_Instrn   : IN  std_logic_vector (31 DOWNTO 0);
    Incrmnt_PC    : OUT std_logic;
    Ld_Brnch_Addr : OUT std_logic;
    Ld_Rtn_Addr   : OUT std_logic
    );
  END COMPONENT;

  COMPONENT PRGRM_CNT PORT (
    reset_n       : IN  std_logic;
    clk           : IN  std_logic;
    Incrmnt_PC    : IN  std_logic;
    Ld_Brnch_Addr : IN  std_logic;
    Ld_Rtn_Addr   : IN  std_logic;
    Imm_Addr      : IN  std_logic_vector (7 DOWNTO 0);
    Return_Addr   : IN  std_logic_vector (7 DOWNTO 0);
    PC            : OUT std_logic_vector (7 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL Incrmnt_PC, Ld_Brnch_Addr, Ld_Rtn_Addr : std_logic;
  SIGNAL CurrentState                           : State_Type;

BEGIN

  I_PRGRM_FSM : PRGRM_FSM PORT MAP (
    clk          => clk,
    reset_n      => reset_n,
    CurrentState => CurrentState
    );

  I_PRGRM_DECODE : PRGRM_DECODE PORT MAP (
    Zro_Flag      => Zro_Flag,
    Carry_Flag    => Carry_Flag,
    Neg_Flag      => Neg_Flag,
    CurrentState  => CurrentState,
    Crnt_Instrn   => Crnt_Instrn,
    Incrmnt_PC    => Incrmnt_PC,
    Ld_Brnch_Addr => Ld_Brnch_Addr,
    Ld_Rtn_Addr   => Ld_Rtn_Addr
    );

  I_PRGRM_CNT : PRGRM_CNT PORT MAP (
    reset_n       => reset_n,
    clk           => clk,
    Incrmnt_PC    => Incrmnt_PC,
    Ld_Brnch_Addr => Ld_Brnch_Addr,
    Ld_Rtn_Addr   => Ld_Rtn_Addr,
    Imm_Addr      => Crnt_Instrn (7 DOWNTO 0),
    Return_Addr   => Return_Addr,
    PC            => PC
    );

  Current_State <= CurrentState;

END STRUCT;
