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


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.RISCTYPES.ALL;

ENTITY PRGRM_DECODE IS
  PORT (
    Zro_Flag,                           -- "Zero" Flag from DATA_PATH
    Carry_Flag,                         -- "Carry" Flag from DATA_PATH
    Neg_Flag                            -- "Negative" Flag from DATA_PATH
      : IN std_logic;

    CurrentState                        -- CurrentState from FSM
      : IN State_Type;

    Crnt_Instrn                         -- Current instruction under execution
    -- from Instruction Latch
      : IN std_logic_vector (31 DOWNTO 0);

    Incrmnt_PC,                         -- Increments PC (in WRITEBACK cycle)
    Ld_Brnch_Addr,                      -- Load Immediate add from Instrn Latch 
    -- into PC (in WRITEBACK cycle)
    Ld_Rtn_Addr                         -- Load Return addr from Stack into PC (in WRITEBACK cycle)
      : OUT std_logic
    );
END PRGRM_DECODE;

ARCHITECTURE RTL OF PRGRM_DECODE IS

  SIGNAL Brnch_Addr, Rtn_Addr, Take_Branch : std_logic;

BEGIN

  PROCESS (Take_Branch, CurrentState, Crnt_Instrn, Zro_Flag, Carry_Flag, Neg_Flag, Brnch_Addr, Rtn_Addr)
    VARIABLE Neg, Carry, Zro, Jmp : std_logic;
  BEGIN

    Brnch_Addr <= '0';
    Rtn_Addr   <= '0';

    --  Determine if Jmp on False or Jmp on True
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

    --  Determines which of the CONDITIONs needs to be checked and whether to jmp
    IF (Crnt_Instrn(23 DOWNTO 16) = "00000000") THEN
      Take_Branch <= Neg;
    ELSIF (Crnt_Instrn(23 DOWNTO 16) = "00000001") THEN
      Take_Branch <= Zro;
    ELSIF (Crnt_Instrn(23 DOWNTO 16) = "00000010") THEN
      Take_Branch <= Carry;
    ELSIF (Crnt_Instrn(23 DOWNTO 16) = "00111111") THEN
      Take_Branch <= Jmp;
    ELSE Take_Branch <= '0';
    END IF;

    CASE CurrentState IS
      WHEN WRITEBACK =>
        IF (Crnt_Instrn(31 DOWNTO 30) = "00") THEN 
          -- For Jmp/Call with condition check
          IF ((Crnt_Instrn(29) = '1' OR Crnt_Instrn(28) = '1' ) AND
              Take_Branch = '1') THEN 
            Brnch_Addr <= '1';
          END IF;
          -- For Return
          IF (Crnt_Instrn(27) = '1') THEN
            Rtn_Addr <= '1';
          END IF;
        END IF;
        -- If not Jmping or Rtrning the increment PC
        IF (Rtn_Addr = '1' OR Brnch_Addr = '1') THEN
          Incrmnt_PC <= '0';
        ELSE
          Incrmnt_PC <= '1';
        END IF;
      WHEN OTHERS =>
        Incrmnt_PC <= '0';
    END CASE;
  END PROCESS;

  Ld_Brnch_Addr <= Brnch_Addr;
  Ld_Rtn_Addr   <= Rtn_Addr;

END RTL;

