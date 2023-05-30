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

ENTITY STACK_FSM IS
  PORT (
    reset_n,                              -- Reset
    clk,                                  -- Clock
    PushEnbl,                             -- Push cmd for stack
    PopEnbl                               -- Pop cmd for stack
        : IN  std_logic;
    TOS : OUT std_logic_vector (0 TO 2);  -- Stack address
    STACK_FULL                            -- Stack is full
        : OUT std_logic
    );
END STACK_FSM;

ARCHITECTURE RTL OF STACK_FSM IS

  TYPE   Stack_State IS (EMPTY, NORMAL, FULL, error);
  SIGNAL Crnt_Stack, Next_Stack : Stack_State;
  SIGNAL Next_TOS, TOS_int      : std_logic_vector (0 TO 2);

BEGIN
  PROCESS (Crnt_Stack, TOS_int, PushEnbl, PopEnbl)
  BEGIN
    IF (PushEnbl = '1' AND PopEnbl = '1') THEN
      Next_Stack <= error;
      Next_TOS   <= "000" ;
    ELSE
      CASE Crnt_Stack IS
        WHEN EMPTY =>
          IF (PushEnbl = '1') THEN
            Next_Stack <= NORMAL;
            Next_TOS   <= "001";
          ELSIF (PopEnbl = '1') THEN
            Next_Stack <= error;
            Next_TOS   <= "000";
          ELSE
            Next_Stack <= EMPTY;
            Next_TOS   <= "000";
          END IF;
        WHEN NORMAL =>
          IF (PushEnbl = '1') THEN
            IF (TOS_int = "111") THEN
              Next_Stack <= FULL;
              Next_TOS   <= "111";
            ELSE
              Next_Stack <= NORMAL;
              Next_TOS   <= TOS_int + '1';
            END IF;
          ELSIF (PopEnbl = '1') THEN
            IF (TOS_int = "001") THEN
              Next_Stack <= EMPTY;
              Next_TOS   <= "000";
            ELSE
              Next_Stack <= NORMAL;
              Next_TOS   <= TOS_int - '1';
            END IF;
          ELSE
            Next_Stack <= NORMAL;
            Next_TOS   <= TOS_int;
          END IF;

        WHEN FULL =>
          IF (PushEnbl = '1') THEN
            Next_Stack <= error;
            Next_TOS   <= "111";
          ELSIF (PopEnbl = '1') THEN
            Next_Stack <= NORMAL;
            Next_TOS   <= "111";
          ELSE
            Next_Stack <= FULL;
            Next_TOS   <= "111";
          END IF;

        WHEN error =>
          Next_Stack <= error;
          Next_TOS   <= "111";
      END CASE;
    END IF;
  END PROCESS;

  PROCESS (reset_n, clk, Next_Stack, Next_TOS, Crnt_Stack, TOS_int)
  BEGIN
    IF reset_n = '0' THEN
      Crnt_Stack <= EMPTY;
      TOS_int    <= "000";
      STACK_FULL <= '0';
    ELSIF clk'event AND clk = '1' THEN

      Crnt_Stack <= Next_Stack;
      TOS_int    <= Next_TOS;
      IF (Crnt_Stack = FULL AND TOS_int = "111") THEN
        STACK_FULL <= '1';
      ELSE
        STACK_FULL <= '0';
      END IF;
    END IF;
  END PROCESS;

  TOS <= TOS_int;

END RTL;
