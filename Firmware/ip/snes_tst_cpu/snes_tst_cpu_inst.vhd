	component snes_tst_cpu is
		port (
			clk_clk              : in  std_logic                     := 'X';             -- clk
			config_input_export  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			config_output_export : out std_logic_vector(31 downto 0);                    -- export
			cont_data_export     : in  std_logic_vector(15 downto 0) := (others => 'X'); -- export
			osd_ram_export       : out std_logic_vector(22 downto 0);                    -- export
			reset_reset_n        : in  std_logic                     := 'X'              -- reset_n
		);
	end component snes_tst_cpu;

	u0 : component snes_tst_cpu
		port map (
			clk_clk              => CONNECTED_TO_clk_clk,              --           clk.clk
			config_input_export  => CONNECTED_TO_config_input_export,  --  config_input.export
			config_output_export => CONNECTED_TO_config_output_export, -- config_output.export
			cont_data_export     => CONNECTED_TO_cont_data_export,     --     cont_data.export
			osd_ram_export       => CONNECTED_TO_osd_ram_export,       --       osd_ram.export
			reset_reset_n        => CONNECTED_TO_reset_reset_n         --         reset.reset_n
		);

