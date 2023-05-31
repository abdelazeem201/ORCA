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
USE work.RISCTYPES.ALL;

ENTITY PRGRM_CNT_TOP IS
  PORT (
    clk           : IN  std_logic;
    reset_n       : IN  std_logic;
    Crnt_Instrn   : IN  std_logic_vector (31 DOWNTO 0);  -- Current Executing Inst
    Zro_Flag,                           -- Flags from ALU or Stack
    Carry_Flag,
    Neg_Flag      : IN  std_logic;
    Return_Addr   : IN  std_logic_vector (7 DOWNTO 0);
    Current_State : OUT State_Type;     -- CurrentState from Control FSM                       
    PC            : OUT std_logic_vector (7 DOWNTO 0)    -- Program Count
    );
END PRGRM_CNT_TOP;


ARCHITECTURE STRUCT OF PRGRM_CNT_TOP IS

  COMPONENT PRGRM_FSM PORT (
    clk          : IN  std_logic;
    reset_n      : IN  std_logic;
    CurrentState : OUT State_Type
    );
  END COMPONENT;

  COMPONENT PRGRM_DECODE PORT (
    Zro_Flag      : IN  std_logic;
    Carry_Flag    : IN  std_logic;
    Neg_Flag      : IN  std_logic;
    CurrentState  : IN  State_Type;
    Crnt_Instrn   : IN  std_logic_vector (31 DOWNTO 0);
    Incrmnt_PC    : OUT std_logic;
    Ld_Brnch_Addr : OUT std_logic;
    Ld_Rtn_Addr   : OUT std_logic
    );
  END COMPONENT;

  COMPONENT PRGRM_CNT PORT (
    reset_n       : IN  std_logic;
    clk           : IN  std_logic;
    Incrmnt_PC    : IN  std_logic;
    Ld_Brnch_Addr : IN  std_logic;
    Ld_Rtn_Addr   : IN  std_logic;
    Imm_Addr      : IN  std_logic_vector (7 DOWNTO 0);
    Return_Addr   : IN  std_logic_vector (7 DOWNTO 0);
    PC            : OUT std_logic_vector (7 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL Incrmnt_PC, Ld_Brnch_Addr, Ld_Rtn_Addr : std_logic;
  SIGNAL CurrentState                           : State_Type;

BEGIN

  I_PRGRM_FSM : PRGRM_FSM PORT MAP (
    clk          => clk,
    reset_n      => reset_n,
    CurrentState => CurrentState
    );

  I_PRGRM_DECODE : PRGRM_DECODE PORT MAP (
    Zro_Flag      => Zro_Flag,
    Carry_Flag    => Carry_Flag,
    Neg_Flag      => Neg_Flag,
    CurrentState  => CurrentState,
    Crnt_Instrn   => Crnt_Instrn,
    Incrmnt_PC    => Incrmnt_PC,
    Ld_Brnch_Addr => Ld_Brnch_Addr,
    Ld_Rtn_Addr   => Ld_Rtn_Addr
    );

  I_PRGRM_CNT : PRGRM_CNT PORT MAP (
    reset_n       => reset_n,
    clk           => clk,
    Incrmnt_PC    => Incrmnt_PC,
    Ld_Brnch_Addr => Ld_Brnch_Addr,
    Ld_Rtn_Addr   => Ld_Rtn_Addr,
    Imm_Addr      => Crnt_Instrn (7 DOWNTO 0),
    Return_Addr   => Return_Addr,
    PC            => PC
    );

  Current_State <= CurrentState;

END STRUCT;
