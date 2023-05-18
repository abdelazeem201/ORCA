----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
----------------------------------------------------------------------/

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

USE WORK.ORCA_TYPES.ALL;

ENTITY PCI_CORE IS
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

END PCI_CORE;

ARCHITECTURE RTL OF PCI_CORE IS

  SIGNAL d_in_p_bus   : std_logic_vector(10 DOWNTO 0);
  SIGNAL d_out_p_bus  : std_logic_vector(22 DOWNTO 0);
  SIGNAL d_in_i_bus   : std_logic_vector( 6 DOWNTO 0);
  SIGNAL d_out_i_bus  : std_logic_vector( 6 DOWNTO 0);

  SIGNAL i_pad_en     : std_logic;
  SIGNAL i_pc_be_en   : std_logic;

  TYPE   data_page IS ARRAY (0 TO pci_shift_depth) OF std_logic_vector(15 DOWNTO 0);
  SIGNAL mega_shift   : data_page;
  SIGNAL pad_out_buf  : std_logic_vector(15 DOWNTO 0);

BEGIN



  d_in_p_bus <= pidsel & 
                pgnt_n &      
                ppar_in &
                pframe_n_in &
                ptrdy_n_in &
                pirdy_n_in &
                pdevsel_n_in &
                pstop_n_in &
                pperr_n_in &
                pserr_n_in &
                pm66en;

  d_in_i_bus <= read_full &
                write_empty &
                cmd_in_valid &
                cmd_in;

  i_pad_en        <= d_out_p_bus(0);
  
  ppar_out      <= d_out_p_bus(1);
  ppar_en       <= d_out_p_bus(2);
  i_pc_be_en    <= d_out_p_bus(3);
  pframe_n_out  <= d_out_p_bus(4);
  pframe_n_en   <= d_out_p_bus(5);
  ptrdy_n_out   <= d_out_p_bus(6);
  ptrdy_n_en    <= d_out_p_bus(7);
  pirdy_n_out   <= d_out_p_bus(8);
  pirdy_n_en    <= d_out_p_bus(9);
  pdevsel_n_out <= d_out_p_bus(10);
  pdevsel_n_en  <= d_out_p_bus(11);
  pstop_n_out   <= d_out_p_bus(12);
  pstop_n_en    <= d_out_p_bus(13);
  pperr_n_out   <= d_out_p_bus(14);
  pperr_n_en    <= d_out_p_bus(15);
  pserr_n_out   <= d_out_p_bus(16);
  pserr_n_en    <= d_out_p_bus(17);
  preq_n        <= d_out_p_bus(18);
  pc_be_out     <= d_out_p_bus(22 DOWNTO 19);

  read_push     <= d_out_i_bus(0);
  write_pop     <= d_out_i_bus(1);
  cmd_valid     <= d_out_i_bus(2);
  cmd           <= d_out_i_bus(6 DOWNTO 3);

  pad_enable: PROCESS (pci_rst_n, pclk, i_pad_en)
  BEGIN
    IF pci_rst_n = '0' THEN
      pad_en <= '0';
    ELSIF pclk'event AND pclk='1' THEN
      pad_en <= NOT i_pad_en;
    END IF;
  END PROCESS;
  
  pbe_enable: PROCESS (pci_rst_n, pclk, i_pc_be_en)
  BEGIN
    IF pci_rst_n = '0' THEN
      pc_be_en <= '0';
    ELSIF pclk'event AND pclk='1' THEN
      pc_be_en <= NOT i_pc_be_en;
    END IF;
  END PROCESS;
  
  data_in: PROCESS(pc_be_in, pad_in)
    VARIABLE pci_data_width, n3, n2, n1, n0 : integer;
  BEGIN

    pci_data_width := 16;
    n3 := pci_data_width*2;
    n2 := pci_data_width*2/4*3;
    n1 := pci_data_width;
    n0 := pci_data_width/2;

    read_data <= (OTHERS => '0');
    CASE pc_be_in IS
      WHEN "1100" => read_data(n3-1 DOWNTO n1) <= pad_in;
      WHEN "0011" => read_data(n1-1 DOWNTO 0) <= pad_in;
      WHEN "1010" =>
        read_data(n3-1 DOWNTO n2) <= pad_in(n1-1 DOWNTO n0);
        read_data(n1-1 DOWNTO n0) <= pad_in(n0-1 DOWNTO 0);
      WHEN "0101" => 
        read_data(n2-1 DOWNTO n1) <= pad_in(n1-1 DOWNTO n0);
        read_data(n0-1 DOWNTO 0)  <= pad_in(n0-1 DOWNTO 0);
      WHEN OTHERS => 
        read_data <= (OTHERS => '0');
    END CASE;
    
  END PROCESS;
                                  
  p_out_bus: PROCESS(pci_rst_n, pclk, d_in_i_bus)
  BEGIN
    IF pci_rst_n = '0' THEN
      d_out_p_bus <= (OTHERS => '0');
    ELSIF pclk'event AND pclk='1' THEN
      CASE d_in_i_bus IS
        WHEN "0101010" => d_out_p_bus <= "10101010101010101010101";
        WHEN "1110111" => d_out_p_bus <= "01010101111111010101101";
        WHEN "0111111" => d_out_p_bus <= "01000111010101110101101";
        WHEN "1111111" => d_out_p_bus <= "01000101010101010111101";
        WHEN "1010111" => d_out_p_bus <= "01000111110111011101101";
        WHEN "1001001" => d_out_p_bus <= "01000101010111010101101";
        WHEN "1000001" => d_out_p_bus <= "01000101010111111111101";
        WHEN "1011001" => d_out_p_bus <= "01001101010101110101101";
        WHEN "1110101" => d_out_p_bus <= "01000101010101010101101";
        WHEN "1010101" => d_out_p_bus <= "01010101111111111101101";
        WHEN OTHERS =>    d_out_p_bus <= write_data(18 DOWNTO 0) & cmd_in;
      END CASE;
    END IF;
  END PROCESS;

  p_in_bus: PROCESS(pci_rst_n, pclk, d_in_p_bus)
  BEGIN
    IF pci_rst_n = '0' THEN
      d_out_i_bus <= (OTHERS => '0');
    ELSIF pclk'event AND pclk='1' THEN
      CASE d_in_p_bus IS
        WHEN "10100101010" => d_out_i_bus <= "1010101";
        WHEN "11111101110" => d_out_i_bus <= "0101010";
        WHEN "10101101111" => d_out_i_bus <= "1101101";
        WHEN "10110111010" => d_out_i_bus <= "1010010";
        WHEN "00100101000" => d_out_i_bus <= "1010111";
        WHEN "00100001000" => d_out_i_bus <= "1100011";
        WHEN "10101011111" => d_out_i_bus <= "0011100";
        WHEN OTHERS        => d_out_i_bus <= pad_in(6 DOWNTO 0);
      END CASE;
    END IF;
  END PROCESS;



  write_proc: PROCESS (pclk, pci_rst_n, mega_shift, write_data)
  BEGIN
    IF pci_rst_n = '0' THEN
      -- Don't really need to reset these if this were the real world, but this just makes the
      -- synthesis of a reset network more interesting ;-)
      mega_shift <= (OTHERS => (OTHERS => '0') );
      pad_out_buf <= (OTHERS => '0');
                 
    ELSIF pclk'event AND pclk='1' THEN 

      IF cmd_in(1) = '1' THEN
        mega_shift(pci_shift_depth) <= write_data(31 DOWNTO 16);
      ELSE
        mega_shift(pci_shift_depth) <= write_data(15 DOWNTO 0);
      END IF;

      pad_out_buf <= mega_shift(0);

      -- could replace with a 16 bit multiplier to increase complexity in this
      -- area of the chip
      FOR i IN 0 TO pci_shift_depth-1 loop
        mega_shift(i) <= word_mult_8( mega_shift(i+1) );
      END LOOP;
    END IF;
  END PROCESS;
  
  pad_out <= pad_out_buf;
  

END RTL;
