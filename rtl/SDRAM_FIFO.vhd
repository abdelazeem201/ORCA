----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/
 


library IEEE,DWARE,DW06;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE DWARE.DW_Foundation_arith.ALL;
USE DWARE.DW_Foundation_comp_arith.ALL;

ENTITY SDRAM_FIFO IS
--   GENERIC (
--     fifo_data_width : integer := 32;
--     fifo_depth      : integer := 64
--   );
  PORT (fifo_clk_push          : IN  std_logic;
        fifo_clk_pop           : IN  std_logic;
        fifo_rst_n             : IN  std_logic;
        test_mode              : IN  std_logic;
        fifo_push_req_n        : IN  std_logic;
        fifo_pop_req_n         : IN  std_logic;
        fifo_data_in           : IN  std_logic_vector(32-1 DOWNTO 0);
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
        data_out_fifo          : OUT std_logic_vector(32-1 DOWNTO 0)
        );
END SDRAM_FIFO;


ARCHITECTURE RAMS OF SDRAM_FIFO IS

  constant fifo_depth: integer := 64;

  COMPONENT ram32x64
    PORT (A1   : in  std_logic_vector(bit_width(fifo_depth)-1 downto 0);
          A2   : in  std_logic_vector(bit_width(fifo_depth)-1 downto 0);
          CE1  : in std_logic;
          CE2  : in std_logic;
          WEB1 : in std_logic;
          WEB2 : in std_logic;
          OEB1 : in std_logic;
          OEB2 : in std_logic;
          CSB1 : in std_logic;
          CSB2 : in std_logic;
          I1   : in  std_logic_vector(32-1 downto 0);
          I2   : in  std_logic_vector(32-1 downto 0);
          O1   : out std_logic_vector(32-1 downto 0);
          O2   : out std_logic_vector(32-1 downto 0)
         );
  END COMPONENT;

  SIGNAL ti_hi, ti_low : std_logic;
  SIGNAL we_n          : std_logic;
  SIGNAL wr_addr       : std_logic_vector(bit_width(fifo_depth)-1 DOWNTO 0);
  SIGNAL rd_addr       : std_logic_vector(bit_width(fifo_depth)-1 DOWNTO 0);
  SIGNAL data_in       : std_logic_vector(32-1 DOWNTO 0);
  SIGNAL data_out      : std_logic_vector(32-1 DOWNTO 0);
  SIGNAL bus_hi        : std_logic_vector(32-1 DOWNTO 0);

BEGIN -- RAMS

  ti_hi <= '1';
  ti_low <= '0';
  bus_hi <= (OTHERS => '1');

-- Design requires more speed than the default RPL
-- architecture so the CL2 architecture will be selected
-- pragma dc_script_begin
-- set_implementation cl2 {SD_FIFO_CTL}
-- pragma dc_script_end
-- Fifoance of DW_asymfifo_s2_sf
  SD_FIFO_CTL : DW_fifoctl_s2_sf
    GENERIC MAP (depth          => fifo_depth,
                 push_ae_lvl    => 2,
                 push_af_lvl    => 2,
                 pop_ae_lvl     => 2,
                 pop_af_lvl     => 2,
                 err_mode       => 0,
                 push_sync      => 1,
                 pop_sync       => 1,
                 rst_mode       => 0
                 )
    
    PORT MAP (
              clk_push   => fifo_clk_push,
              clk_pop    => fifo_clk_pop,
              rst_n      => fifo_rst_n,
              push_req_n => fifo_push_req_n,
              pop_req_n  => fifo_pop_req_n,

              we_n       => we_n,
              push_empty => push_empty_fifo,
              push_ae    => push_ae_fifo,
              push_hf    => push_hf_fifo,
              push_af    => push_af_fifo,
              push_full  => push_full_fifo,
              push_error => push_error_fifo,
              pop_empty  => pop_empty_fifo,
              pop_ae     => pop_ae_fifo,
              pop_hf     => pop_hf_fifo,
              pop_af     => pop_af_fifo,
              pop_full   => pop_full_fifo,
              pop_error  => pop_error_fifo,

              wr_addr    => wr_addr,
              rd_addr    => rd_addr,
              push_word_count => open,
              pop_word_count => open,
              test => test_mode

              );

  data_in  <= fifo_data_in;
  data_out_fifo <= data_out;
  
  SD_FIFO_RAM : ram32x64
    PORT MAP (
      A1   => wr_addr,
      CE1  => fifo_clk_push,
      WEB1 => we_n,
      OEB1 => ti_hi,
      CSB1 => ti_low,
      I1   => data_in,
      O1   => open,
      
      A2   => rd_addr,
      CE2  => fifo_clk_pop,
      WEB2 => ti_hi,
      OEB2 => ti_low,
      CSB2 => ti_low,
      I2   => bus_hi,
      O2   => data_out
    );
  
end RAMS;

ARCHITECTURE NO_RAMS OF SDRAM_FIFO IS

  constant reg_depth: integer := 8;

  SIGNAL we_n          : std_logic;
  SIGNAL wr_addr       : std_logic_vector(bit_width(reg_depth)-1 DOWNTO 0);
  SIGNAL rd_addr       : std_logic_vector(bit_width(reg_depth)-1 DOWNTO 0);
  SIGNAL data_in       : std_logic_vector(32-1 DOWNTO 0);
  SIGNAL data_out      : std_logic_vector(32-1 DOWNTO 0);
  SIGNAL data_out_sync : std_logic_vector(32-1 DOWNTO 0);

  type regfile_type is array (0 to reg_depth-1) of std_logic_vector(32-1 downto 0);
  signal reg_array : regfile_type; 

begin -- NO_RAMS


  SD_FIFO_CTL : DW_fifoctl_s2_sf
    GENERIC MAP (depth          => reg_depth,
                 push_ae_lvl    => 2,
                 push_af_lvl    => 2,
                 pop_ae_lvl     => 2,
                 pop_af_lvl     => 2,
                 err_mode       => 0,
                 push_sync      => 1,
                 pop_sync       => 1,
                 rst_mode       => 0
                 )
    
    PORT MAP (
              clk_push   => fifo_clk_push,
              clk_pop    => fifo_clk_pop,
              rst_n      => fifo_rst_n,
              push_req_n => fifo_push_req_n,
              pop_req_n  => fifo_pop_req_n,

              we_n       => we_n,
              push_empty => push_empty_fifo,
              push_ae    => push_ae_fifo,
              push_hf    => push_hf_fifo,
              push_af    => push_af_fifo,
              push_full  => push_full_fifo,
              push_error => push_error_fifo,
              pop_empty  => pop_empty_fifo,
              pop_ae     => pop_ae_fifo,
              pop_hf     => pop_hf_fifo,
              pop_af     => pop_af_fifo,
              pop_full   => pop_full_fifo,
              pop_error  => pop_error_fifo,

              wr_addr    => wr_addr,
              rd_addr    => rd_addr,
              push_word_count => open,
              pop_word_count => open,
              test => test_mode

              );

  data_in  <= fifo_data_in;
  data_out_fifo <= data_out;

  -- reg_file write
  process (fifo_rst_n, reg_array, fifo_clk_push, data_in)
  begin
    if fifo_rst_n='0' then
      for i in 0 to reg_depth-1 loop
        reg_array(i) <= (others => '0');
      end loop;
    
    elsif fifo_clk_push'event and fifo_clk_push='1' then
      if we_n = '0' then
        reg_array(conv_integer(unsigned(wr_addr))) <= data_in;
      else
        reg_array(conv_integer(unsigned(wr_addr))) <= reg_array(conv_integer(unsigned(wr_addr)));
      end if;
    end if;
  end process;
  
  -- reg_file read
  process
  begin
    wait until fifo_clk_pop'event and fifo_clk_pop='1';

    data_out_sync <= reg_array(conv_integer(unsigned(rd_addr)));
    data_out <= data_out_sync;
    
  end process;
 
end NO_RAMS;
