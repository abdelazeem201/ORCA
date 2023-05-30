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

ENTITY STACK_MEM IS
  PORT (
    clk,                                -- Clock
    PushEnbl,                           -- Push cmd for stack
    PopEnbl,                            -- Pop cmd for stack
    Stack_Full                          -- Stack is full flag      
      : IN std_logic;

    TOS : IN std_logic_vector (0 TO 2);

    PushDataIn                          -- Data to be pushed into the stack 
      : IN std_logic_vector (3 DOWNTO 0);

    PopDataOut                          -- Data popped out of the stack
      : OUT std_logic_vector (3 DOWNTO 0)
    );
END STACK_MEM;

ARCHITECTURE RTL OF STACK_MEM IS

  TYPE   Mem IS ARRAY (0 TO 7) OF std_logic_vector (3 DOWNTO 0);
  SIGNAL Stack_Mem   : Mem;
  SIGNAL Pop_Address : std_logic_vector (0 TO 2);

BEGIN
  -- Generate Correct Address for Pop
  PROCESS(Stack_Full, TOS)
  BEGIN
    IF (Stack_Full = '1') THEN
      Pop_Address <= TOS;
    ELSE
      Pop_Address <= TOS - '1';
    END IF;
  END PROCESS;

  -- Stack Memory writes; described as a set of registers (edge sensitive)
  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';
    IF(PushEnbl = '1') THEN             -- {
      Stack_Mem(conv_integer(unsigned(TOS))) <= PushDataIn;
    END IF;  -- }
  END PROCESS;

  -- Stack Memory reads; the output is latched every clock edge
  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';
    IF(PopEnbl = '1') THEN
      PopDataOut <= Stack_Mem(conv_integer(unsigned(Pop_Address)));
    END IF;
  END PROCESS;

END RTL;
