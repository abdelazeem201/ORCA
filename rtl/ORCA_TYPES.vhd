----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/
--
-- This package contains constants for several ORCA blocks
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

package ORCA_TYPES is

  -- The following settings control the size of the ORCA blocks
  -- Total number of registers added: (shift_size+1) x bit_width. + the logic
  -- between the registers created by the function word_mux

  -- for BLENDER
  CONSTANT blender_shift_depth: natural := 1;

  -- for SDRAM_IF
  CONSTANT sdram_shift_depth: natural := 1;

  -- for PCI_CORE
  CONSTANT pci_shift_depth: natural := 1;

  -- Some values for ORCA_TOP
  CONSTANT pci_data_width : natural := 16;
  CONSTANT sd_a_width : natural := 10;
  CONSTANT sd_dq_width : natural := 16;
    
  -- Function declarations
  FUNCTION word_mult_8  (ein : IN std_logic_vector(15 DOWNTO 0) ) RETURN std_logic_vector;
  FUNCTION word_mult_16 (ein : IN std_logic_vector(31 DOWNTO 0) ) RETURN std_logic_vector;
  FUNCTION word_mux_16 (ein : IN std_logic_vector(15 DOWNTO 0) ) RETURN std_logic_vector;
  FUNCTION word_mux_32 (ein : IN std_logic_vector(31 DOWNTO 0) ) RETURN std_logic_vector;

end ORCA_TYPES;

package body ORCA_TYPES is

  FUNCTION word_mult_8 (ein : IN std_logic_vector(15 DOWNTO 0) ) RETURN std_logic_vector IS
    VARIABLE word     : std_logic_vector(15 DOWNTO 0);
  BEGIN
    word := ein(15 downto 8) * ein(7 downto 0);
    RETURN word;
  END;

  FUNCTION word_mult_16 (ein : IN std_logic_vector(31 DOWNTO 0) ) RETURN std_logic_vector IS
    VARIABLE word     : std_logic_vector(31 DOWNTO 0);
  BEGIN
    word := ein(31 downto 16) * ein(15 downto 0);
    RETURN word;
  END;

  FUNCTION word_mux_16 (ein : IN std_logic_vector(15 DOWNTO 0) ) RETURN std_logic_vector IS
    VARIABLE word     : bit_vector(15 DOWNTO 0);
    VARIABLE rol_word : bit_vector(15 DOWNTO 0);
    VARIABLE bv_ein   : bit_vector(15 DOWNTO 0);
  BEGIN

    bv_ein := to_bitvector(ein);
    FOR i IN 0 TO 15 LOOP
      rol_word := bv_ein ROL i;
      FOR n IN 0 TO 15 LOOP
        word(i) := rol_word(n) XOR word(i);
      END LOOP;
    END LOOP;

    RETURN to_stdlogicvector(word);
  END;

  FUNCTION word_mux_32 (ein : IN std_logic_vector(31 DOWNTO 0) ) RETURN std_logic_vector IS
    VARIABLE word     : bit_vector(31 DOWNTO 0);
    VARIABLE rol_word : bit_vector(31 DOWNTO 0);
    VARIABLE bv_ein   : bit_vector(31 DOWNTO 0);
  BEGIN

    bv_ein := to_bitvector(ein);
    FOR i IN 0 TO 31 LOOP
      rol_word := bv_ein ROL i;
      FOR n IN 0 TO 31 LOOP
        word(i) := rol_word(n) XOR word(i);
      END LOOP;
    END LOOP;

    RETURN to_stdlogicvector(word);
  END;


end ORCA_TYPES;

