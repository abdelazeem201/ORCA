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
USE IEEE.std_logic_unsigned.ALL;

USE WORK.ORCA_TYPES.ALL;

ENTITY SDRAM_TOP IS
--   GENERIC (
--     sd_a_width       : integer := 10;
--     sd_dq_width      : integer := 16
--   );
  PORT (
    sys_clk             : IN  std_logic;
    sdram_clk           : IN  std_logic;
    sys_rst_n           : IN  std_logic;
    sdram_rst_n         : IN  std_logic;
    test_mode           : IN  std_logic;
    
    risc_OUT_VALID      : IN  std_logic;
    risc_STACK_FULL     : IN  std_logic;
    risc_EndOfInstrn    : IN  std_logic;
    risc_PSW            : IN  std_logic_vector(10 DOWNTO 0);
    risc_Rd_Instr       : IN  std_logic;

    -- interface to SDRAM
    sd_A             : OUT std_logic_vector(9 DOWNTO 0);
    sd_CK            : OUT std_logic;
    sd_CKn           : OUT std_logic;
    sd_LD            : OUT std_logic;
    sd_RW            : OUT std_logic;
    sd_BWS           : OUT std_logic_vector(1 DOWNTO 0);

    sd_DQ_in         : IN  std_logic_vector(15 DOWNTO 0);
    sd_DQ_out        : OUT std_logic_vector(15 DOWNTO 0);
    sd_DQ_en         : OUT std_logic_vector(15 DOWNTO 0);

    sd_sys_data_out  : OUT std_logic_vector(31 DOWNTO 0);
    sd_wfifo_data    : IN  std_logic_vector(31 DOWNTO 0);

    parser_sd_rfifo_pop   : IN  std_logic;
    parser_sd_wfifo_push  : IN  std_logic;
    sd_rfifo_parser_empty : OUT std_logic;
    sd_wfifo_parser_full  : OUT std_logic
  );

END SDRAM_TOP;

ARCHITECTURE struct OF SDRAM_TOP IS

  COMPONENT SDRAM_IF
--     GENERIC (
--       sd_a_width       : integer;
--       sd_dq_width      : integer
--     );
    PORT (
      sdram_clk        : IN  std_logic;

      sdram_rst_n      : IN  std_logic;

      risc_OUT_VALID   : IN  std_logic;
      risc_STACK_FULL  : IN  std_logic;
      risc_EndOfInstrn : IN  std_logic;
      risc_PSW         : IN  std_logic_vector(10 DOWNTO 0);
      risc_Rd_Instr    : IN  std_logic;

      -- interface to SDRAM
      sd_A             : OUT std_logic_vector(9 DOWNTO 0);
      sd_CK            : OUT std_logic;
      sd_CKn           : OUT std_logic;
      sd_LD            : OUT std_logic;
      sd_RW            : OUT std_logic;
      sd_BWS           : OUT std_logic_vector(1 DOWNTO 0);

      sd_DQ_in         : IN  std_logic_vector(15 DOWNTO 0);
      sd_DQ_out        : OUT std_logic_vector(15 DOWNTO 0);
      -- sd_Enable DQ for SDRAM IO PAD
      sd_DQ_en         : OUT std_logic_vector(15 DOWNTO 0);

      -- interface to FIFOs
      sd_wfifo_pop     : OUT std_logic;
      sd_wfifo_empty   : IN  std_logic;
      sd_rfifo_push    : OUT std_logic;
      sd_rfifo_full    : IN  std_logic;

      sd_rfifo_DQ_out  : OUT std_logic_vector(31 DOWNTO 0);
      sd_wfifo_DQ_in   : IN  std_logic_vector(31 DOWNTO 0)

    );
  END COMPONENT;
  
  COMPONENT SDRAM_FIFO
--     GENERIC (
--       fifo_data_width : integer;
--       fifo_depth      : integer
--     );
    PORT (fifo_clk_push          : IN  std_logic;
          fifo_clk_pop           : IN  std_logic;
          fifo_rst_n             : IN  std_logic;
          test_mode              : IN  std_logic;
          fifo_push_req_n        : IN  std_logic;
          fifo_pop_req_n         : IN  std_logic;
          fifo_data_in           : IN  std_logic_vector(31 DOWNTO 0);
          push_empty_fifo        : OUT std_logic;
          push_ae_fifo           : OUT std_logic;
          push_hf_fifo           : OUT std_logic;
          push_af_fifo           : OUT std_logic;
          push_full_fifo         : OUT std_logic;
          push_error_fifo        : OUT std_logic;
          pop_empty_fifo         : OUT std_logic;
          pop_ae_fifo            : OUT std_logic;
          pop_hf_fifo            : OUT std_logic;
          pop_af_fifo            : OUT std_logic;
          pop_full_fifo          : OUT std_logic;
          pop_error_fifo         : OUT std_logic;
          data_out_fifo          : OUT std_logic_vector(31 DOWNTO 0)
    );
  END COMPONENT;
  

  SIGNAL net_sd_wfifo_pop       : std_logic;
  SIGNAL net_sd_wfifo_empty     : std_logic;
  SIGNAL net_sd_rfifo_push      : std_logic;
  SIGNAL net_sd_rfifo_full      : std_logic;
  SIGNAL net_sdram_if_wDQ       : std_logic_vector(31 DOWNTO 0);
  SIGNAL net_sdram_if_rDQ       : std_logic_vector(31 DOWNTO 0);
  

BEGIN

  I_SDRAM_IF: SDRAM_IF
--   GENERIC MAP (
--     sd_a_width          => sd_a_width,
--     sd_dq_width         => sd_dq_width
--   )
  PORT MAP
  (
    sdram_clk           => sdram_clk,

    sdram_rst_n         => sdram_rst_n,

    risc_OUT_VALID      => risc_OUT_VALID,
    risc_STACK_FULL     => risc_STACK_FULL,
    risc_EndOfInstrn    => risc_EndOfInstrn,
    risc_PSW            => risc_PSW,
    risc_Rd_Instr       => risc_Rd_Instr,

    -- interface to SDRAM
    sd_A           => sd_A,
    sd_CK          => sd_CK,
    sd_CKn         => sd_CKn,
    sd_LD          => sd_LD,
    sd_RW          => sd_RW,
    sd_BWS         => sd_BWS,

    sd_DQ_in       => sd_DQ_in,
    sd_DQ_out      => sd_DQ_out,

    -- Enable DQ for SDRAM IO PAD
    sd_DQ_en       => sd_DQ_en,
    
    -- interface to FIFOs
    sd_wfifo_pop        => net_sd_wfifo_pop,
    sd_wfifo_empty      => net_sd_wfifo_empty,
    sd_rfifo_push       => net_sd_rfifo_push,
    sd_rfifo_full       => net_sd_rfifo_full,

    sd_rfifo_DQ_out     => net_sdram_if_rDQ,
    sd_wfifo_DQ_in      => net_sdram_if_wDQ
  );
  


  I_SDRAM_READ_FIFO: SDRAM_FIFO 
--   GENERIC MAP (
--     fifo_data_width     => 32,
--     fifo_depth          => 64
--   )
  PORT MAP (
    fifo_clk_push       => sdram_clk,
    fifo_clk_pop        => sys_clk,
    fifo_rst_n          => sdram_rst_n,
    test_mode           => test_mode,
    fifo_push_req_n     => net_sd_rfifo_push,
    fifo_pop_req_n      => parser_sd_rfifo_pop,
    fifo_data_in        => net_sdram_if_rDQ,
    
    push_empty_fifo     => OPEN,
    push_ae_fifo        => OPEN,
    push_hf_fifo        => OPEN,
    push_af_fifo        => OPEN,
    push_full_fifo      => net_sd_rfifo_full,
    push_error_fifo     => OPEN,
    pop_empty_fifo      => sd_rfifo_parser_empty,
    pop_ae_fifo         => OPEN,
    pop_hf_fifo         => OPEN,
    pop_af_fifo         => OPEN,
    pop_full_fifo       => OPEN,
    pop_error_fifo      => OPEN,
    data_out_fifo       => sd_sys_data_out
  );

  I_SDRAM_WRITE_FIFO: SDRAM_FIFO
--   GENERIC MAP (
--     fifo_data_width     => 32,
--     fifo_depth          => 64
--   )
  PORT MAP (
    fifo_clk_push       => sys_clk,
    fifo_clk_pop        => sdram_clk,
    fifo_rst_n          => sys_rst_n,
    test_mode           => test_mode,
    fifo_push_req_n     => parser_sd_wfifo_push,
    fifo_pop_req_n      => net_sd_wfifo_pop,
    fifo_data_in        => sd_wfifo_data,
    
    push_empty_fifo     => OPEN,
    push_ae_fifo        => OPEN,
    push_hf_fifo        => OPEN,
    push_af_fifo        => OPEN,
    push_full_fifo      => sd_wfifo_parser_full,
    push_error_fifo     => OPEN,
    pop_empty_fifo      => net_sd_wfifo_empty,
    pop_ae_fifo         => OPEN,
    pop_hf_fifo         => OPEN,
    pop_af_fifo         => OPEN,
    pop_full_fifo       => OPEN,
    pop_error_fifo      => OPEN,
    data_out_fifo       => net_sdram_if_wDQ
  );


END struct;
