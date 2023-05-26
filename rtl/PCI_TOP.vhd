----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY PCI_TOP IS
--   GENERIC (
--     pci_data_width   : integer := 16
--   );
  PORT (
      -- PCI chip bus
      pclk              : IN  std_logic;  
      pci_rst_n         : IN  std_logic;
      pidsel            : IN  std_logic;
      pgnt_n            : IN  std_logic;
      
      pad_in            : IN  std_logic_vector(15 DOWNTO 0);
      pad_out           : OUT std_logic_vector(15 DOWNTO 0);
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

      pci_read_data     : OUT std_logic_vector(31 DOWNTO 0);
      pci_write_data    : IN  std_logic_vector(31 DOWNTO 0)
      
  );

END PCI_TOP;
      

ARCHITECTURE STRUCT OF PCI_TOP IS
  -- Design Component declarations:

COMPONENT PCI_CORE
--     GENERIC (
--       pci_data_width   : integer
--     );
    PORT (
      -- PCI chip bus
      pclk              : IN  std_logic;  
      pci_rst_n         : IN  std_logic;
      pidsel            : IN  std_logic;
      pgnt_n            : IN  std_logic;
      
      pad_in            : IN  std_logic_vector(15 DOWNTO 0);
      pad_out           : OUT std_logic_vector(15 DOWNTO 0);
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
      read_data         : OUT std_logic_vector(31 DOWNTO 0);
      write_data        : IN  std_logic_vector(31 DOWNTO 0);

      read_push         : OUT std_logic;
      read_full         : IN  std_logic;

      write_pop         : OUT std_logic;
      write_empty       : IN  std_logic;

      cmd_valid         : OUT std_logic;
      cmd               : OUT std_logic_vector(3 DOWNTO 0);

      cmd_in_valid      : IN  std_logic;
      cmd_in            : IN  std_logic_vector(3 DOWNTO 0)
      
    );
  END COMPONENT;

  COMPONENT PCI_FIFO
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
  

  SIGNAL net_pci_read_data      : std_logic_vector(31 DOWNTO 0);
  SIGNAL net_pci_write_data     : std_logic_vector(31 DOWNTO 0);
  SIGNAL net_pci_read_push      : std_logic;
  SIGNAL net_pci_write_pop      : std_logic;
  SIGNAL net_pci_write_empty    : std_logic;
  SIGNAL net_pci_read_full              : std_logic;
  SIGNAL ti_hi, ti_low          : std_logic;




BEGIN

  ti_low <= '0';
  ti_hi  <= '1';


  I_PCI_CORE: PCI_CORE
--   GENERIC MAP (
--     pci_data_width => pci_data_width
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
      read_data         => net_pci_read_data,
      write_data        => net_pci_write_data,

      read_push         => net_pci_read_push,
      read_full         => net_pci_read_full,

      write_pop         => net_pci_write_pop,
      write_empty       => net_pci_write_empty,

      cmd_valid         => cmd_valid,
      cmd               => cmd,

      cmd_in_valid      => cmd_in_valid,
      cmd_in            => cmd_in
  );
  

  I_PCI_READ_FIFO: PCI_FIFO
--   GENERIC MAP (
--     fifo_data_width     => pci_data_width*2,
--     fifo_depth          => 32
--   )
  PORT MAP
  (
    fifo_clk_push       => pclk,
    fifo_clk_pop        => sys_clk,
    fifo_rst_n          => pci_rst_n,
    test_mode           => test_mode,
    fifo_push_req_n     => net_pci_read_push,
    fifo_pop_req_n      => rfifo_pop,
    fifo_data_in        => net_pci_read_data,
    
    push_empty_fifo     => OPEN,
    push_ae_fifo        => OPEN,
    push_hf_fifo        => OPEN,
    push_af_fifo        => OPEN,
    push_full_fifo      => net_pci_read_full,
    push_error_fifo     => OPEN,
    pop_empty_fifo      => rfifo_empty,
    pop_ae_fifo         => OPEN,
    pop_hf_fifo         => OPEN,
    pop_af_fifo         => OPEN,
    pop_full_fifo       => OPEN,
    pop_error_fifo      => OPEN,
    data_out_fifo       => pci_read_data
  );

  I_PCI_WRITE_FIFO: PCI_FIFO
--   GENERIC MAP (
--     fifo_data_width     => pci_data_width*2,
--     fifo_depth          => 32
--   )
  PORT MAP
  (
    fifo_clk_push       => sys_clk,
    fifo_clk_pop        => pclk,
    fifo_rst_n          => sys_rst_n,
    test_mode           => test_mode,
    fifo_push_req_n     => wfifo_push,
    fifo_pop_req_n      => net_pci_write_pop,
    fifo_data_in        => pci_write_data,
    
    push_empty_fifo     => OPEN,
    push_ae_fifo        => OPEN,
    push_hf_fifo        => OPEN,
    push_af_fifo        => OPEN,
    push_full_fifo      => wfifo_full,
    push_error_fifo     => OPEN,
    pop_empty_fifo      => net_pci_write_empty,
    pop_ae_fifo         => OPEN,
    pop_hf_fifo         => OPEN,
    pop_af_fifo         => OPEN,
    pop_full_fifo       => OPEN,
    pop_error_fifo      => OPEN,
    data_out_fifo       => net_pci_write_data
  );
  
END STRUCT;
