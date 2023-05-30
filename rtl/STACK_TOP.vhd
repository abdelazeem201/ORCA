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

ENTITY STACK_TOP IS
  PORT (
    reset_n,                            -- Reset
    clk,                                -- Clock
    PushEnbl,                           -- Push cmd for stack
    PopEnbl                             -- Pop cmd for stack
      : IN std_logic;

    PushDataIn                          -- Data to be pushed into the stack 
      : IN std_logic_vector (11 DOWNTO 0);

    PopDataOut                          -- Data popped out of the stack
      : OUT std_logic_vector (11 DOWNTO 0);
    STACK_FULL                          -- Stack is full
      : OUT std_logic
    );
END STACK_TOP;

ARCHITECTURE STRUCT OF STACK_TOP IS

  COMPONENT STACK_FSM PORT (
    reset_n    : IN  std_logic;
    clk        : IN  std_logic;
    PushEnbl   : IN  std_logic;
    PopEnbl    : IN  std_logic;
    TOS        : OUT std_logic_vector (0 TO 2);
    STACK_FULL : OUT std_logic
    );
  END COMPONENT;

  COMPONENT STACK_MEM PORT (
    clk        : IN  std_logic;
    PushEnbl   : IN  std_logic;
    PopEnbl    : IN  std_logic;
    Stack_Full : IN  std_logic;
    TOS        : IN  std_logic_vector (0 TO 2);
    PushDataIn : IN  std_logic_vector (3 DOWNTO 0);
    PopDataOut : OUT std_logic_vector (3 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL TOS            : std_logic_vector (0 TO 2);
  SIGNAL STACK_FULL_int : std_logic;

BEGIN

  I_STACK_FSM : STACK_FSM PORT MAP (
    reset_n    => reset_n,
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    TOS        => TOS,
    STACK_FULL => STACK_FULL_int
    );

  I1_STACK_MEM : STACK_MEM PORT MAP (
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    Stack_Full => STACK_FULL_int,
    TOS        => TOS,
    PushDataIn => PushDataIn(3 DOWNTO 0),
    PopDataOut => PopDataOut(3 DOWNTO 0)
    );

  I2_STACK_MEM : STACK_MEM PORT MAP (
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    Stack_Full => STACK_FULL_int,
    TOS        => TOS,
    PushDataIn => PushDataIn(7 DOWNTO 4),
    PopDataOut => PopDataOut(7 DOWNTO 4)
    );

  I3_STACK_MEM : STACK_MEM PORT MAP (
    clk        => clk,
    PushEnbl   => PushEnbl,
    PopEnbl    => PopEnbl,
    Stack_Full => STACK_FULL_int,
    TOS        => TOS,
    PushDataIn => PushDataIn(11 DOWNTO 8),
    PopDataOut => PopDataOut(11 DOWNTO 8)
    );

  STACK_FULL <= STACK_FULL_int;

END STRUCT;
