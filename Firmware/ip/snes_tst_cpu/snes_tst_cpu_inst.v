	snes_tst_cpu u0 (
		.clk_clk              (<connected-to-clk_clk>),              //           clk.clk
		.config_input_export  (<connected-to-config_input_export>),  //  config_input.export
		.config_output_export (<connected-to-config_output_export>), // config_output.export
		.cont_data_export     (<connected-to-cont_data_export>),     //     cont_data.export
		.osd_ram_export       (<connected-to-osd_ram_export>),       //       osd_ram.export
		.reset_reset_n        (<connected-to-reset_reset_n>)         //         reset.reset_n
	);

