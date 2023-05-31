-----------------------------------------------------------------------
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----  
----                                                               ----      
----                                                               ----  
----------------------------------------------------------------------- 


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.RISCTYPES.ALL;

ENTITY PRGRM_FSM IS
  PORT (
    clk,                                -- CPU Clock
    reset_n                             -- CPU Reset
      : IN  std_logic;
    CurrentState                        -- Current State of FSM
      : OUT State_Type
    );
END PRGRM_FSM;

ARCHITECTURE RTL OF PRGRM_FSM IS

--    type State_Type is (RESET_STATE, FETCH_INSTR, READ_OPS, EXECUTE, WRITEBACK);
  SIGNAL Current_State, Next_State : State_Type;

BEGIN

  PROCESS (Current_State)
  BEGIN
    CASE Current_State IS
      WHEN RESET_STATE =>
        Next_State <= FETCH_INSTR;
      WHEN FETCH_INSTR =>
        Next_State <= READ_OPS;
      WHEN READ_OPS =>
        Next_State <= EXECUTE;
      WHEN EXECUTE =>
        Next_State <= WRITEBACK;
      WHEN WRITEBACK =>
        Next_State <= FETCH_INSTR;
    END CASE;
  END PROCESS;

  PROCESS(reset_n, clk, Next_State)
  BEGIN
    IF reset_n = '0' THEN
      Current_State <= RESET_STATE;
    ELSIF clk'event AND clk = '1' THEN

      Current_State <= Next_State;
    END IF;
  END PROCESS;

  CurrentState <= Current_State;

END RTL;

