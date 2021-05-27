	snes_tst_cpu u0 (
		.clk_clk              (<connected-to-clk_clk>),              //           clk.clk
		.config_input_export  (<connected-to-config_input_export>),  //  config_input.export
		.config_output_export (<connected-to-config_output_export>), // config_output.export
		.osdram_addr_export   (<connected-to-osdram_addr_export>),   //   osdram_addr.export
		.osdram_ctrl_export   (<connected-to-osdram_ctrl_export>),   //   osdram_ctrl.export
		.osdram_data_export   (<connected-to-osdram_data_export>),   //   osdram_data.export
		.reset_reset_n        (<connected-to-reset_reset_n>),        //         reset.reset_n
		.sync_export          (<connected-to-sync_export>),          //          sync.export
		.cont_data_export     (<connected-to-cont_data_export>)      //     cont_data.export
	);

