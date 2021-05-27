----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Regis Galland
-- 
-- Create Date: 12/16/2019 10:27:01 AM
-- Design Name: 
-- Module Name: cic_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cic_lock_top is
    port (
		--CTRL
		cic_clk       : in std_logic;
		pll_locked    : in std_logic;
		--pll_rst_n	  : out std_logic;
		
		-- ports
		port0_INOUT   : inout std_logic_vector(1 downto 0);
		--port0_IN      : in std_logic_vector(1 downto 0);
		--port0_OUT     : out std_logic_vector(1 downto 0);
		--port0_OE      : out std_logic_vector(1 downto 0);
		--dir           : out std_logic_vector(1 downto 0);
		
		pal_ntsc		  : in std_logic;
		cic_fail		  : out std_logic;
		
		cart_cic_reset: out std_logic;
		sys_reset     : out std_logic
	);
end cic_lock_top;

architecture behaviour of cic_lock_top is

    component cic is 
        port (
            --CTRL
            clk 			: in std_logic;
            rst 			: in std_logic;
            
            -- input ports
            Port_0_i        : in std_logic_vector(3 downto 0);
            Port_1_i        : in std_logic_vector(3 downto 0);
            Port_2_i        : in std_logic_vector(3 downto 0);
             
            -- output ports
            Port_0_o        : out std_logic_vector(3 downto 0);
            Port_1_o        : out std_logic_vector(3 downto 0);
            Port_2_o        : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component seed_counter is
		Generic (threshold : STD_LOGIC_VECTOR(12 downto 0) := "0101101000101");	-- X"5A2C" >> 2 
		Port ( clk : in STD_LOGIC;
			   rst : in STD_LOGIC;
			   seed : out STD_LOGIC);
	end component;
    
    signal seed, rst : std_logic;
    signal port0_o, port1_o  : std_logic_vector(3 downto 0);
    
begin
	
	port0_INOUT(0) <= port0_o(0) when port0_o(0) = '1' else
							'Z';
					
	port0_INOUT(1) <= port0_o(1) when port0_o(1) = '1' else
							'Z';


		
	--port0_OE <= port0_o(1 downto 0);
	
	--dir <= port0_o(1 downto 0);
	sys_reset <= port1_o(0);			
	cart_cic_reset <=  port1_o(1);	-- inverted as I use N-FET to buffer
	
	--pll_rst_n <= '1';
    rst <= not pll_locked;
	 
	 cic_fail <= port1_o(3);
	
	seed_inst : seed_counter
		Generic map (threshold => "0101101000101")	-- X"5A2C" >> 2 
		Port map ( clk => cic_clk, rst => rst, seed => seed);

    cic_inst : cic
        port map (
            clk => cic_clk,
		      rst => rst,
            Port_0_i(0) => port0_INOUT(0),
            Port_0_i(1) => port0_INOUT(1),
            Port_0_i(2) => seed,
            Port_0_i(3) => '1',
--          Port_1_i => "0000",
				Port_1_i(0) => '0',
            Port_1_i(1) => '0',
            Port_1_i(2) => '0',
            Port_1_i(3) => pal_ntsc,
            Port_2_i => "0000",
            Port_0_o => port0_o,
            Port_1_o => port1_o,
			   Port_2_o => open);

end behaviour;
