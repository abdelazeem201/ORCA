----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY RISC_CHIP IS
  PORT (
    clk              : IN  std_logic;
    Test_Regfile_Clk : IN  std_logic;
    scan_en          : IN  std_logic;
    Test_Mode        : IN  std_logic;
    reset_n          : IN  std_logic;
    Instrn           : IN  std_logic_vector (3 DOWNTO 0);
    Xecutng_Instrn   : OUT std_logic_vector (3 DOWNTO 0);
    EndOfInstrn      : OUT std_logic;
    PSW              : OUT std_logic_vector (10 DOWNTO 0);
    Rd_Instr         : OUT std_logic;
    RESULT_DATA      : OUT std_logic_vector (3 DOWNTO 0);
    OUT_VALID        : OUT std_logic;
    STACK_FULL       : OUT std_logic
    );
END RISC_CHIP;

ARCHITECTURE STRUCT OF RISC_CHIP IS

  COMPONENT RISC_CORE
  PORT (
    clk              : IN  std_logic;
--    Test_Regfile_Clk : IN  std_logic;
--    Test_Mode        : IN  std_logic;
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
  END COMPONENT;

  COMPONENT pc3d01                             -- non-invering input buffer
    PORT (
      PAD            	: IN std_logic;
      CIN            	: OUT std_logic
      );
  END COMPONENT;

  COMPONENT pc3o05                             -- 3V CMOS Output Pad
    PORT (
      I            	: IN std_logic;
      PAD            	: OUT std_logic
      );
  END COMPONENT;

  SIGNAL net_clk              : std_logic;
  SIGNAL net_Test_Regfile_Clk : std_logic;
  SIGNAL net_Test_Mode        : std_logic;
  SIGNAL net_reset_n          : std_logic;
  SIGNAL net_Instrn           : std_logic_vector (31 DOWNTO 0);
  SIGNAL net_Instrn_reduced   : std_logic_vector (3 DOWNTO 0);
  SIGNAL net_Xecutng_Instrn   : std_logic_vector (31 DOWNTO 0);
  SIGNAL net_Xecutng_Instrn_reduced : std_logic_vector (3 DOWNTO 0);
  SIGNAL net_EndOfInstrn      : std_logic;
  SIGNAL net_PSW              : std_logic_vector (10 DOWNTO 0);
  SIGNAL net_Rd_Instr         : std_logic;
  SIGNAL net_RESULT_DATA      : std_logic_vector (15 DOWNTO 0);
  SIGNAL net_RESULT_DATA_reduced : std_logic_vector (3 DOWNTO 0);
  SIGNAL net_OUT_VALID        : std_logic;
  SIGNAL net_STACK_FULL       : std_logic;

  BEGIN
  
    clk_iopad: pc3d01 PORT MAP
    (     
      PAD => clk,
      CIN => net_clk
    );

     Test_Regfile_Clk_iopad: pc3d01 PORT MAP
     (     
       PAD => Test_Regfile_Clk,
       CIN => net_Test_Regfile_Clk
     );

     Test_Mode_iopad: pc3d01 PORT MAP
     (     
       PAD => Test_Mode,
       CIN => net_Test_Mode
     );

     scan_en_iopad: pc3d01 PORT MAP
     (     
       PAD => scan_en,
       CIN => open
     );

    reset_n_iopad: pc3d01 PORT MAP
    (     
      PAD => reset_n,
      CIN => net_reset_n
    );

  Instrn_Bus: FOR bit_index IN 3 DOWNTO 0 GENERATE
    Instrn_iopad: pc3d01 PORT MAP
    (     
      PAD => Instrn(bit_index),
      CIN => net_Instrn_reduced(bit_index)
    );
  END GENERATE Instrn_Bus;

  Xecutng_Instrn_Bus: FOR bit_index IN 3 DOWNTO 0 GENERATE
    Xecutng_Instrn_iopad: pc3o05
    PORT MAP 
    ( PAD => Xecutng_Instrn(bit_index),
      I   => net_Xecutng_Instrn_reduced(bit_index)
    );
  END GENERATE Xecutng_Instrn_Bus;

  PSW_Bus: FOR bit_index IN 10 DOWNTO 0 GENERATE
    PSW_iopad: pc3o05
    PORT MAP 
    ( PAD => PSW(bit_index),
      I   => net_PSW(bit_index)
    );
  END GENERATE PSW_Bus;

  RESULT_DATA_Bus: FOR bit_index IN 3 DOWNTO 0 GENERATE
    RESULT_DATA_iopad: pc3o05
    PORT MAP 
    ( PAD => RESULT_DATA(bit_index),
      I   => net_RESULT_DATA_reduced(bit_index)
    );
  END GENERATE RESULT_DATA_Bus;

  EndOfInstrn_iopad: pc3o05
    PORT MAP 
    ( PAD => EndOfInstrn,
      I   => net_EndOfInstrn
    );
  
  Rd_Instr_iopad: pc3o05
    PORT MAP 
    ( PAD => Rd_Instr,
      I   => net_Rd_Instr
    );
  
  OUT_VALID_iopad: pc3o05
    PORT MAP 
    ( PAD => OUT_VALID,
      I   => net_OUT_VALID
    );
  
  STACK_FULL_iopad: pc3o05
    PORT MAP 
    ( PAD => STACK_FULL,
      I   => net_STACK_FULL
    );

  process(net_Instrn_reduced)
  begin
    FOR i IN 0 TO 31 loop
      net_Instrn(i) <= net_Instrn_reduced(i MOD 4);
    END loop;
  END process;

  process(net_Xecutng_Instrn)
  begin
    FOR i IN 0 TO 3 loop
      net_Xecutng_Instrn_reduced(i) <= net_Xecutng_Instrn(i*8 + 0) XOR
                                       net_Xecutng_Instrn(i*8 + 1) XOR
                                       net_Xecutng_Instrn(i*8 + 2) XOR
                                       net_Xecutng_Instrn(i*8 + 3) XOR
                                       net_Xecutng_Instrn(i*8 + 4) XOR
                                       net_Xecutng_Instrn(i*8 + 5) XOR
                                       net_Xecutng_Instrn(i*8 + 6) XOR
                                       net_Xecutng_Instrn(i*8 + 7);
    END loop;
  END process;
  
  process(net_RESULT_DATA)
  begin
    FOR i IN 1 TO 3 loop
      net_RESULT_DATA_reduced(i) <= net_RESULT_DATA(i*4 + 0) XOR
                                    net_RESULT_DATA(i*4 + 1) XOR
                                    net_RESULT_DATA(i*4 + 2) XOR
                                    net_RESULT_DATA(i*4 + 3);
    END loop;
    net_RESULT_DATA_reduced(0) <= (net_RESULT_DATA(0) and net_Xecutng_Instrn(0)) xor
                                  (net_RESULT_DATA(1) and net_Xecutng_Instrn(1)) xor
                                  (net_RESULT_DATA(2) and net_Xecutng_Instrn(2)) xor
                                  (net_RESULT_DATA(3) and net_Xecutng_Instrn(3));
  END process;

  
  I_RISC_CORE: RISC_CORE PORT MAP
  (
    clk            	 => net_clk,
--     Test_Regfile_Clk     => net_Test_Regfile_Clk,
--     Test_Mode            => net_Test_Mode,
    Reset_n          	 => net_Reset_n,
    Instrn         	 => net_Instrn,
    Xecutng_Instrn 	 => net_Xecutng_Instrn,
    EndOfInstrn    	 => net_EndOfInstrn,
    PSW            	 => net_PSW,
    Rd_Instr       	 => net_Rd_Instr,
    RESULT_DATA    	 => net_RESULT_DATA,
    OUT_VALID      	 => net_OUT_VALID,
    STACK_FULL     	 => net_STACK_FULL
  );

END STRUCT;


configuration risc_config of RISC_CHIP is
  for STRUCT
    for I_RISC_CORE: RISC_CORE
      use entity work.RISC_CORE(struct);
      for struct -- of RISC_CORE
        for I_REG_FILE: REG_FILE
          use entity work.REG_FILE(RAMS_2);
        end for; -- I_REG_FILE
      end for; -- struct
    end for; -- I_RISC_CORE
  end for; -- STRUCT of RISC_CHIP
end risc_config;
