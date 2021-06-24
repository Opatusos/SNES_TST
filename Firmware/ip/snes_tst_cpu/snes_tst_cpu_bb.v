
module snes_tst_cpu (
	clk_clk,
	config_input_export,
	config_output_export,
	cont_data_export,
	osd_ram_export,
	reset_reset_n);	

	input		clk_clk;
	input	[31:0]	config_input_export;
	output	[31:0]	config_output_export;
	input	[15:0]	cont_data_export;
	output	[22:0]	osd_ram_export;
	input		reset_reset_n;
endmodule
