----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Regis Galland
-- 
-- Create Date: 12/16/2019 02:35:55 PM
-- Design Name: 
-- Module Name: pseudo_rnd_gen - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity seed_counter is
    Generic (threshold : STD_LOGIC_VECTOR(12 downto 0) := "0101101000101");	-- X"5A2C" >> 3 
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           seed : out STD_LOGIC);
end seed_counter;

architecture Behavioral of seed_counter is
    signal seed_counter : unsigned (12 downto 0);
begin

    apu_clk_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                seed_counter <= (others => '0');
            else
                seed_counter <= seed_counter + 1;
            end if;    
        end if;
    end process;

    seed <= '1' when seed_counter < unsigned(threshold) else '0';

end Behavioral;
