create_clock -period 13.000 -name clk -waveform {0.000 6.500} [get_ports clk]
# I hope these are correct
set_false_path -from [get_ports btnC]
set_false_path -to [get_ports {led[0]}]