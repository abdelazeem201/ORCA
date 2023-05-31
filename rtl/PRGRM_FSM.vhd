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

ENTITY PRGRM_FSM IS
  PORT (
    clk,                                -- CPU Clock
    reset_n                             -- CPU Reset
      : IN  std_logic;
    CurrentState                        -- Current State of FSM
      : OUT State_Type
    );
END PRGRM_FSM;

ARCHITECTURE RTL OF PRGRM_FSM IS

--    type State_Type is (RESET_STATE, FETCH_INSTR, READ_OPS, EXECUTE, WRITEBACK);
  SIGNAL Current_State, Next_State : State_Type;

BEGIN

  PROCESS (Current_State)
  BEGIN
    CASE Current_State IS
      WHEN RESET_STATE =>
        Next_State <= FETCH_INSTR;
      WHEN FETCH_INSTR =>
        Next_State <= READ_OPS;
      WHEN READ_OPS =>
        Next_State <= EXECUTE;
      WHEN EXECUTE =>
        Next_State <= WRITEBACK;
      WHEN WRITEBACK =>
        Next_State <= FETCH_INSTR;
    END CASE;
  END PROCESS;

  PROCESS(reset_n, clk, Next_State)
  BEGIN
    IF reset_n = '0' THEN
      Current_State <= RESET_STATE;
    ELSIF clk'event AND clk = '1' THEN

      Current_State <= Next_State;
    END IF;
  END PROCESS;

  CurrentState <= Current_State;

END RTL;

