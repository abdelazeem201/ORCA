create_clock -period 2 [get_ports clk]
set_clock_latency 1 clk
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold  0.1 [get_clocks clk]
set_clock_transition 0.3 [get_clocks clk]

set_input_delay  -clock clk 1.2 [get_ports "Instrn* reset_n"]
set_output_delay -clock clk 2 [all_outputs]
set_output_delay -clock clk 2.7 [get_ports RESULT_DATA[0]]
set_load 2 [get_ports *]
set_input_transition 0.3 [all_inputs]
