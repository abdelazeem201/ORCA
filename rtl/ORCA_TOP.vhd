----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE work.ORCA_TYPES.ALL;

ENTITY ORCA_TOP IS
--   GENERIC (
--     sd_a_width       : integer := 10;
--     sd_dq_width      : integer := 16;
--     pci_data_width   : integer := 16
--   );
  PORT (
    sys_clk          : IN  std_logic;
    sys_2x_clk       : IN  std_logic;
    sdram_clk        : IN  std_logic;

    -- SCAN
    scan_en          : IN  std_logic;
    test_mode        : IN  std_logic;

    pci_rst_n        : IN std_logic;
    sdram_rst_n      : IN std_logic;
    sys_rst_n        : IN std_logic;
    sys_2x_rst_n     : IN std_logic;

    -- PCI Interface
    pclk             : IN  std_logic;

    pidsel           : IN  std_logic;
    pgnt_n           : IN  std_logic;

    pad_in           : IN  std_logic_vector(pci_data_width-1 DOWNTO 0);
    pad_out          : OUT std_logic_vector(pci_data_width-1 DOWNTO 0);
    pad_en           : OUT std_logic;
      
    ppar_in          : IN  std_logic;
    ppar_out         : OUT std_logic;
    ppar_en          : OUT std_logic;
    pc_be_in         : IN  std_logic_vector(3 DOWNTO 0);
    pc_be_out        : OUT std_logic_vector(3 DOWNTO 0);
    pc_be_en         : OUT std_logic;
    pframe_n_in      : IN  std_logic;
    pframe_n_out     : OUT std_logic;
    pframe_n_en      : OUT std_logic;
    ptrdy_n_in       : IN  std_logic;
    ptrdy_n_out      : OUT std_logic;
    ptrdy_n_en       : OUT std_logic;
    pirdy_n_in       : IN  std_logic;
    pirdy_n_out      : OUT std_logic;
    pirdy_n_en       : OUT std_logic;
    pdevsel_n_in     : IN  std_logic;
    pdevsel_n_out    : OUT std_logic;
    pdevsel_n_en     : OUT std_logic;
    pstop_n_in       : IN  std_logic;
    pstop_n_out      : OUT std_logic;
    pstop_n_en       : OUT std_logic;
    pperr_n_in       : IN  std_logic;
    pperr_n_out      : OUT std_logic;
    pperr_n_en       : OUT std_logic;
    pserr_n_in       : IN  std_logic;
    pserr_n_out      : OUT std_logic;
    pserr_n_en       : OUT std_logic;
    
    preq_n           : OUT std_logic;
    pm66en           : IN  std_logic;

    -- SDRAM Interface
    sd_A             : OUT std_logic_vector(sd_a_width-1 DOWNTO 0);
    sd_CK            : OUT std_logic;
    sd_CKn           : OUT std_logic;
    sd_LD            : OUT std_logic;
    sd_RW            : OUT std_logic;
    sd_BWS           : OUT std_logic_vector(1 DOWNTO 0);
    sd_DQ_in         : IN  std_logic_vector(sd_dq_width-1 DOWNTO 0);
    sd_DQ_out        : OUT std_logic_vector(sd_dq_width-1 DOWNTO 0);
    sd_DQ_en         : OUT std_logic_vector(sd_dq_width-1 DOWNTO 0)    
  );

END ORCA_TOP;

ARCHITECTURE STRUCT OF ORCA_TOP IS
  -- Design Component declarations:

  
  COMPONENT PCI_TOP
--     GENERIC (
--       pci_data_width   : integer
--     );
    PORT (
      -- PCI chip bus
      pclk              : IN  std_logic;  
      pci_rst_n         : IN  std_logic;
      pidsel            : IN  std_logic;
      pgnt_n            : IN  std_logic;
      
      pad_in            : IN  std_logic_vector(pci_data_width-1 DOWNTO 0);
      pad_out           : OUT std_logic_vector(pci_data_width-1 DOWNTO 0);
      pad_en            : OUT std_logic;
      ppar_in           : IN  std_logic;
      ppar_out          : OUT std_logic;
      ppar_en           : OUT std_logic;
      pc_be_in          : IN  std_logic_vector(3 DOWNTO 0);
      pc_be_out         : OUT std_logic_vector(3 DOWNTO 0);
      pc_be_en          : OUT std_logic;
      pframe_n_in       : IN  std_logic;
      pframe_n_out      : OUT std_logic;
      pframe_n_en       : OUT std_logic;
      ptrdy_n_in        : IN  std_logic;
      ptrdy_n_out       : OUT std_logic;
      ptrdy_n_en        : OUT std_logic;
      pirdy_n_in        : IN  std_logic;
      pirdy_n_out       : OUT std_logic;
      pirdy_n_en        : OUT std_logic;
      pdevsel_n_in      : IN  std_logic;
      pdevsel_n_out     : OUT std_logic;
      pdevsel_n_en      : OUT std_logic;
      pstop_n_in        : IN  std_logic;
      pstop_n_out       : OUT std_logic;
      pstop_n_en        : OUT std_logic;
      pperr_n_in        : IN  std_logic;
      pperr_n_out       : OUT std_logic;
      pperr_n_en        : OUT std_logic;
      pserr_n_in        : IN  std_logic;
      pserr_n_out       : OUT std_logic;
      pserr_n_en        : OUT std_logic;

      preq_n            : OUT std_logic;
      pm66en            : IN  std_logic;

      -- internal bus interface
      cmd_valid         : OUT std_logic;
      cmd               : OUT std_logic_vector(3 DOWNTO 0);
      cmd_in_valid      : IN  std_logic;
      cmd_in            : IN  std_logic_vector(3 DOWNTO 0);
      
      sys_clk           : IN  std_logic;
      sys_rst_n         : IN  std_logic;
      test_mode         : IN  std_logic;
      
      rfifo_pop         : IN  std_logic;
      rfifo_empty       : OUT std_logic;
      wfifo_push        : IN  std_logic;
      wfifo_full        : OUT std_logic;

      pci_read_data     : OUT std_logic_vector(pci_data_width*2-1 DOWNTO 0);
      pci_write_data    : IN  std_logic_vector(pci_data_width*2-1 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT SDRAM_TOP
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
    sd_A             : OUT std_logic_vector(sd_a_width-1 DOWNTO 0);
    sd_CK            : OUT std_logic;
    sd_CKn           : OUT std_logic;
    sd_LD            : OUT std_logic;
    sd_RW            : OUT std_logic;
    sd_BWS           : OUT std_logic_vector(1 DOWNTO 0);

    sd_DQ_in         : IN  std_logic_vector(sd_dq_width-1 DOWNTO 0);
    sd_DQ_out        : OUT std_logic_vector(sd_dq_width-1 DOWNTO 0);
    sd_DQ_en         : OUT std_logic_vector(sd_dq_width-1 DOWNTO 0);

    sd_sys_data_out  : OUT std_logic_vector(sd_dq_width*2-1 DOWNTO 0);
    sd_wfifo_data    : IN  std_logic_vector(sd_dq_width*2-1 DOWNTO 0);

    parser_sd_rfifo_pop   : IN  std_logic;
    parser_sd_wfifo_push  : IN  std_logic;
    sd_rfifo_parser_empty : OUT std_logic;
    sd_wfifo_parser_full  : OUT std_logic
  );
  END COMPONENT;
  
  COMPONENT PARSER
    PORT (
      sys_clk          : IN  std_logic;  -- 125 MHz
      pclk             : IN  std_logic;  -- 66/33 MHz
      sys_rst_n        : IN  std_logic;

      pcmd             : IN  std_logic_vector(3 DOWNTO 0);
      pcmd_valid       : IN  std_logic;

      pcmd_out         : OUT std_logic_vector(3 DOWNTO 0);
      pcmd_out_valid   : OUT std_logic;

      context_en       : OUT std_logic;
      context_cmd      : OUT std_logic_vector(7 DOWNTO 0);

      blender_op       : OUT std_logic_vector(3 DOWNTO 0);
      blender_clk_en   : OUT std_logic;

      fifo_read_pop    : OUT  std_logic;
      fifo_read_empty  : IN  std_logic;

      fifo_write_push  : OUT std_logic;
      fifo_write_full  : IN  std_logic;

      risc_Instrn_lo   : OUT std_logic_vector(7 DOWNTO 0);
      risc_Xecutng_Instrn_lo    : IN std_logic_vector(15 DOWNTO 0);

      pci_w_mux_select          : OUT std_logic_vector(1 DOWNTO 0);
      sd_w_mux_select           : OUT std_logic_vector(1 DOWNTO 0);

      parser_sd_rfifo_pop       : OUT std_logic;
      sd_rfifo_parser_empty     : IN  std_logic;
      parser_sd_wfifo_push      : OUT std_logic;
      sd_wfifo_parser_full      : IN  std_logic
    );
  END COMPONENT;

  COMPONENT CONTEXT_MEM
    PORT (
      sys_clk          : IN  std_logic;
      sys_rst_n        : IN  std_logic;
    
      context_en       : IN  std_logic;
      cmd              : IN  std_logic_vector(7 DOWNTO 0);

      pci_data_in      : IN  std_logic_vector(31 DOWNTO 0);
      pci_context_data : OUT std_logic_vector(31 DOWNTO 0)
    );
  END COMPONENT;

  -- This selects whether context_mem contains RAMs or not
  -- This can be used instead of configurations as is used now - see the end of
  -- the file. If done like here, vhdl elaboration is a little easier
  --for I_CONTEXT_MEM: CONTEXT_MEM use entity WORK.CONTEXT_MEM(RAMS);
  --for I_CONTEXT_MEM: CONTEXT_MEM use entity WORK.CONTEXT_MEM(NO_RAMS);
  
  COMPONENT RISC_CORE
    PORT (
      clk            	: IN std_logic;  -- 250 MHz
      Reset_n          	: IN std_logic;
      Instrn         	: IN std_logic_vector (31 DOWNTO 0);
      Xecutng_Instrn 	: OUT std_logic_vector (31 DOWNTO 0);
      EndOfInstrn    	: OUT std_logic;
      PSW            	: OUT std_logic_vector (10 DOWNTO 0);
      Rd_Instr       	: OUT std_logic;
      RESULT_DATA    	: OUT std_logic_vector (15 DOWNTO 0);
      OUT_VALID      	: OUT std_logic;
      STACK_FULL     	: OUT std_logic
    );
  END COMPONENT;
  
  COMPONENT BLENDER
    PORT (
      clk               : IN  std_logic;  -- 125 MHz
      reset_n           : IN  std_logic;
      clk_enable        : IN  std_logic;
      test_mode         : IN  std_logic;
      operation         : IN  std_logic_vector(3 DOWNTO 0);
      op1               : IN  std_logic_vector(31 DOWNTO 0);
      op2               : IN  std_logic_vector(31 DOWNTO 0);
      result            : OUT std_logic_vector(31 DOWNTO 0)
    );
  END COMPONENT;
  
  COMPONENT SD_W_MUX
    PORT (
      blender_data      : IN  std_logic_vector(31 DOWNTO 0);
      pci_read_data     : IN  std_logic_vector(31 DOWNTO 0);
      risc_result_data  : IN  std_logic_vector(31 DOWNTO 0);
      sd_w_select       : IN  std_logic_vector( 1 DOWNTO 0);
      sd_wfifo_data     : OUT std_logic_vector(31 DOWNTO 0)
    );
  END COMPONENT;
  
  COMPONENT PCI_W_MUX
    PORT (
      blender_data      : IN  std_logic_vector(31 DOWNTO 0);
      sdram_read_data   : IN  std_logic_vector(31 DOWNTO 0);
      risc_result_data  : IN  std_logic_vector(31 DOWNTO 0);
      pci_w_select      : IN  std_logic_vector( 1 DOWNTO 0);
      pci_wfifo_data    : OUT std_logic_vector(31 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL ti_hi, ti_low          : std_logic;

  SIGNAL net_pci_context_data   : std_logic_vector(31 DOWNTO 0);

  SIGNAL net_sd_sys_read_data   : std_logic_vector(31 DOWNTO 0);
  SIGNAL net_pci_sys_read_data  : std_logic_vector(31 DOWNTO 0);

  TYPE blender_result_vector IS ARRAY (0 TO 16) OF std_logic_vector(31 DOWNTO 0);
  SIGNAL net_blender_result     : blender_result_vector;
  SIGNAL net_blender_clk_en     : std_logic;
  SIGNAL net_blender_op         : std_logic_vector(3 DOWNTO 0);

  SIGNAL net_context_en         : std_logic;
  SIGNAL net_context_cmd        : std_logic_vector(7 DOWNTO 0);
  
  SIGNAL net_pci_parser_cmd             : std_logic_vector(3 DOWNTO 0);  
  SIGNAL net_pci_parser_cmd_valid       : std_logic;  
  SIGNAL net_parser_pci_cmd             : std_logic_vector(3 DOWNTO 0);  
  SIGNAL net_parser_pci_cmd_valid       : std_logic;

  SIGNAL net_parser_sd_rfifo_pop        : std_logic;
  SIGNAL net_sd_rfifo_parser_empty      : std_logic;
  SIGNAL net_parser_sd_wfifo_push       : std_logic;
  SIGNAL net_sd_wfifo_parser_full       : std_logic;

  SIGNAL net_pci_w_mux_select           : std_logic_vector(1 DOWNTO 0);
  SIGNAL net_sd_w_mux_select            : std_logic_vector(1 DOWNTO 0);

  SIGNAL net_risc_Xecutng_Instrn        : std_logic_vector(31 DOWNTO 0);  
  SIGNAL net_risc_RESULT_DATA           : std_logic_vector(15 DOWNTO 0);
  
  SIGNAL net_risc_sd_EndOfInstrn        : std_logic;
  SIGNAL net_risc_sd_PSW                : std_logic_vector(10 DOWNTO 0);
  SIGNAL net_risc_sd_Rd_Instr           : std_logic;
  SIGNAL net_risc_sd_OUT_VALID          : std_logic;
  SIGNAL net_risc_sd_STACK_FULL         : std_logic;

  SIGNAL net_sd_wfifo_data      : std_logic_vector(sd_dq_width*2-1 DOWNTO 0);

  SIGNAL net_pci_wfifo_data     : std_logic_vector(31 DOWNTO 0);

  SIGNAL net_parser_fifo_read_pop       : std_logic;
  SIGNAL net_parser_fifo_read_empty     : std_logic;
  SIGNAL net_parser_fifo_write_push     : std_logic;
  SIGNAL net_parser_fifo_write_full     : std_logic;
  SIGNAL net_parser_risc_Instrn_lo      : std_logic_vector(7 DOWNTO 0);

  SIGNAL net_risc_Instrn                : std_logic_vector(31 DOWNTO 0);

  SIGNAL temp_vector1                   : std_logic_vector(31 DOWNTO 0);
  SIGNAL temp_vector2                   : std_logic_vector(31 DOWNTO 0);

BEGIN

  ti_low <= '0';
  ti_hi  <= '1';



  I_PCI_TOP: PCI_TOP
--   GENERIC MAP (
--     pci_data_width      => pci_data_width
--   )
  PORT MAP (
      pclk              => pclk,
      pci_rst_n         => pci_rst_n,

      pidsel            => pidsel,
      pgnt_n            => pgnt_n,

      pad_in            => pad_in,
      pad_out           => pad_out,
      pad_en            => pad_en,
      
      ppar_in           => ppar_in,
      ppar_out          => ppar_out,
      ppar_en           => ppar_en,
      pc_be_in          => pc_be_in,
      pc_be_out         => pc_be_out,
      pc_be_en          => pc_be_en,
      pframe_n_in       => pframe_n_in,
      pframe_n_out      => pframe_n_out,
      pframe_n_en       => pframe_n_en,
      ptrdy_n_in        => ptrdy_n_in,
      ptrdy_n_out       => ptrdy_n_out,
      ptrdy_n_en        => ptrdy_n_en,
      pirdy_n_in        => pirdy_n_in,
      pirdy_n_out       => pirdy_n_out,
      pirdy_n_en        => pirdy_n_en,
      pdevsel_n_in      => pdevsel_n_in,
      pdevsel_n_out     => pdevsel_n_out,
      pdevsel_n_en      => pdevsel_n_en,
      pstop_n_in        => pstop_n_in,
      pstop_n_out       => pstop_n_out,
      pstop_n_en        => pstop_n_en,
      pperr_n_in        => pperr_n_in,
      pperr_n_out       => pperr_n_out,
      pperr_n_en        => pperr_n_en,
      pserr_n_in        => pserr_n_in,
      pserr_n_out       => pserr_n_out,
      pserr_n_en        => pserr_n_en,

      preq_n            => preq_n,
      pm66en            => pm66en,

      -- internal bus interface
      cmd_valid         => net_pci_parser_cmd_valid,
      cmd               => net_pci_parser_cmd,
      cmd_in_valid      => net_parser_pci_cmd_valid,
      cmd_in            => net_parser_pci_cmd,

      sys_clk           => sys_clk,
      sys_rst_n         => sys_rst_n,
      test_mode         => test_mode,

      rfifo_pop         => net_parser_fifo_read_pop,
      rfifo_empty       => net_parser_fifo_read_empty,
      wfifo_push        => net_parser_fifo_write_push,
      wfifo_full        => net_parser_fifo_write_full,

      pci_read_data     => net_pci_sys_read_data,
      pci_write_data    => net_pci_wfifo_data
      
  );

  I_PARSER: PARSER PORT MAP
  (
    sys_clk          => sys_clk,
    pclk             => pclk,
    sys_rst_n        => sys_rst_n,

    pcmd             => net_pci_parser_cmd,
    pcmd_valid       => net_pci_parser_cmd_valid,
    pcmd_out         => net_parser_pci_cmd,
    pcmd_out_valid   => net_parser_pci_cmd_valid,
    
    blender_op       => net_blender_op,
    blender_clk_en   => net_blender_clk_en,

    context_en       => net_context_en,
    context_cmd      => net_context_cmd,

    fifo_read_pop    => net_parser_fifo_read_pop,
    fifo_read_empty  => net_parser_fifo_read_empty,
    fifo_write_push  => net_parser_fifo_write_push,
    fifo_write_full  => net_parser_fifo_write_full,

    risc_Instrn_lo   => net_parser_risc_Instrn_lo,
    risc_Xecutng_Instrn_lo => net_risc_Xecutng_Instrn(15 DOWNTO 0),

    pci_w_mux_select => net_pci_w_mux_select,
    sd_w_mux_select  => net_sd_w_mux_select,

    parser_sd_rfifo_pop         => net_parser_sd_rfifo_pop,
    sd_rfifo_parser_empty       => net_sd_rfifo_parser_empty,
    parser_sd_wfifo_push        => net_parser_sd_wfifo_push,
    sd_wfifo_parser_full        => net_sd_wfifo_parser_full
  );

  I_CONTEXT_MEM: CONTEXT_MEM PORT MAP
  (

    sys_clk             => sys_clk,
    sys_rst_n           => sys_rst_n,

    context_en          => net_context_en,
    cmd                 => net_context_cmd,

    pci_data_in         => net_pci_sys_read_data,
    pci_context_data    => net_pci_context_data
  );

  net_risc_Instrn <= net_pci_context_data(31 DOWNTO 8) & net_parser_risc_Instrn_lo;
  I_RISC_CORE: RISC_CORE PORT MAP
  (
    clk            	 => sys_2x_clk,
    Reset_n          => sys_2x_rst_n,
    Instrn         	 => net_risc_Instrn,
    Xecutng_Instrn 	 => net_risc_Xecutng_Instrn,
    EndOfInstrn    	 => net_risc_sd_EndOfInstrn,
    PSW            	 => net_risc_sd_PSW,
    Rd_Instr       	 => net_risc_sd_Rd_Instr,
    RESULT_DATA    	 => net_risc_RESULT_DATA,
    OUT_VALID      	 => net_risc_sd_OUT_VALID,
    STACK_FULL     	 => net_risc_sd_STACK_FULL
  );

  BLENDERS: FOR i IN 1 TO 1 GENERATE
    I_BLENDER: BLENDER PORT MAP
      (
        clk               => sys_clk,
        reset_n           => sys_rst_n,
        clk_enable        => net_blender_clk_en,
        test_mode         => test_mode,
        operation         => net_blender_op,
        op1               => net_sd_sys_read_data,
        op2               => net_pci_context_data,
        result            => net_blender_result(i)
        );
  END GENERATE BLENDERS;

  
  -- BLENDER Muxing
  net_blender_result(0) <= net_blender_result(1);
    
  
  I_SDRAM_TOP: SDRAM_TOP
--   GENERIC MAP (
--     sd_a_width       => sd_a_width,
--     sd_dq_width      => sd_dq_width
--   )
  PORT MAP
  (
    sys_clk          => sys_clk,
    sdram_clk        => sdram_clk,
    sys_rst_n        => sys_rst_n,
    sdram_rst_n      => sdram_rst_n,
    test_mode        => test_mode,

    risc_OUT_VALID   => net_risc_sd_OUT_VALID,
    risc_STACK_FULL  => net_risc_sd_STACK_FULL,
    risc_EndOfInstrn => net_risc_sd_EndOfInstrn,
    risc_PSW         => net_risc_sd_PSW,
    risc_Rd_Instr    => net_risc_sd_Rd_Instr,

    -- interface to SDRAM
    sd_A             => sd_A,
    sd_CK            => sd_CK,
    sd_CKn           => sd_CKn,
    sd_LD            => sd_LD,
    sd_RW            => sd_RW,
    sd_BWS           => sd_BWS,

    sd_DQ_in         => sd_DQ_in,
    sd_DQ_out        => sd_DQ_out,

    -- Enable DQ for SDRAM IO PAD
    sd_DQ_en         => sd_DQ_en,

    sd_sys_data_out  => net_sd_sys_read_data,
    sd_wfifo_data    => net_sd_wfifo_data,

    parser_sd_rfifo_pop   => net_parser_sd_rfifo_pop,
    parser_sd_wfifo_push  => net_parser_sd_wfifo_push,
    sd_rfifo_parser_empty => net_sd_rfifo_parser_empty,
    sd_wfifo_parser_full  => net_sd_wfifo_parser_full
  );
  
  temp_vector1 <= net_risc_RESULT_DATA & net_risc_Xecutng_Instrn(31 DOWNTO 16);
  I_PCI_W_MUX: PCI_W_MUX PORT MAP
  (
    blender_data      => net_blender_result(0),
    sdram_read_data   => net_sd_sys_read_data,
    risc_result_data  => temp_vector1,
    pci_w_select      => net_pci_w_mux_select,
    pci_wfifo_data    => net_pci_wfifo_data
  );  

  temp_vector2 <= net_risc_RESULT_DATA & net_risc_Xecutng_Instrn(31 DOWNTO 16);
  I_SD_W_MUX: SD_W_MUX PORT MAP
  (
    blender_data      => net_blender_result(0),
    pci_read_data     => net_pci_context_data,
    risc_result_data  => temp_vector2,
    sd_w_select       => net_sd_w_mux_select,
    sd_wfifo_data     => net_sd_wfifo_data
  );  

END STRUCT;

configuration orca_config of ORCA_TOP is
  for struct
    for I_CONTEXT_MEM: CONTEXT_MEM
--      use entity WORK.CONTEXT_MEM(RAMS_16);
--      use entity WORK.CONTEXT_MEM(RAMS_8);
--      use entity WORK.CONTEXT_MEM(NO_RAMS);
      use entity WORK.CONTEXT_MEM(NO_RAMS);
    end for;
    for I_RISC_CORE: RISC_CORE
      use entity work.RISC_CORE(struct);
      for struct -- of RISC_CORE
        for I_REG_FILE: REG_FILE
--          use entity work.REG_FILE(RAMS_4);
--          use entity work.REG_FILE(RAMS_2);
--          use entity work.REG_FILE(NO_RAMS);
          use entity WORK.REG_FILE(NO_RAMS);
        end for; -- I_REG_FILE
      end for; -- struct
    end for; -- I_RISC_CORE
    for I_PCI_TOP: PCI_TOP
      use entity work.PCI_TOP(struct);
      for struct -- of PCI_TOP
        for I_PCI_READ_FIFO: PCI_FIFO
--          use entity work.PCI_FIFO(RAMS_4);
--          use entity work.PCI_FIFO(RAMS_8);
--          use entity work.PCI_FIFO(NO_RAMS);
          use entity WORK.PCI_FIFO(NO_RAMS);
        end for;
        for I_PCI_WRITE_FIFO: PCI_FIFO
--          use entity work.PCI_FIFO(RAMS_4);
--          use entity work.PCI_FIFO(RAMS_8);
--          use entity work.PCI_FIFO(NO_RAM8);
          use entity WORK.PCI_FIFO(NO_RAMS);
        end for;
      end for;
    end for; -- PCI_TOP
    for I_SDRAM_TOP: SDRAM_TOP
      use entity work.SDRAM_TOP(struct);
      for struct
        for I_SDRAM_READ_FIFO: SDRAM_FIFO
--          use entity work.SDRAM_FIFO(RAMS);
--          use entity work.SDRAM_FIFO(NO_RAMS);
          use entity WORK.SDRAM_FIFO(NO_RAMS);
        end for;
        for I_SDRAM_WRITE_FIFO: SDRAM_FIFO
--          use entity work.SDRAM_FIFO(RAMS);
--          use entity work.SDRAM_FIFO(NO_RAMS);
          use entity WORK.SDRAM_FIFO(NO_RAMS);
        end for;
      end for;
    end for; -- SDRAM_TOP
  end for; -- struct of ORCA_TOP
end orca_config;
