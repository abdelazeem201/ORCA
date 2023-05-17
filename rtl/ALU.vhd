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
USE work.RISCTYPES.ALL;

ENTITY ALU IS
  PORT (
    reset_n, clk
      : IN std_logic;
    Oprnd_A,                            -- Operand A, from RegFile
    Oprnd_B                             -- Operand B, from RegFile or current inst
      : IN std_logic_vector (15 DOWNTO 0);


    ALU_OP                              -- Code from OP field of Instruction
      : IN std_logic_vector (5 DOWNTO 0);

    Latch_Result,
    Latch_Flags
      : IN  std_logic;
    Lachd_Result                        -- Result of performing OP on operands 
      : OUT std_logic_vector (15 DOWNTO 0);

    Zro_Flag,                           -- Zero flag
    Neg_Flag,                           -- Negative result flag 
    Carry_Flag                          -- Carry out flag
      : OUT std_logic

    );
END ALU;

ARCHITECTURE RTL OF ALU IS

  SIGNAL Op_Result                   : std_logic_vector (15 DOWNTO 0);
  SIGNAL ALU_Zro, ALU_Carry, ALU_Neg : std_logic;

BEGIN

  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';

    IF Latch_Result = '1' THEN
      Lachd_Result <= Op_Result;
    END IF;
  END PROCESS;

  PROCESS (reset_n, clk, Latch_Flags, ALU_Zro, ALU_Neg, ALU_Carry)
  BEGIN
    IF reset_n = '0' THEN
      Zro_Flag   <= '0';
      Neg_Flag   <= '0';
      Carry_Flag <= '0';
    ELSIF clk'event AND clk = '1' THEN
      IF Latch_Flags = '1' THEN
        Zro_Flag   <= ALU_Zro;
        Neg_Flag   <= ALU_Neg;
        Carry_Flag <= ALU_Carry;
      END IF;
    END IF;

  END PROCESS;

-- ALU Operations
  PROCESS (Oprnd_A, Oprnd_B, ALU_OP)
    VARIABLE Result   : std_logic_vector(15 DOWNTO 0);
    VARIABLE I, count : integer;
    VARIABLE carry    : std_logic;
  BEGIN
    carry := '0';
    count := 0;

    CASE ALU_OP IS

      WHEN OP_ADD =>
        Result := unsigned(Oprnd_A) + unsigned(Oprnd_B);

      WHEN OP_ADD_PLUS_ONE =>
        Result := unsigned(Oprnd_A) + (unsigned(Oprnd_B) + '1');

      WHEN OP_A | OP_Ap | OP_App =>
        Result := Oprnd_A;

      WHEN OP_A_PLUS_ONE =>
        Result := unsigned(Oprnd_A) + '1';

      WHEN OP_SUB =>
        Result := unsigned(Oprnd_A) - unsigned(Oprnd_B);

      WHEN OP_SUB_MINUS_ONE =>
        Result := unsigned(Oprnd_A) - (unsigned(Oprnd_B) + '1');

      WHEN OP_A_MINUS_ONE =>
        Result := unsigned(Oprnd_A) - '1';

      WHEN OP_ALL_ZEROS =>
        Result := "0000000000000000";

      WHEN OP_A_AND_B =>
        Result := Oprnd_A AND Oprnd_B;

      WHEN OP_notA_AND_B =>
        Result := NOT Oprnd_A AND Oprnd_B;

      WHEN OP_B =>
        Result := Oprnd_B;

      WHEN OP_notA_AND_notB =>
        Result := NOT Oprnd_A AND NOT Oprnd_B;

      WHEN OP_A_XNOR_B =>
        Result := NOT (Oprnd_A XOR Oprnd_B);

      WHEN OP_notA =>
        Result := NOT Oprnd_A;

      WHEN OP_notA_OR_B =>
        Result := NOT Oprnd_A OR Oprnd_B;

      WHEN OP_A_AND_notB =>
        Result := Oprnd_A AND NOT Oprnd_B;

      WHEN OP_A_XOR_B =>
        Result := Oprnd_A XOR Oprnd_B;

      WHEN OP_A_OR_B =>
        Result := Oprnd_A OR Oprnd_B;

      WHEN OP_notB =>
        Result := NOT Oprnd_B;

      WHEN OP_A_OR_notB =>
        Result := Oprnd_A OR NOT Oprnd_B;

      WHEN OP_A_NAND_B =>
        Result := NOT (Oprnd_A AND Oprnd_B);

      WHEN OP_ALL_ONES =>
        Result := "1111111111111111";

        -- When non-ALU ops don't generate errors
      WHEN OTHERS =>
        Result := "0000000000000000";
    END CASE;

    IF (Result = 0) THEN
      ALU_Zro <= '1';
    ELSE
      ALU_Zro <= '0';
    END IF;

    IF (Result < 0) THEN
      ALU_Neg <= '1';
    ELSE
      ALU_Neg <= '0';
    END IF;

    ALU_Carry <= '0';

    Op_Result <= Result;

  END PROCESS;
END RTL;


