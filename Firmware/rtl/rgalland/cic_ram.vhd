library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cic_ram is
	PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
end cic_ram;

architecture behaviour of cic_ram is
	subtype nibble is std_logic_vector(3 downto 0);
	type ram_t is array (0 to 31) of nibble;
	signal cic_ram : ram_t;
begin

	write_proc : process(clka)
	begin
		if rising_edge(clka) then
			if wea(0) = '1' then
				cic_ram(to_integer(unsigned(addra))) <= dina;
			end if;
		end if;
	end process;
	
	read_proc : process(clka)
	begin
		if rising_edge(clka) then
			--if wea(0) = '0' then
				douta <= cic_ram(to_integer(unsigned(addra)));
			--end if;
		end if;
	end process;

end behaviour;
