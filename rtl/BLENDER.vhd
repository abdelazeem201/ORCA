----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

USE WORK.ORCA_TYPES.ALL;

ENTITY BLENDER IS
    PORT (
      clk               : IN  std_logic;
      reset_n           : IN  std_logic;
      clk_enable        : IN  std_logic;
      test_mode         : IN  std_logic;
      operation         : IN  std_logic_vector(3 DOWNTO 0);
      op1               : IN  std_logic_vector(31 DOWNTO 0);
      op2               : IN  std_logic_vector(31 DOWNTO 0);
      result            : OUT std_logic_vector(31 DOWNTO 0)
    );
END BLENDER;

ARCHITECTURE RTL OF BLENDER IS
  TYPE   data_page IS ARRAY (0 TO blender_shift_depth) OF std_logic_vector(31 DOWNTO 0);
  SIGNAL mega_shift   : data_page;

  SIGNAL gclk           : std_logic;
  SIGNAL trans1         : std_logic;
  SIGNAL trans2         : std_logic;
  SIGNAL trans3         : std_logic;
  SIGNAL rem_red        : std_logic;
  SIGNAL rem_green      : std_logic;
  SIGNAL rem_blue       : std_logic;

  SIGNAL c_trans1       : std_logic;
  SIGNAL c_trans2       : std_logic;
  SIGNAL c_trans3       : std_logic;
  SIGNAL c_rem_red      : std_logic;
  SIGNAL c_rem_green    : std_logic;
  SIGNAL c_rem_blue     : std_logic;

  SIGNAL s1_op1         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s1_op2         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s2_op1         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s2_op2         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s3_op1         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s3_op2         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s4_op1         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s4_op2         : std_logic_vector(31 DOWNTO 0);
  SIGNAL s5_result      : std_logic_vector(15 DOWNTO 0);

  SIGNAL latched_clk_en : std_logic;
  
BEGIN

  -- Block will switch off clocks if not enabled!
  -- if testmode, clk always enabled!
  clk_en_latch: PROCESS(clk_enable, clk)
  BEGIN
    IF clk = '0' THEN
      latched_clk_en <= clk_enable;
    END IF;
  END PROCESS;
  
  gclk <= clk AND (latched_clk_en OR test_mode);

  command_seq: PROCESS (reset_n, gclk, c_trans1, c_trans2, c_trans3, c_rem_red, c_rem_blue, c_rem_green)
  BEGIN
    IF reset_n = '0' THEN
      trans1 <= '0';
      trans2 <= '0';
      trans3 <= '0';
      rem_red <= '0';
      rem_blue <= '0';
      rem_green <= '0';
    ELSIF gclk'event AND gclk='1' THEN 
      trans1 <= c_trans1;
      trans2 <= c_trans2;
      trans3 <= c_trans3;
      rem_red <= c_rem_red;
      rem_blue <= c_rem_blue;
      rem_green <= c_rem_green;
    END IF;
  END process;

  command_decode: PROCESS (operation)
  BEGIN
      c_trans1 <= '0';
      c_trans2 <= '0';
      c_trans3 <= '0';
      c_rem_red <= '0';
      c_rem_blue <= '0';
      c_rem_green <= '0';

      CASE operation IS
        WHEN "0101" =>
          c_trans1 <= '1';
          c_rem_red <= '1';
        WHEN "1101" =>
          c_rem_blue <= '1';
        WHEN "1010" =>
          c_rem_green <= '1';
          c_trans2 <= '1';
        WHEN "1001" =>
          c_trans3 <= '1';
        WHEN "1110" =>
          c_trans1 <= '1';
          c_trans2 <= '1';
          c_trans3 <= '1';
        WHEN "1111" =>
          c_rem_red <= '1';
        WHEN OTHERS =>
          NULL;
      END CASE;        
  END process;

  s1: process
  begin
    WAIT UNTIL gclk'event AND gclk='1';

    IF trans1 = '1' THEN
      s1_op1 <= op1(31 DOWNTO 24) & op2(23 DOWNTO 16) & op1(15 DOWNTO 8) & op2(7 DOWNTO 0);
      s1_op2 <= op2(31 DOWNTO 24) & op1(23 DOWNTO 16) & op2(15 DOWNTO 8) & op1(7 DOWNTO 0);
    ELSIF trans2 = '1' THEN
      s1_op1 <= op2(7 DOWNTO 0) & op1(31 DOWNTO 24) & op2(23 DOWNTO 16) & op1(15 DOWNTO 8);
      s1_op2 <= op1(7 DOWNTO 0) & op2(31 DOWNTO 24) & op1(23 DOWNTO 16) & op2(15 DOWNTO 8);
    ELSE
      s1_op1 <= op1;
      s1_op2 <= op2;
    END if;      
  END process;

  s2: process
  begin
    WAIT UNTIL gclk'event AND gclk='1';

    IF rem_red = '1' THEN
      s2_op1 <= "00000000" & s1_op2(23 DOWNTO 16) & s1_op1(15 DOWNTO 8) & s1_op2(7 DOWNTO 0);
      s2_op2 <= "00000000" & s1_op1(23 DOWNTO 16) & s1_op2(15 DOWNTO 8) & s1_op1(7 DOWNTO 0);
    ELSIF rem_green = '1' THEN
      s2_op1 <= s1_op2(7 DOWNTO 0) & "00000000" & s1_op2(23 DOWNTO 16) & s1_op1(15 DOWNTO 8);
      s2_op2 <= s1_op1(7 DOWNTO 0) & "00000000" & s1_op1(23 DOWNTO 16) & s1_op2(15 DOWNTO 8);
    ELSIF rem_blue = '1' THEN
      s2_op1 <= s1_op2(7 DOWNTO 0) & s1_op2(23 DOWNTO 16) & "00000000" & s1_op1(15 DOWNTO 8);
      s2_op2 <= s1_op1(7 DOWNTO 0) & s1_op1(23 DOWNTO 16) & "00000000" & s1_op2(15 DOWNTO 8);
    ELSE
      s2_op1 <= s1_op1;
      s2_op2 <= s1_op2;
    END IF;      
  END PROCESS;

  s3: process
  begin
    WAIT UNTIL gclk'event AND gclk='1';

    IF trans3 = '1' THEN
      s3_op1 <= s2_op1 + 7;
      s3_op2 <= s2_op2 - 23;
    ELSIF trans1 = '1' AND trans2 = '1' THEN
      s3_op1 <= s2_op1 + 214;
      s3_op2 <= s2_op2 - 997;
    ELSE
      s3_op1 <= s2_op1;
      s3_op2 <= s2_op2;
    END IF;      
  END PROCESS;

  s4: process
  begin
    WAIT UNTIL gclk'event AND gclk='1';

    IF rem_green = '1' AND rem_red = '1' THEN
      s4_op1 <= (s3_op1(31 DOWNTO 16) + s3_op1(15 DOWNTO 0)) * (s3_op2(31 DOWNTO 16) - s3_op2(15 DOWNTO 0));
      s4_op2 <= (s3_op2(31 DOWNTO 16) + s3_op1(15 DOWNTO 0)) * (s3_op2(31 DOWNTO 16) - s3_op1(15 DOWNTO 0));
    ELSIF trans2 = '1' AND trans3 = '1' THEN
      s4_op1 <= (s3_op1(31 DOWNTO 20) * s3_op1(19 DOWNTO 8)) & s3_op1(7 DOWNTO 0);
      s4_op2 <= (s3_op2(31 DOWNTO 20) * s3_op2(19 DOWNTO 8)) & s3_op2(7 DOWNTO 0);
    ELSE
      s4_op1 <= s3_op1;
      s4_op2 <= s3_op2;
    END IF;      
  END PROCESS;



  s5: PROCESS (s4_op1, s4_op2)
  begin
    FOR i IN 0 TO 15 loop
      s5_result(i) <= (s4_op1(i*2) XOR s4_op2(i*2)) XOR (s4_op1(i*2+1) XOR s4_op2(i*2+1));
    END LOOP;
  END process;



  shift_regs: PROCESS (reset_n, gclk, mega_shift, s5_result)
  BEGIN
    IF reset_n = '0' THEN
      mega_shift <= (OTHERS => (OTHERS => '0') );
    ELSIF gclk'event AND gclk='1' THEN 
  
      mega_shift(blender_shift_depth) <= s5_result & s5_result;

      FOR i IN 0 TO blender_shift_depth-1 loop
        --mega_shift(i) <= word_mult_16( mega_shift(i+1) );
        --mega_shift(i) <= word_mux_32( mega_shift(i+1) );
        mega_shift(i) <= word_mult_16( mega_shift(i+1) );
      END LOOP;
    END IF;
  END PROCESS;

  sout: PROCESS ( reset_n, gclk, mega_shift )
  begin
    IF reset_n = '0' THEN
      result <= (OTHERS => '0');
    ELSIF gclk'event AND gclk='1' THEN 
      result <= mega_shift(0);
    END IF;
  END PROCESS;


END RTL;
