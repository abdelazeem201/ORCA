----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
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


--------------------------------------------------------------------
--                                                                --
--              1995, Synopsys (India) Pvt Ltd                    --
--                                                                --
--                 Entity : RISCTYPES.vhd                         --
--                                                                --
--                Project : RISC CPU                              --
--                                                                --
--                Authors : Hemant Mallapur                       --
--                                                                --
--                   Date : 25th August 1995                      --
--                                                                --
--               Function :                                       --
--                                                                --
--------------------------------------------------------------------
library Synopsys;
    Use Synopsys.attributes.all;
library IEEE;
   use IEEE.std_logic_1164.all;
   use IEEE.std_logic_arith.all;

package RISCTYPES is

    -- constants defining OPCODE types
    constant OP_ADD : std_logic_vector(5 downto 0) := "000000";
    constant OP_ADD_PLUS_ONE : std_logic_vector(5 downto 0) := "000001";
    constant OP_A : std_logic_vector(5 downto 0) := "000010";
    constant OP_A_PLUS_ONE : std_logic_vector(5 downto 0) := "000011";
    constant OP_AND : std_logic_vector(5 downto 0) := "010001";
    constant OP_NOT_A_AND_B : std_logic_vector(5 downto 0) := "010010";
    constant OP_B : std_logic_vector(5 downto 0) := "010011";
    constant OP_NOT_A_AND_NOT_B : std_logic_vector(5 downto 0) := "011000";
    constant OP_A_XNOR_B : std_logic_vector(5 downto 0) := "011001";
    constant OP_NOT_A : std_logic_vector(5 downto 0) := "011010";
    constant OP_NOT_A_OR_B : std_logic_vector(5 downto 0) := "011011";
    constant OP_SUB_MINUS_ONE : std_logic_vector(5 downto 0) := "000100";
    constant OP_SUB : std_logic_vector(5 downto 0) := "000101";
    constant OP_A_MINUS_ONE : std_logic_vector(5 downto 0) := "000110";
    constant OP_A_AND_NOT_B : std_logic_vector(5 downto 0) := "010100";
    constant OP_A_XOR_B : std_logic_vector(5 downto 0) :=     "010110";
    constant OP_A_OR_B : std_logic_vector(5 downto 0) := "010111";
    constant OP_NOT_B : std_logic_vector(5 downto 0) := "011100";
    constant OP_A_OR_NOT_B : std_logic_vector(5 downto 0) := "011101";
    constant OP_NAND : std_logic_vector(5 downto 0) := "011110";
    constant OP_JTRUE : std_logic_vector(5 downto 0) := "100000";
    constant OP_JFALSE : std_logic_vector(5 downto 0) := "100010";
    constant OP_HALT : std_logic_vector(5 downto 0) := "111111";
    constant OP_CALL: std_logic_vector(5 downto 0) := "010000";
    constant OP_RET : std_logic_vector(5 downto 0) := "001000";
    constant OP_LDR : std_logic_vector(5 downto 0) := "001001";

-- Hemant added
    constant OP_ALL_ZEROS : std_logic_vector(5 downto 0) := "010000";
    constant OP_A_AND_B : std_logic_vector(5 downto 0) := "010001";
    constant OP_notA_AND_B : std_logic_vector(5 downto 0) := "010010";
  --constant OP_B : std_logic_vector(5 downto 0) := "010011";
    constant OP_notA_AND_notB : std_logic_vector(5 downto 0) := "011000";
  --constant OP_A_XNOR_B : std_logic_vector(5 downto 0) := "011001";
    constant OP_notA : std_logic_vector(5 downto 0) := "011010";
    constant OP_notA_OR_B : std_logic_vector(5 downto 0) := "011011";
    constant OP_A_AND_notB : std_logic_vector(5 downto 0) := "010100";

  --Same operation as OP_A
    constant OP_Ap : std_logic_vector(5 downto 0) := "000111";  
    constant OP_App : std_logic_vector(5 downto 0) := "010101"; 

  --constant OP_A_XOR_B : std_logic_vector(5 downto 0) := "010110";
  --constant OP_A_OR_B : std_logic_vector(5 downto 0) := "010111";
    constant OP_notB : std_logic_vector(5 downto 0) := "011100";
    constant OP_A_OR_notB : std_logic_vector(5 downto 0) := "011101";
    constant OP_A_NAND_B : std_logic_vector(5 downto 0) := "011110";
    constant OP_ALL_ONES : std_logic_vector(5 downto 0) := "011111";
    constant IWIDTH : integer := 32;
    constant CODE_MEM_DEPTH : integer := 256;

-- Anupam added for outputting the result at RISC_TOP level
    constant OP_DATA_OUT : std_logic_vector(5 downto 0) := "000001";


 -- Boolean variable to STD_LOGIC variable conversion function
 function ToSig (bool : BOOLEAN ) return std_logic;

-- Added for Control_FSM
     type State_Type is (RESET_STATE, FETCH_INSTR, READ_OPS, EXECUTE, WRITEBACK);

 end RISCTYPES;

 package body RISCTYPES is

 function ToSig (bool : BOOLEAN ) return std_logic is
 variable sig : std_logic;
 begin
     if (bool) then
         sig := '1';
     else
         sig := '0';
     end if;
     return sig;
 end ToSig;

 end RISCTYPES;
