library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cic_stack is
	PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
end cic_stack;

architecture behaviour of cic_stack is
	subtype stack_addr is std_logic_vector(9 downto 0);
	type stack_t is array (0 to 3) of stack_addr;
	signal stack : stack_t;
begin

	write_proc : process(clka)
	begin
		if rising_edge(clka) then
			if wea(0) = '1' then
				stack(to_integer(unsigned(addra))) <= dina;
			end if;
		end if;
	end process;
	
	read_proc : process(clka)
	begin
		if rising_edge(clka) then
			--if wea(0) = '0' then
				douta <= stack(to_integer(unsigned(addra)));
			--end if;
		end if;
	end process;

end behaviour;
