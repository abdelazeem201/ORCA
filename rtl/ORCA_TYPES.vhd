----------------------------------------------------------------------/
----                                                               ----
----  The data contained in the file is created for educational    ---- 
----  and training purposes only and is  not recommended           ----
----  for fabrication                                              ----
----                                                               ----
----------------------------------------------------------------------/
----                                                               ----
----  Copyright (C) 2013 Synopsys, Inc.                            ----
----                                                               ----
----------------------------------------------------------------------/
----                                                               ----
----  The 32/28nm Generic Library ("Library") is unsupported       ----    
----  Confidential Information of Synopsys, Inc. ("Synopsys")      ----    
----  provided to you as Documentation under the terms of the      ----    
----  End User Software License Agreement between you or your      ----    
----  employer and Synopsys ("License Agreement") and you agree    ----    
----  not to distribute or disclose the Library without the        ----    
----  prior written consent of Synopsys. The Library IS NOT an     ----    
----  item of Licensed Software or Licensed Product under the      ----    
----  License Agreement.  Synopsys and/or its licensors own        ----    
----  and shall retain all right, title and interest in and        ----    
----  to the Library and all modifications thereto, including      ----    
----  all intellectual property rights embodied therein. All       ----    
----  rights in and to any Library modifications you make are      ----    
----  hereby assigned to Synopsys. If you do not agree with        ----    
----  this notice, including the disclaimer below, then you        ----    
----  are not authorized to use the Library.                       ----    
----                                                               ----  
----                                                               ----      
----  THIS LIBRARY IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN   ----
----  "AS IS" BASIS, WITH NO INTELLECUTAL PROPERTY                 ----
----  INDEMNIFICATION AND NO SUPPORT. ANY EXPRESS OR IMPLIED       ----
----  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED       ----
----  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR   ----
----  PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS    ----
----  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,     ----
----  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT      ----
----  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;     ----
----  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)     ----
----  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN    ----
----  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE    ----
----  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS      ----
----  DOCUMENTATION, EVEN IF ADVISED OF THE POSSIBILITY OF         ----
----  SUCH DAMAGE.                                                 ---- 		
----                                                               ----  
----------------------------------------------------------------------- 


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

