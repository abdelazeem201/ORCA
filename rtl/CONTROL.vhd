----------------------------------------------------------------------/
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.RISCTYPES.ALL;

ENTITY CONTROL IS
  PORT (
    clk,                                -- CPU Clock
    reset_n                             -- Reset to the cpu core
      : IN std_logic;

    Crnt_Instrn                         -- Current instruction under execution;
    -- from Instruction Latch
      : IN std_logic_vector (31 DOWNTO 0);

    Current_State
      : IN State_Type;

    Neg_Flag,
    Carry_Flag,
    Zro_Flag
      : IN std_logic;

    Latch_Instr,                        -- Enable for latching current instruction
    Rd_Oprnd_A,                         -- Latch operand A into reg at i/p of ALU
    Rd_Oprnd_B,                         -- Latch operand B into reg at i/p of ALU
    Latch_Flags,                        -- Enable for storing flags, only occurs
    -- for ALU type instructions in Execute Clock 
    Latch_Result,                       -- Enable for latching o/p of ALU into latch 
    Write_RegC,                         -- Write for operand C (in execute cycle)

    UseData_Imm_Or_RegB,
    -- Select for mux between RegFile portB data
    -- and Imm data (8-bit)

    UseData_Imm_Or_ALU,                 -- Select for mux between ALU o/p and
    -- and Imm data to load to Register File
    Reset_AluRegs,
    -- Used to reset alu i/ps on every 
    -- FETCH_INSTRN state
    EndOfInstrn,                        -- Used to dump PSW and RegFile contents into files at
    -- end of every WRITE_BACK cycle
    PushEnbl,
    PopEnbl,
    OUT_VALID                           -- to indicate that execution of DATA OUT 
      : OUT std_logic

    );
END CONTROL;

ARCHITECTURE RTL OF CONTROL IS

  SIGNAL Data_Imm_Or_ALU, Data_Imm_Or_RegB : std_logic;
  SIGNAL Take_Branch                       : std_logic;

BEGIN

  PROCESS (Crnt_Instrn, Neg_Flag, Carry_Flag, Zro_Flag)

    VARIABLE Neg, Carry, Zro, Jmp : std_logic;

  BEGIN

    IF (Crnt_Instrn(25)) = '1' THEN
      Neg   := NOT Neg_Flag;
      Carry := NOT Carry_Flag;
      Zro   := NOT Zro_Flag;
      Jmp   := '0';
    ELSE
      Neg   := Neg_Flag;
      Carry := Carry_Flag;
      Zro   := Zro_Flag;
      Jmp   := '1';
    END IF;

    IF (Crnt_Instrn(23 DOWNTO 16) = "00000000") THEN
      Take_Branch <= Neg;
    ELSIF (Crnt_Instrn(23 DOWNTO 16) = "00000001") THEN
      Take_Branch <= Zro;
    ELSIF (Crnt_Instrn(23 DOWNTO 16) = "00111111") THEN
      Take_Branch <= Jmp;
    ELSE Take_Branch <= '0';
    END IF;

  END PROCESS;

  PROCESS (Current_State, Crnt_Instrn, Take_Branch)
  BEGIN
    OUT_VALID <= '0';
    CASE Current_State IS

      WHEN RESET_STATE =>
        PushEnbl         <= '0';
        PopEnbl          <= '0';
        Latch_Flags      <= '0';
        Latch_Result     <= '0';
        Rd_Oprnd_A       <= '0';
        Rd_Oprnd_B       <= '0';
        Data_Imm_Or_RegB <= '0';
        Data_Imm_Or_ALU  <= '0';
        Latch_Instr      <= '0';
        Reset_AluRegs    <= '0';
        Write_RegC       <= '0';

      WHEN FETCH_INSTR =>
        Data_Imm_Or_RegB <= '0';
        Data_Imm_Or_ALU  <= '0';
        Latch_Instr      <= '1';
        Reset_AluRegs    <= '1';
        Write_RegC       <= '0';
        PushEnbl         <= '0';
        PopEnbl          <= '0';
        Latch_Flags      <= '0';
        Latch_Result     <= '0';
        Rd_Oprnd_A       <= '0';
        Rd_Oprnd_B       <= '0';

      WHEN READ_OPS =>
        Latch_Instr   <= '0';
        Reset_AluRegs <= '0';
        PushEnbl      <= '0';
        PopEnbl       <= '0';
        Latch_Flags   <= '0';
        Latch_Result  <= '0';
        Write_RegC    <= '0';

        -- Generation of mux selects for data path and operand read signals
        -- Asserting them in this state gives sufficient time for setup

        CASE Crnt_Instrn(31 DOWNTO 30) IS
          WHEN "01" =>                  --    (Type 1 instruction)
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '0';
            Rd_Oprnd_A       <= '1';
            Rd_Oprnd_B       <= '1';

          WHEN "10" =>                  --    (Type 2 instruction)
            Data_Imm_Or_RegB <= '1';
            Data_Imm_Or_ALU  <= '0';
            Rd_Oprnd_A       <= '1';
            Rd_Oprnd_B       <= '1';

          WHEN "11" =>                  --    (Type 3 instruction)
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '1';
            Rd_Oprnd_A       <= '0';
            Rd_Oprnd_B       <= '1';

          WHEN OTHERS =>
          --
          --WHEN "00" =>                  --    (Type 0 instruction)
            -- These 2 can actually be don't cares for Type 0
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '0';
            Rd_Oprnd_A       <= '0';
            Rd_Oprnd_B       <= '0';
        END CASE;

-- Added by Anupam For reading the REG_FILE address given in instruction on user request
        IF ( Crnt_Instrn(31 DOWNTO 30) = "00" AND 
             Crnt_Instrn(24) = '1') THEN
          Rd_Oprnd_A <= '1';
        END IF;
        
      WHEN EXECUTE =>
        Rd_Oprnd_A    <= '0';
        Rd_Oprnd_B    <= '0';
        Latch_Instr   <= '0';
        Reset_AluRegs <= '0';
        Write_RegC    <= '0';

        CASE Crnt_Instrn(31 DOWNTO 30) IS
          WHEN "01" =>                  --    (Type 1 instruction)
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '0';

          WHEN "10" =>                  --    (Type 2 instruction)
            Data_Imm_Or_RegB <= '1';
            Data_Imm_Or_ALU  <= '0';

          WHEN "11" =>                  --    (Type 3 instruction)
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '1';

          WHEN OTHERS =>
          --WHEN "00" =>                  --    (Type 0 instruction)
            -- These 2 can actually be don't cares for Type 0
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '0';
        END CASE;

        IF ( Crnt_Instrn(31 DOWNTO 30) = "00" AND Crnt_Instrn(24) = '1') THEN
          OUT_VALID <= '1';
        ELSE
          OUT_VALID <= '0';
        END IF;

-- Push PC into Stack (Call Conditional)
        IF ((Crnt_Instrn (31 DOWNTO 30) = "00" AND  -- Testing for Call instruction
             Crnt_Instrn(28) = '1'
             ) AND
            Take_Branch = '1'
            ) THEN                                  -- {
          PushEnbl <= '1';
        ELSE
          PushEnbl <= '0';
        END IF;  --}

        -- Pop from Stack (Return)
        IF (Crnt_Instrn(31 DOWNTO 30) = "00" AND 
            Crnt_Instrn(27) = '1'
            ) THEN                      -- {
          PopEnbl <= '1';
        ELSE
          PopEnbl <= '0';
        END IF;  --}
        -- Latching flags for ALU ops but not pass-thru ( ?? Can this be same as Latch_Result ??)
        IF (Crnt_Instrn(31 DOWNTO 30) = "01" OR 
            Crnt_Instrn(31 DOWNTO 30) = "10"
            ) THEN                      -- {
          Latch_Flags <= '1';
        ELSE
          Latch_Flags <= '0';
        END IF;  --}

        -- Latching result for ALU and pass-thru
        IF (Crnt_Instrn(31 DOWNTO 30) = "01" OR 
            Crnt_Instrn(31 DOWNTO 30) = "10" OR
            Crnt_Instrn(31 DOWNTO 30) = "11"
            ) THEN                      -- {
          Latch_Result <= '1';
        ELSE
          Latch_Result <= '0';
        END IF;  --}

      WHEN WRITEBACK =>
        Latch_Flags   <= '0';
        Latch_Result  <= '0';
        PushEnbl      <= '0';
        PopEnbl       <= '0';
        Rd_Oprnd_A    <= '0';
        Rd_Oprnd_B    <= '0';
        Latch_Instr   <= '0';
        Reset_AluRegs <= '0';

        -- Write result of ALU OP or the immediate data to reg_file
        IF (Crnt_Instrn(31 DOWNTO 30) /= "00") THEN  -- {
          Write_RegC <= '1';
        ELSE
          Write_RegC <= '0';
        END IF;  --}

        CASE Crnt_Instrn(31 DOWNTO 30) IS
          WHEN "01" =>                  --    (Type 1 instruction)
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '0';

          WHEN "10" =>                  --    (Type 2 instruction)
            Data_Imm_Or_RegB <= '1';
            Data_Imm_Or_ALU  <= '0';

          WHEN "11" =>                  --    (Type 3 instruction)
            Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '1';

          WHEN OTHERS =>
           --WHEN "00" =>                  --    (Type 0 instruction)
            -- These 2 can actually be don't cares for Type 0
           Data_Imm_Or_RegB <= '0';
            Data_Imm_Or_ALU  <= '0';
        END CASE;

      WHEN OTHERS =>
        PushEnbl         <= '0';
        PopEnbl          <= '0';
        Latch_Flags      <= '0';
        Latch_Result     <= '0';
        Rd_Oprnd_A       <= '0';
        Rd_Oprnd_B       <= '0';
        Data_Imm_Or_RegB <= '0';
        Data_Imm_Or_ALU  <= '0';
        Latch_Instr      <= '0';
        Reset_AluRegs    <= '0';
        Write_RegC       <= '0';

    END CASE;
  END PROCESS;

  PROCESS (reset_n, clk, Data_Imm_Or_RegB, Data_Imm_Or_ALU)
  BEGIN
    IF reset_n = '0' THEN
      UseData_Imm_Or_RegB <= '0';
      UseData_Imm_Or_ALU  <= '0';
    ELSIF clk'event AND clk = '1' THEN
      UseData_Imm_Or_RegB <= Data_Imm_Or_RegB;
      UseData_Imm_Or_ALU  <= Data_Imm_Or_ALU;
    END IF;
  END PROCESS;

-- Added to generate signals which control file dump
  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';
    IF(Current_State = WRITEBACK) THEN  -- {
      EndOfInstrn <= '1';
    ELSE
      EndOfInstrn <= '0';
    END IF;  --}
    
  END PROCESS;

END RTL;

