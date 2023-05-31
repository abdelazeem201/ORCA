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


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_signed.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY PRGRM_CNT IS
  PORT (
    reset_n,                            -- Reset for the PC
    clk,                                -- CPU Clock
    Incrmnt_PC,                         -- Increment PC
    Ld_Brnch_Addr,                      -- Load Jmp/Call Addr from instruction
    Ld_Rtn_Addr                         -- Load Return Addr
      : IN std_logic;
    Imm_Addr,                           -- Immediate Addr for Jmp/Call
    Return_Addr                         -- Return addr from Stack
      : IN std_logic_vector (7 DOWNTO 0);

    PC                                  -- Addr of instruction to be fetched in
    -- the next Fetch Cycle
      : OUT std_logic_vector (7 DOWNTO 0)
    );

END PRGRM_CNT;

ARCHITECTURE RTL OF PRGRM_CNT IS

  SIGNAL PCint : std_logic_vector (7 DOWNTO 0);

BEGIN

  PROCESS (reset_n, clk, PCint, Return_Addr, Imm_Addr)
  BEGIN
    IF reset_n = '0' THEN
      PCint <= "00000000";
    ELSIF clk'event AND clk = '1' THEN
      IF Incrmnt_PC = '1' THEN          -- Occurs in WRITEBACK cycle
        PCint <= unsigned(PCint) + unsigned ' ("001");
      ELSIF (Ld_Rtn_Addr = '1') THEN    -- Occurs in WRITEBACK cycle
        PCint <= Return_Addr;
      ELSIF (Ld_Brnch_Addr = '1') THEN  -- Occurs in WRITEBACK cycle
        PCint <= Imm_Addr;
      END IF;
    END IF;
  END PROCESS;

  PC <= PCint;

END RTL;
