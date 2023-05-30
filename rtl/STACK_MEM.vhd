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
USE IEEE.std_logic_signed.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY STACK_MEM IS
  PORT (
    clk,                                -- Clock
    PushEnbl,                           -- Push cmd for stack
    PopEnbl,                            -- Pop cmd for stack
    Stack_Full                          -- Stack is full flag      
      : IN std_logic;

    TOS : IN std_logic_vector (0 TO 2);

    PushDataIn                          -- Data to be pushed into the stack 
      : IN std_logic_vector (3 DOWNTO 0);

    PopDataOut                          -- Data popped out of the stack
      : OUT std_logic_vector (3 DOWNTO 0)
    );
END STACK_MEM;

ARCHITECTURE RTL OF STACK_MEM IS

  TYPE   Mem IS ARRAY (0 TO 7) OF std_logic_vector (3 DOWNTO 0);
  SIGNAL Stack_Mem   : Mem;
  SIGNAL Pop_Address : std_logic_vector (0 TO 2);

BEGIN
  -- Generate Correct Address for Pop
  PROCESS(Stack_Full, TOS)
  BEGIN
    IF (Stack_Full = '1') THEN
      Pop_Address <= TOS;
    ELSE
      Pop_Address <= TOS - '1';
    END IF;
  END PROCESS;

  -- Stack Memory writes; described as a set of registers (edge sensitive)
  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';
    IF(PushEnbl = '1') THEN             -- {
      Stack_Mem(conv_integer(unsigned(TOS))) <= PushDataIn;
    END IF;  -- }
  END PROCESS;

  -- Stack Memory reads; the output is latched every clock edge
  PROCESS
  BEGIN
    WAIT UNTIL clk'event AND clk = '1';
    IF(PopEnbl = '1') THEN
      PopDataOut <= Stack_Mem(conv_integer(unsigned(Pop_Address)));
    END IF;
  END PROCESS;

END RTL;
