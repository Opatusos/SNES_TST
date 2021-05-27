
set_time_format -unit ns -decimal_places 3

create_clock -name ctrl_clk_snes_virt -period 2500
create_clock -name ctrl_clk_snes -period 25000 [get_ports CTRL_CLK_i]

set_clock_groups -exclusive -group {ctrl_clk_snes_virt ctrl_clk_snes}

set snes_data_delay_min 0.0
set snes_data_delay_max 8.0

set_input_delay -clock ctrl_clk_snes_virt -min $snes_data_delay_min [get_ports {CTRL_LATCH_i CTRL_SDATA_i}]
set_input_delay -clock ctrl_clk_snes_virt -max $snes_data_delay_min [get_ports {CTRL_LATCH_i CTRL_SDATA_i}]

set_false_path -from [get_ports {CIC_RST_io}]
set_false_path -to [get_ports {CIC_RST_io}]