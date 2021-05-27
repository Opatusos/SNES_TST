	component snes_tst_cpu is
		port (
			clk_clk              : in  std_logic                     := 'X';             -- clk
			config_input_export  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			config_output_export : out std_logic_vector(31 downto 0);                    -- export
			osdram_addr_export   : out std_logic_vector(8 downto 0);                     -- export
			osdram_ctrl_export   : out std_logic_vector(1 downto 0);                     -- export
			osdram_data_export   : out std_logic_vector(11 downto 0);                    -- export
			reset_reset_n        : in  std_logic                     := 'X';             -- reset_n
			sync_export          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- export
			cont_data_export     : in  std_logic_vector(15 downto 0) := (others => 'X')  -- export
		);
	end component snes_tst_cpu;

	u0 : component snes_tst_cpu
		port map (
			clk_clk              => CONNECTED_TO_clk_clk,              --           clk.clk
			config_input_export  => CONNECTED_TO_config_input_export,  --  config_input.export
			config_output_export => CONNECTED_TO_config_output_export, -- config_output.export
			osdram_addr_export   => CONNECTED_TO_osdram_addr_export,   --   osdram_addr.export
			osdram_ctrl_export   => CONNECTED_TO_osdram_ctrl_export,   --   osdram_ctrl.export
			osdram_data_export   => CONNECTED_TO_osdram_data_export,   --   osdram_data.export
			reset_reset_n        => CONNECTED_TO_reset_reset_n,        --         reset.reset_n
			sync_export          => CONNECTED_TO_sync_export,          --          sync.export
			cont_data_export     => CONNECTED_TO_cont_data_export      --     cont_data.export
		);

