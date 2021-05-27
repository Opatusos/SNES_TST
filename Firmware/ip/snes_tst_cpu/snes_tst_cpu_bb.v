
module snes_tst_cpu (
	clk_clk,
	config_input_export,
	config_output_export,
	osdram_addr_export,
	osdram_ctrl_export,
	osdram_data_export,
	reset_reset_n,
	sync_export,
	cont_data_export);	

	input		clk_clk;
	input	[31:0]	config_input_export;
	output	[31:0]	config_output_export;
	output	[8:0]	osdram_addr_export;
	output	[1:0]	osdram_ctrl_export;
	output	[11:0]	osdram_data_export;
	input		reset_reset_n;
	input	[2:0]	sync_export;
	input	[15:0]	cont_data_export;
endmodule
