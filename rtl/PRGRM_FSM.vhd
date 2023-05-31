----------------------------------------------------------------------/
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
----                                                               ----
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

