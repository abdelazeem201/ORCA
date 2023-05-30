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

ENTITY STACK_TOP IS
  PORT (
    reset_n,                            -- Reset
    clk,                                -- Clock
    PushEnbl,                           -- Push cmd for stack
    PopEnbl                             -- Pop cmd for stack
      : IN std_logic;

    PushDataIn                          -- Data to be pushed into the stack 
      : IN std_logic_vector (11 DOWNTO 0);

    PopDataOut                          -- Data popped out of the stack
      : OUT std_logic_vector (11 DOWNTO 0);
    STACK_FULL                          -- Stack is full
      : OUT std_logic
    );
END STACK_TOP;

ARCHITECTURE STRUCT OF STACK_TOP IS

  COMPONENT STACK_FSM PORT (
    reset_n    : IN  std_logic;
    clk        : IN  std_logic;
    PushEnbl   : IN  std_logic;
    PopEnbl    : IN  std_logic;
    TOS        : OUT std_logic_vector (0 TO 2);
    STACK_FULL : OUT std_logic
    );
  END COMPONENT;

  COMPONENT STACK_MEM PORT (
    clk        : IN  std_logic;
    PushEnbl   : IN  std_logic;
    PopEnbl    : IN  std_logic;
    Stack_Full : IN  std_logic;
    TOS        : IN  std_logic_vector (0 TO 2);
    PushDataIn : IN  std_logic_vector (3 DOWNTO 0);
    PopDataOut : OUT std_logic_vector (3 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL TOS            : std_logic_vector (0 TO 2);
  SIGNAL STACK_FULL_int : std_logic;

BEGIN

  I_STACK_FSM : STACK_FSM PORT MAP (
    reset_n    => reset_n,
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    TOS        => TOS,
    STACK_FULL => STACK_FULL_int
    );

  I1_STACK_MEM : STACK_MEM PORT MAP (
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    Stack_Full => STACK_FULL_int,
    TOS        => TOS,
    PushDataIn => PushDataIn(3 DOWNTO 0),
    PopDataOut => PopDataOut(3 DOWNTO 0)
    );

  I2_STACK_MEM : STACK_MEM PORT MAP (
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    Stack_Full => STACK_FULL_int,
    TOS        => TOS,
    PushDataIn => PushDataIn(7 DOWNTO 4),
    PopDataOut => PopDataOut(7 DOWNTO 4)
    );

  I3_STACK_MEM : STACK_MEM PORT MAP (
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    Stack_Full => STACK_FULL_int,
    TOS        => TOS,
    PushDataIn => PushDataIn(11 DOWNTO 8),
    PopDataOut => PopDataOut(11 DOWNTO 8)
    );

  STACK_FULL <= STACK_FULL_int;

END STRUCT;
