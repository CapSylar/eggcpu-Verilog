create_clock -period 16.000 -name clk -waveform {0.000 8.000} [get_ports clk]
# I hope these are correct
set_false_path -from [get_ports btnC]
set_false_path -to [get_ports {led[0]}]


