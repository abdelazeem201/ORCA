----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.std_logic_unsigned.all;

ENTITY PARSER IS
  PORT (
    sys_clk          : IN  std_logic;  -- 125 MHz
    pclk             : IN  std_logic;  -- 66 MHz
    sys_rst_n        : IN  std_logic;
    
    pcmd             : IN  std_logic_vector(3 DOWNTO 0);
    pcmd_valid       : IN  std_logic;

    pcmd_out         : OUT std_logic_vector(3 DOWNTO 0);
    pcmd_out_valid   : OUT std_logic;

    blender_op       : OUT std_logic_vector(3 DOWNTO 0);
    blender_clk_en   : OUT std_logic;

    context_en       : OUT std_logic;
    context_cmd      : OUT std_logic_vector(7 DOWNTO 0);
    
    fifo_read_pop    : OUT  std_logic;
    fifo_read_empty  : IN  std_logic;

    fifo_write_push  : OUT std_logic;
    fifo_write_full  : IN  std_logic;

    risc_Instrn_lo   : OUT std_logic_vector(7 DOWNTO 0);
    risc_Xecutng_Instrn_lo : IN std_logic_vector(15 DOWNTO 0);

    pci_w_mux_select : OUT std_logic_vector(1 DOWNTO 0);
    sd_w_mux_select  : OUT std_logic_vector(1 DOWNTO 0);

    parser_sd_rfifo_pop      : OUT std_logic;
    sd_rfifo_parser_empty    : IN  std_logic;
    parser_sd_wfifo_push     : OUT std_logic;
    sd_wfifo_parser_full     : IN  std_logic
  );
END PARSER;

ARCHITECTURE RTL OF PARSER IS
  SIGNAL r_pcmd                 : std_logic_vector(3 DOWNTO 0);
  SIGNAL r_pcmd_valid           : std_logic;
  SIGNAL sync_pcmd              : std_logic_vector(3 DOWNTO 0);
  SIGNAL sync_pcmd_valid        : std_logic;

  SIGNAL i_pcmd_out             : std_logic_vector(3 DOWNTO 0);
  SIGNAL i_pcmd_out_valid       : std_logic;
  SIGNAL r_pcmd_out             : std_logic_vector(3 DOWNTO 0);
  SIGNAL r_pcmd_out_valid       : std_logic;
  SIGNAL sync_pcmd_out          : std_logic_vector(3 DOWNTO 0);
  SIGNAL sync_pcmd_out_valid    : std_logic;

  SIGNAL in_bus                 : std_logic_vector(19 DOWNTO 0);
  SIGNAL i_reg                  : std_logic_vector(19 DOWNTO 0);
  SIGNAL out_bus                : std_logic_vector(19 DOWNTO 0);
  
BEGIN


  in_bus <= fifo_read_empty &
            fifo_write_full &
            risc_Xecutng_Instrn_lo &
            sd_rfifo_parser_empty &
            sd_wfifo_parser_full;

  risc_Instrn_lo <= out_bus(7 DOWNTO 0);
  blender_op <= out_bus(11 DOWNTO 8);
  fifo_read_pop <= out_bus(12);
  fifo_write_push <= out_bus(13);
  parser_sd_rfifo_pop <= out_bus(14);
  parser_sd_wfifo_push <= out_bus(15);

  context_en <= out_bus(0) AND out_bus(8);
  context_cmd <= out_bus (19 DOWNTO 16) & out_bus(11 DOWNTO 8);

  sync_to_sys : PROCESS
  BEGIN
    WAIT UNTIL sys_clk'event AND sys_clk='1';

    r_pcmd    <= sync_pcmd;
    sync_pcmd <= pcmd;
    r_pcmd_valid    <= sync_pcmd_valid;
    sync_pcmd_valid <= pcmd_valid;
    
  END PROCESS;

  -- no need to reset the data
  sync_to_pci : PROCESS
  BEGIN
    WAIT UNTIL pclk'event AND pclk='1';

    r_pcmd_out    <= sync_pcmd_out;
    sync_pcmd_out <= i_pcmd_out;
    r_pcmd_out_valid    <= sync_pcmd_out_valid;
    sync_pcmd_out_valid <= i_pcmd_out_valid;
    
  END PROCESS;

  -- primary outputs PCI domain:
  pcmd_out <= r_pcmd_out;
  pcmd_out_valid <= r_pcmd_out_valid;


  
  enable_blender: PROCESS (sys_rst_n, sys_clk, r_pcmd_valid, r_pcmd)
  BEGIN
    IF sys_rst_n = '0' THEN
      blender_clk_en <= '0';
    ELSIF  sys_clk'event AND sys_clk='1' THEN 
      blender_clk_en <= r_pcmd_valid AND r_pcmd(2);
    END IF;
  END PROCESS;

  i_reg_handler: PROCESS
  BEGIN
    WAIT UNTIL sys_clk'event AND sys_clk='1';

    FOR i IN 0 TO 18 LOOP
      i_reg(i) <= in_bus(i) XOR in_bus(i+1);
    END LOOP;
    i_reg(19) <= in_bus(0) XOR in_bus(19);
    
  END PROCESS;

  i_pcmd_handler: PROCESS (sys_rst_n, sys_clk, i_reg)
  BEGIN
    IF sys_rst_n = '0' THEN
      i_pcmd_out <= (OTHERS => '0');
      i_pcmd_out_valid <= '0';
    ELSIF sys_clk'event AND sys_clk='1' THEN 
      i_pcmd_out <= i_reg(10 DOWNTO 7) + i_reg(3 DOWNTO 0);
      i_pcmd_out_valid <= i_reg(17) XOR i_reg(13);
    END IF;
  END PROCESS;
  
  out_handler: PROCESS (sys_rst_n, sys_clk, r_pcmd_valid, r_pcmd, i_reg)
  BEGIN
    IF sys_rst_n = '0' THEN
      out_bus <= (OTHERS => '0');
    ELSIF sys_clk'event AND sys_clk='1' THEN 
      IF r_pcmd_valid = '1' THEN 
        CASE r_pcmd IS
          WHEN "0101" => out_bus <= "0000" & i_reg(19 DOWNTO 4);
          WHEN "1010" => out_bus <= "0000" & i_reg(18 DOWNTO 3);
          WHEN "1100" => out_bus <= "0000" & i_reg(17 DOWNTO 9) & i_reg(6 DOWNTO 0) ;
          WHEN "0011" => out_bus <= "0000" & i_reg(16 DOWNTO 1);
          WHEN "1001" => out_bus <= "0000" & i_reg(19 DOWNTO 10) & i_reg(5 DOWNTO 0);
          WHEN OTHERS => out_bus <= NOT ("0000" & i_reg(19 DOWNTO 4 ));
        END CASE;
      ELSE
        out_bus <= i_reg(19 DOWNTO 0);
      END IF;
    END IF;
  END PROCESS;


  Mux_selects : PROCESS(sys_rst_n, sys_clk, in_bus)
  BEGIN
    IF sys_rst_n='0' THEN
      pci_w_mux_select <= "00";
      sd_w_mux_select  <= "00";
    ELSIF sys_clk'event AND sys_clk='1' THEN

      CASE in_bus(3 DOWNTO 0) IS
        WHEN "0101" =>
          pci_w_mux_select <= "01";
          sd_w_mux_select  <= "10";
        WHEN "1010" =>
          pci_w_mux_select <= "10";
          sd_w_mux_select  <= "01";
        WHEN "0110" =>
          pci_w_mux_select <= "00";
          sd_w_mux_select  <= "11";
        WHEN "1001" =>
          pci_w_mux_select <= "11";
          sd_w_mux_select  <= "00";
        WHEN "1111" =>
          pci_w_mux_select <= "11";
          sd_w_mux_select  <= "11";
        WHEN OTHERS => 
          pci_w_mux_select <= "01";
          sd_w_mux_select  <= "01";
        END CASE;
      END IF;
    END PROCESS;

END RTL;
