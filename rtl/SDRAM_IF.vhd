----------------------------------------------------------------------/
----                                                               ----
----                                                               ---- 
----                                                               ----
----                                                               ----
----                                                               ----
-----------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

USE WORK.ORCA_TYPES.ALL;

ENTITY SDRAM_IF IS
--   GENERIC (
--     sd_a_width       : integer := 10;
--     sd_dq_width      : integer := 16
--   );
  PORT (
    sdram_clk           : IN  std_logic;

    sdram_rst_n         : IN  std_logic;

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

    -- interface to FIFOs
    sd_wfifo_pop        : OUT std_logic;
    sd_wfifo_empty      : IN  std_logic;
    sd_rfifo_push       : OUT std_logic;
    sd_rfifo_full       : IN  std_logic;

    sd_rfifo_DQ_out     : OUT std_logic_vector(31 DOWNTO 0);
    sd_wfifo_DQ_in      : IN  std_logic_vector(31 DOWNTO 0)
  );

END SDRAM_IF;

ARCHITECTURE RTL OF SDRAM_IF IS
  SIGNAL u_control_bus          : std_logic_vector(14 DOWNTO 0);
  SIGNAL sync_control_bus       : std_logic_vector(14 DOWNTO 0);
  SIGNAL control_bus            : std_logic_vector(14 DOWNTO 0);
  
  SIGNAL out_control            : std_logic_vector(17 DOWNTO 0);
  SIGNAL c_out_control          : std_logic_vector(17 DOWNTO 0);

  SIGNAL DQ_in_0                : std_logic_vector(15 DOWNTO 0);
  SIGNAL DQ_in_1                : std_logic_vector(15 DOWNTO 0);

  SIGNAL DQ_out_0               : std_logic_vector(15 DOWNTO 0);
  SIGNAL DQ_out_1               : std_logic_vector(15 DOWNTO 0);

  SIGNAL ti_hi, ti_low          : std_logic;

  FUNCTION MUX_FUNC(A1, A2 : IN std_logic; S0 : IN std_logic) RETURN std_logic IS
    -- pragma map_to_entity mx02d4
    -- pragma return_port_name Y
    -- contents of this function are ignored but should match the
    -- functionality of the module MUX_ENTITY, so pre- and post
    -- simulation will match

  BEGIN
    IF(S0 = '0') THEN
      RETURN(A1);
    ELSE
      RETURN(A2);
    END IF;
  END;


  COMPONENT MUX21X2
    PORT (
      A1  : IN  std_logic;
      A2  : IN  std_logic;
      S0  : IN  std_logic;
      Y   : OUT std_logic
    );
  END COMPONENT;
  
  TYPE   data_page IS ARRAY (0 TO sdram_shift_depth) OF std_logic_vector(15 DOWNTO 0);
  SIGNAL mega_shift_0 : data_page;
  SIGNAL mega_shift_1 : data_page;

BEGIN

  ti_low <= '0';
  ti_hi  <= '1';

  u_control_bus <= risc_PSW &
                   risc_OUT_VALID &
                   risc_STACK_FULL &
                   risc_EndOfInstrn &
                   risc_Rd_Instr;
  
  sd_A    <= out_control(9 DOWNTO 0);

  sd_LD   <= out_control(10);
  sd_RW   <= out_control(11);
  sd_BWS  <= out_control(13 DOWNTO 12);
  
  sd_wfifo_pop <= out_control(14);
  sd_rfifo_push <= out_control(15);


  data_en_l: PROCESS (sdram_rst_n, sdram_clk)
  BEGIN
    IF sdram_rst_n = '0' THEN
      sd_DQ_en <= (OTHERS => '0');
    ELSIF sdram_clk'event AND sdram_clk='1' THEN 

      IF c_out_control(0) = '1' THEN 
        sd_DQ_en <= (OTHERS => '0');
      ELSE 
        sd_DQ_en <= (OTHERS => '1');
      END IF;
    END IF;
  END PROCESS;
  
  syncs: PROCESS
  BEGIN
    WAIT UNTIL sdram_clk'event AND sdram_clk='1';

    control_bus <= sync_control_bus;
    sync_control_bus <= u_control_bus;
  END PROCESS;

  sd_fsm: PROCESS (sdram_rst_n, sdram_clk, c_out_control)
  BEGIN
    IF sdram_rst_n='0' THEN
      out_control <= (OTHERS => '0');
    ELSIF sdram_clk'event AND sdram_clk='1' THEN 
      out_control <= c_out_control;
    END IF;
  END PROCESS;

  -- the most bogus fsm you've ever seen!!
  sd_states: PROCESS(control_bus, sd_wfifo_empty, sd_rfifo_full)
    VARIABLE temp : std_logic_vector(16 DOWNTO 0);
  BEGIN
    
    temp := control_bus & sd_rfifo_full & sd_wfifo_empty;

    CASE temp IS
      WHEN "01010101010101010" => 
        c_out_control <= (temp & "1") + 981;
      WHEN "10101010101010101" => 
        c_out_control <= (temp & "1") + 97632;
      WHEN "01101101101101101" => 
        c_out_control <= (temp & "1") + 13243;
      WHEN "10010010010010010" => 
        c_out_control <= (temp & "1") + 4565;
      WHEN "11011011011011011" => 
        c_out_control <= (temp & "1") + 92734;
      WHEN "11101010001101001" => 
        c_out_control <= (temp & "1") + 18273;
      WHEN "01001011010100110" =>
        c_out_control <= (temp & "1") + 7346;
      WHEN OTHERS => 
        c_out_control <= (temp & "1") + 3114;
    END CASE;
  END PROCESS;


  sd_data0_read: PROCESS
  BEGIN 
    WAIT UNTIL sdram_clk'event AND sdram_clk='1';

    DQ_in_0 <= sd_DQ_in;
  END PROCESS;

  sd_data1_read: PROCESS
  BEGIN 
    WAIT UNTIL sdram_clk'event AND sdram_clk='0';

    DQ_in_1 <= sd_DQ_in;
  END PROCESS;

  SD_DATAIN_BUS: PROCESS ( DQ_in_0, DQ_in_1 )
  begin
    sd_rfifo_DQ_out(31 DOWNTO 16) <= DQ_in_1;
    sd_rfifo_DQ_out(15 DOWNTO 0) <= DQ_in_0;
  END PROCESS;
  
  
  sd_data0_write: process ( sdram_rst_n, sdram_clk, mega_shift_0, sd_wfifo_DQ_in )
  BEGIN 
    IF sdram_rst_n = '0' THEN
      mega_shift_0 <= (OTHERS => (OTHERS => '0') );
      DQ_out_0 <= (OTHERS => '0');
      
    ELSIF sdram_clk'event AND sdram_clk='1' THEN 

      DQ_out_0 <= mega_shift_0(0);

      mega_shift_0(sdram_shift_depth) <= sd_wfifo_DQ_in(15 DOWNTO 0);

      FOR i IN 0 TO sdram_shift_depth-1 loop
        mega_shift_0(i) <= word_mux_16( mega_shift_0(i+1) );
      END LOOP;
    END IF;
  END PROCESS;

  sd_data1_write: process ( sdram_rst_n, sdram_clk, mega_shift_1, sd_wfifo_DQ_in )
  BEGIN 
    IF sdram_rst_n = '0' THEN
      mega_shift_1 <= (OTHERS => (OTHERS => '0') );
      DQ_out_1 <= (OTHERS => '0');
      
    ELSIF sdram_clk'event AND sdram_clk='0' THEN 

      DQ_out_1 <= mega_shift_1(0);

      mega_shift_1(sdram_shift_depth) <= sd_wfifo_DQ_in(31 DOWNTO 16);

      FOR i IN 0 TO sdram_shift_depth-1 loop
        mega_shift_1(i) <= word_mux_16( mega_shift_1(i+1) );
      END LOOP;
    END IF;
  END PROCESS;


  sd_mux_out_bus: FOR bit_index IN 15 DOWNTO 0 GENERATE
    sd_mux_dq_out: MUX21X2 PORT MAP (A1 => DQ_out_0(bit_index) , A2 => DQ_out_1(bit_index), S0 => sdram_clk,
                                    Y => sd_DQ_out(bit_index));
  END GENERATE sd_mux_out_bus;
  
  sd_mux_CK:  MUX21X2 PORT MAP (A1 => ti_low, A2 => ti_hi,  S0 => sdram_clk, Y => sd_CK);
  sd_mux_CKn: MUX21X2 PORT MAP (A2 => ti_hi,  A1 => ti_low, S0 => sdram_clk, Y => sd_CKn);
  
  
END RTL;
