----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE work.RISCTYPES.ALL;

ENTITY RISC_CORE IS
  PORT (
    clk              : IN  std_logic;
    reset_n          : IN  std_logic;
    Instrn           : IN  std_logic_vector (31 DOWNTO 0);
    Xecutng_Instrn   : OUT std_logic_vector (31 DOWNTO 0);
    EndOfInstrn      : OUT std_logic;
    PSW              : OUT std_logic_vector (10 DOWNTO 0);
    Rd_Instr         : OUT std_logic;
    RESULT_DATA      : OUT std_logic_vector (15 DOWNTO 0);
    OUT_VALID        : OUT std_logic;
    STACK_FULL       : OUT std_logic
    );

END RISC_CORE;

ARCHITECTURE STRUCT OF RISC_CORE IS

  SIGNAL Oprnd_A, Oprnd_B, Op_Result, RegPort_A, RegPort_B, RegPort_C : std_logic_vector (15 DOWNTO 0);

  SIGNAL Addr_A, Addr_B, Addr_C : std_logic_vector(6 DOWNTO 0);

  SIGNAL ALU_OP : std_logic_vector (5 DOWNTO 0);

  SIGNAL ALU_Zro, ALU_Neg, ALU_Carry, Zro_Flag, Neg_Flag, Carry_Flag,
    PSW_Zro, PushEnbl, PopEnbl, PSW_Neg, PSW_Carry,
    Write_RegC, Rd_Oprnd_A, Rd_Oprnd_B, Latch_Instr, Latch_Flags,
    Latch_Result, UseData_Imm_Or_RegB, UseData_Imm_Or_ALU,
    Reset_AluRegs : std_logic;
  SIGNAL Current_State : State_Type;
  SIGNAL Crnt_Instrn_1, Crnt_Instrn_2 : std_logic_vector (31 DOWNTO 0);
  SIGNAL PushDataIn, PopDataOut : std_logic_vector (11 DOWNTO 0);
  SIGNAL Return_Addr, Imm_Addr  : std_logic_vector (7 DOWNTO 0);
  SIGNAL PC                     : std_logic_vector (7 DOWNTO 0);


  COMPONENT ALU
    PORT (
      reset_n, clk : IN  std_logic;
      Oprnd_A,
      Oprnd_B      : IN  std_logic_vector (15 DOWNTO 0);
      ALU_OP       : IN  std_logic_vector (5 DOWNTO 0);
      Latch_Result,
      Latch_Flags  : IN  std_logic;
      Lachd_Result : OUT std_logic_vector (15 DOWNTO 0);
      Zro_Flag, Neg_Flag,
      Carry_Flag   : OUT std_logic
      );
  END COMPONENT;

  COMPONENT CONTROL
    PORT (
      clk, reset_n  : IN  std_logic;
      Crnt_Instrn   : IN  std_logic_vector (31 DOWNTO 0);
      Current_State : IN  State_Type;
      Neg_Flag      : IN  std_logic;
      Carry_Flag    : IN  std_logic;
      Zro_Flag      : IN  std_logic;
      Latch_Instr,
      Rd_Oprnd_A, Rd_Oprnd_B,
      Latch_Flags, Latch_Result,
      Write_RegC,
      UseData_Imm_Or_RegB, UseData_Imm_Or_ALU,
      Reset_AluRegs, EndOfInstrn,
      PushEnbl, PopEnbl,
      OUT_VALID     : OUT std_logic
      );
  END COMPONENT;

  COMPONENT DATA_PATH
    PORT (
      clk, reset_n,
      Reset_AluRegs,
      Rd_Oprnd_A, Rd_Oprnd_B,
      UseData_Imm_Or_RegB, UseData_Imm_Or_ALU,
      Latch_Flags,
      ALU_Zro, ALU_Neg, ALU_Carry,
      PSW_Zro, PSW_Neg, PSW_Carry
                  : IN     std_logic;
      Crnt_Instrn : IN     std_logic_vector (31 DOWNTO 0);
      RegPort_A, RegPort_B, Op_Result
                  : IN     std_logic_vector (15 DOWNTO 0);
      Zro_Flag, Neg_Flag, Carry_Flag
                  : BUFFER std_logic;
      Addr_A      : OUT    std_logic_vector(6 DOWNTO 0);
      Oprnd_A, Oprnd_B, RegPort_C
                  : OUT    std_logic_vector (15 DOWNTO 0)
      );
  END COMPONENT;

  COMPONENT INSTRN_LAT
    PORT (
      clk           : IN  std_logic;
      Instrn        : IN  std_logic_vector (31 DOWNTO 0);
      Latch_Instr   : IN  std_logic;
      Crnt_Instrn_1 : OUT std_logic_vector(31 DOWNTO 0);
      Crnt_Instrn_2 : OUT std_logic_vector(31 DOWNTO 0)
      );
  END COMPONENT;

  COMPONENT PRGRM_CNT_TOP
    PORT (
      clk, reset_n  : IN  std_logic;
      Crnt_Instrn   : IN  std_logic_vector (31 DOWNTO 0);
      Zro_Flag      : IN  std_logic;
      Carry_Flag    : IN  std_logic;
      Neg_Flag      : IN  std_logic;
      Return_Addr   : IN  std_logic_vector (7 DOWNTO 0);
      Current_State : OUT State_Type;
      PC            : OUT std_logic_vector (7 DOWNTO 0)
      );
  END COMPONENT;

  COMPONENT REG_FILE
    PORT (
      reset_n : IN std_logic;
      clk : IN  std_logic;
      Addr_A, Addr_B, Addr_C
                   : IN  std_logic_vector (6 DOWNTO 0);
      RegPort_C    : IN  std_logic_vector (15 DOWNTO 0);
      Write_RegC   : IN  std_logic;
      RegPort_A, RegPort_B
                   : OUT std_logic_vector ( 15 DOWNTO 0)
      );
  END COMPONENT;

  COMPONENT STACK_TOP
    PORT (
      reset_n, clk      : IN  std_logic;
      PushEnbl, PopEnbl : IN  std_logic;
      PushDataIn        : IN  std_logic_vector (11 DOWNTO 0);
      PopDataOut        : OUT std_logic_vector (11 DOWNTO 0);
      STACK_FULL        : OUT std_logic
      );
  END COMPONENT;

BEGIN

-- Connectivity definition of components
  PushDataIn (11 DOWNTO 0) <= ALU_Zro & Zro_Flag & Neg_Flag & Carry_Flag & PC;
  Return_Addr              <= PopDataOut (7 DOWNTO 0);
  PSW_Zro                  <= PopDataOut(10);
  PSW_Neg                  <= PopDataOut(9);
  PSW_Carry                <= PopDataOut(8);
  ALU_OP                   <= Crnt_Instrn_1 (29 DOWNTO 24);
  Addr_B                   <= Crnt_Instrn_1 ( 6 DOWNTO 0);
  Addr_C                   <= Crnt_Instrn_1 (22 DOWNTO 16);
  PSW                      <= PC & Zro_Flag & Neg_Flag & Carry_Flag;
  Rd_Instr                 <= Latch_Instr;
  Xecutng_Instrn           <= Crnt_Instrn_1;
  RESULT_DATA              <= RegPort_A;

-- Entity instantiations

  I_ALU : ALU PORT MAP (
    reset_n      => reset_n,
    clk          => clk,
    Oprnd_A      => Oprnd_A,
    Oprnd_B      => Oprnd_B,
    ALU_OP       => ALU_OP,
    Latch_Result => Latch_Result,
    Latch_Flags  => Latch_Flags,
    Lachd_Result => Op_Result,
    Zro_Flag     => ALU_Zro,
    Neg_Flag     => ALU_Neg,
    Carry_Flag   => ALU_Carry
    );

  I_CONTROL : CONTROL PORT MAP (
    clk                 => clk,
    reset_n             => reset_n,
    Crnt_Instrn         => Crnt_Instrn_2,
    Current_State       => Current_State,
    Neg_Flag            => Neg_Flag,
    Carry_Flag          => Carry_Flag,
    Zro_Flag            => Zro_Flag,
    Latch_Instr         => Latch_Instr,
    Rd_Oprnd_A          => Rd_Oprnd_A,
    Rd_Oprnd_B          => Rd_Oprnd_B,
    Latch_Flags         => Latch_Flags,
    Latch_Result        => Latch_Result,
    Write_RegC          => Write_RegC,
    UseData_Imm_Or_RegB => UseData_Imm_Or_RegB,
    UseData_Imm_Or_ALU  => UseData_Imm_Or_ALU,
    Reset_AluRegs       => Reset_AluRegs,
    EndOfInstrn         => EndOfInstrn,
    PushEnbl            => PushEnbl,
    PopEnbl             => PopEnbl,
    OUT_VALID           => OUT_VALID
    );

  I_DATA_PATH : DATA_PATH PORT MAP (
    clk                 => clk,
    reset_n             => reset_n,
    Reset_AluRegs       => Reset_AluRegs,
    Rd_Oprnd_A          => Rd_Oprnd_A,
    Rd_Oprnd_B          => Rd_Oprnd_B,
    UseData_Imm_Or_RegB => UseData_Imm_Or_RegB,
    UseData_Imm_Or_ALU  => UseData_Imm_Or_ALU,
    Latch_Flags         => Latch_Flags,
    ALU_Zro             => ALU_Zro,
    ALU_Neg             => ALU_Neg,
    ALU_Carry           => ALU_Carry,
    PSW_Zro             => PSW_Zro,
    PSW_Neg             => PSW_Neg,
    PSW_Carry           => PSW_Carry,
    Crnt_Instrn         => Crnt_Instrn_2,
    RegPort_A           => RegPort_A,
    RegPort_B           => RegPort_B,
    Op_Result           => Op_Result,
    Zro_Flag            => Zro_Flag,
    Neg_Flag            => Neg_Flag,
    Carry_Flag          => Carry_Flag,
    Addr_A              => Addr_A,
    Oprnd_A             => Oprnd_A,
    Oprnd_B             => Oprnd_B,
    RegPort_C           => RegPort_C
    );

  I_INSTRN_LAT : INSTRN_LAT PORT MAP (
    clk           => clk,
    Instrn        => Instrn,
    Latch_Instr   => Latch_Instr,
    Crnt_Instrn_1 => Crnt_Instrn_1,
    Crnt_Instrn_2 => Crnt_Instrn_2
    );

  I_PRGRM_CNT_TOP : PRGRM_CNT_TOP PORT MAP (
    clk           => clk,
    reset_n       => reset_n,
    Crnt_Instrn   => Crnt_Instrn_2,
    Zro_Flag      => Zro_Flag,
    Carry_Flag    => Carry_Flag,
    Neg_Flag      => Neg_Flag,
    Return_Addr   => Return_Addr,
    Current_State => Current_State,
    PC            => PC
    );

  I_REG_FILE : REG_FILE PORT MAP (
    reset_n    => reset_n,
    clk        => clk,
    Addr_A     => Addr_A,
    Addr_B     => Addr_B,
    Addr_C     => Addr_C,
    RegPort_C  => RegPort_C,
    Write_RegC => Write_RegC,
    RegPort_A  => RegPort_A,
    RegPort_B  => RegPort_B
    );

  I_STACK_TOP : STACK_TOP PORT MAP (
    reset_n    => reset_n,
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    PushDataIn => PushDataIn,
    PopDataOut => PopDataOut,
    STACK_FULL => STACK_FULL
    );
END STRUCT;


