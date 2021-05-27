--*************************************************************
--  cic
--  Copyright 2019 Regis Galland
--  DEVICE : 
--*************************************************************
--
--  Description:
--		This is a VHDL implementation of an NES/SNES CIC lockout chip
--*************************************************************
--
-- https://wiki.nesdev.com/w/index.php/CIC_lockout_chip_pinout
--                 ----_----
-- CIC Data0 01 <->|P0.0  Vcc|--- 16 +5V
-- CIC Data1 02 <->|P0.1 P2.2|x-x 15 Gnd
-- Seed          03 x->|P0.2 P2.1|x-x 14 Gnd                -- Seed unused in Cart CIC
-- Lock/Key   04 x->|P0.3 P2.0|x-x 13 Gnd                -- 1= Lock; 0= Seed
-- N/C            05 x-x|Xout P1.3|<-x 12 Gnd/Reset speed B  -- pin 12 not used in SNES
-- Clk in         06 -->|Xin  P1.2|<-x 11 Gnd/Reset speed A  -- pin 11 not used in NES
-- Reset         07 -->|Rset P1.1|x-> 10 Slave CIC reset    -- pin 10 not used key CIC
-- Gnd           08 ---|Gnd  P1.0|x-> 09 /Host reset        -- pin 09 not used key CIC
--                 ---------
--
--P0.x = I/O port 0
--P1.x = I/O port 1
--P2.x = I/O port 2
--Xin  = Clock Input
--Xout = Clock Output
--Rset = Reset
--Vcc  = Input voltage
--Gnd  = Ground
---->|  = input
--<--|  = output
----x|  = unused as input
--x--|  = unused as output
-----|  = Neither input or output

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cic is 
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
end cic; 

architecture cic_a of cic is

--The CIC is a primitive 4-bit microcontroller. It contains the following registers:
--
--+-+         +-------+  +-------+-------+-------+-------+
--|C|         |   A   |  |       |       |       |       |
--+-+         +-+-+-+-+  +- - - - - - - - - - - - - - - -+
--            |   X   |  |       |       |       |       |
--        +---+-+-+-+-+  +- - - - - - - - - - - - - - - -+
--        |     B     |  |       |       |       |       |
--        | BH|   BL  |  +- - - - - - - - - - - - - - - -+
--+-------+-+-+-+-+-+-+  |       |       |       |       |
--|         IC        |  +- - - - - - - -R- - - - - - - -+
--+-+-+-+-+-+-+-+-+-+-+  |       |       |       |       |
--|                   |  +- - - - - - - - - - - - - - - -+
--+- - - - - - - - - -+  |       |       |       |       |
--|                   |  +- - - - - - - - - - - - - - - -+
--+- - - - -S- - - - -+  |       |       |       |       |
--|                   |  +- - - - - - - - - - - - - - - -+
--+- - - - - - - - - -+  |       |       |       |       |
--|                   |  +- - - - - - - - - - - - - - - -+
--+-+-+-+-+-+-+-+-+-+-+
--
--A  = 4-bit Accumulator
--C  = Carry flag
--X  = 4-bit General register
--P  = Pointer, used for memory access
--BH = Upper 2-bits of P
--BL = Lower 4-bits of P, used for I/O
--IC = Instruction counter, to save some space; it counts in a polynominal manner instead of linear manner
--S  = Stack for the IC register
--R  = 32 nibbles of RAM
--There are also 512 (768 for the 3195A) bytes of ROM, where the executable code is stored.

-- types	
	--stack 
	--type cic_stack_t is array (0 to 3) of std_logic_vector(9 downto 0);
	
	
-- exposed registers and signals
	signal carry_s				: std_logic;
	signal acc_s				: std_logic_vector(3 downto 0);
	signal x_s					: std_logic_vector(3 downto 0);
	signal b_s					: std_logic_vector(5 downto 0);
	alias  bm_s is b_s(5 downto 4);
	alias  bl_s is b_s(3 downto 0);
	signal pc_s					: std_logic_vector(9 downto 0);
	type ports_t is array (0 to 3) of std_logic_vector(3 downto 0);
	signal ports_o, ports_i     : ports_t;
	
-- internal
    constant GET_OPCODE     : unsigned(1 downto 0) := "00";
    constant EXEC_OPCODE    : unsigned(1 downto 0) := "01";
    signal cycles           : unsigned(1 downto 0);
    signal opcode_s			: std_logic_vector(7 downto 0);
	signal rom_s			: std_logic_vector(7 downto 0);
	signal ramin_s			: std_logic_vector(3 downto 0);
	signal ramout_s			: std_logic_vector(3 downto 0);
	signal wr_ram_s			: std_logic;
	--signal stack_s			: cic_stack_t;
	signal stack_ptr        : std_logic_vector(1 downto 0);
	signal stack_addr_in, stack_addr_out       : std_logic_vector(9 downto 0);
	signal wr_stack_s       : std_logic;

	signal jump             : std_logic;
	signal skip_s			: std_logic;
	signal inc_bl, dec_bl   : std_logic;
	
	COMPONENT cic_rom
      PORT (
        clka : IN STD_LOGIC;
        ena : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT;

    COMPONENT cic_ram
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
      );
    END COMPONENT;
    
    COMPONENT cic_stack is
	  PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	  );
	END COMPONENT;
	
begin

	rom_inst : cic_rom
        PORT MAP (
            clka => clk,
            ena => '1',
            addra => pc_s(8 downto 0),
            douta => rom_s
        );
  
	ram_inst: cic_ram
        PORT MAP (
            clka => clk,
            wea(0) => wr_ram_s,
            addra => b_s(4 downto 0),
            dina => ramin_s,
            douta => ramout_s
        );
	
	stack_inst : cic_stack
		PORT MAP(
			clka => clk,
			wea(0) => wr_stack_s,
			addra => stack_ptr,
			dina => stack_addr_in,
			douta => stack_addr_out 
	  );

	-- ports
	Port_0_o <= ports_o(0);
	Port_1_o <= ports_o(1);
	Port_2_o <= ports_o(2);
	ports_i(0) <= Port_0_i or ports_o(0);
	ports_i(1) <= Port_1_i or ports_o(1);
	ports_i(2) <= Port_2_i or ports_o(2);
	ports_i(3) <= ports_o(3);	
	
	cpu_state: process(clk)
	begin
		if rising_edge(clk) then
            if rst = '1' then
                cycles <= "00";
            else
                cycles <= cycles + 1;
            end if;
        end if;
	end process;
	
	-- opcode is fetched on 1st cycles
	get_op_proc : process(clk)
	begin
	   if rising_edge(clk) then
	       if cycles = GET_OPCODE and jump = '0' then
				if skip_s = '1' then    -- insert a NOP to skip next instruction
					opcode_s <= ( others => '0');
				else    -- load next instruction from rom
					opcode_s <= rom_s;
				end if;
			end if;
	   end if;
	end process;
	
--	get_op_proc : process(clk)
--	begin
--		if rising_edge(clk) then
--			if cycles = GET_OPCODE and jump = '0' then
--				if skip_s = '1' then    -- insert a NOP to skip next instruction
--					opcode_s <= ( others => '0');
--				else    -- load next instruction from rom
--					opcode_s(7 downto 4) <= rom_s(7 downto 4);
--					if pc_s = "0101100100" then -- address = 0x164
--						opcode_s(3 downto 0) <= not rom_s(3 downto 0);
--					else
--						opcode_s(3 downto 0) <= rom_s(3 downto 0);
--					end if;
--				end if;
--			end if;
--		end if;
--	end process;
	
	--the program counter is a polynomial counter, it increments by setting bit6 only if bit1 and bit0 are equal
	--this process also loads the current opcode into a register
	program_counter: process(clk)
	begin
		if rising_edge(clk) then
            if rst = '1' then
                pc_s <= ( others => '0');
			else
                if cycles = EXEC_OPCODE then
                    if jump = '1' then-- jump 0x7C-0x7F
                        pc_s <= opcode_s(1 downto 0) & rom_s(7 downto 0);
                    elsif opcode_s(7 downto 1) = "0100110" then -- ret 0x4C-0x4D
                        pc_s <= stack_addr_out;  -- only used with ret
                    elsif opcode_s(7) = '1' then    -- any code >= 0x80
                        pc_s(6 downto 0) <= opcode_s(6 downto 0);  
                    else
                        pc_s(6 downto 0) <= (pc_s(1) xnor pc_s(0)) & pc_s(6 downto 1);
                    end if;
                end if;
            end if;
		end if;
	end process;

	opcodes: process(clk)
	   variable temp_s : unsigned(4 downto 0);
	begin
		if rising_edge(clk) then
            if rst = '1' then
                jump <= '0';
                acc_s <= ( others => '0');
                b_s <= ( others => '0');
                x_s <= ( others => '0');
                --stack_s <= (others => (others => '0'));			
                stack_ptr <= "00";
                ports_o <= (others => (others => '0'));	
            else
                wr_ram_s <= '0'; 
                inc_bl <= '0';
                dec_bl <= '0';
		        wr_stack_s <= '0';                                   
                
                if cycles = EXEC_OPCODE then
                    skip_s <= '0';  -- skip is cleared on the next EXEC_OPCODE			
                
                    -- decode operations
                    case opcode_s(7 downto 4) is
                        -- adi N (00+N)
                        -- add immediate, acc = acc + N, skip if overflow
                        -- 00 is NOP
                        when x"0" =>
                            temp_s := unsigned('0' & acc_s) + unsigned('0' & opcode_s(3 downto 0));
                            acc_s <= std_logic_vector(temp_s(3 downto 0));
                            skip_s <= temp_s(4);
                        -- skai N (10+N)
                        -- skip accumulator immediate, skip if acc = N 
                        when x"1" =>
                            if acc_s = opcode_s(3 downto 0) then
                                skip_s <= '1';
                            end if;
                        -- lbli N (20+N)
                        -- load B low immediate, BL = N
                        when x"2" =>
                            bl_s <= opcode_s(3 downto 0);
                        -- ldi N (30+N)
                        -- load immediate, A = N
                        when x"3" =>
                            acc_s <= opcode_s(3 downto 0);
                        when x"4" =>
                            case opcode_s(3 downto 0) is
                                when X"0" | X"1" | X"2" | X"3" =>  -- 0x40-0x43
                                    acc_s <= ramout_s;
                                    if opcode_s(1 downto 0) /= "00" then    -- 0x41, 0x42, 0x43
                                        wr_ram_s <= '1';
                                        ramin_s <= acc_s;
                                        case opcode_s(1 downto 0) is
                                            when "10" =>    -- 0x42
                                                inc_bl <= '1';
                                                skip_s <= bl_s(3) and bl_s(2) and bl_s(1) and bl_s(0);
                                            when "11" =>    -- 0x43
                                                dec_bl <= '1';
                                                skip_s <= not (bl_s(3) or bl_s(2) or bl_s(1) or bl_s(0));
                                            when others =>
                                        end case;        
                                    end if;
                                when X"4" => -- 0x44
                                    acc_s <= std_logic_vector(0 - unsigned(acc_s));
                                when X"6" => -- 0x46
                                    ports_o(to_integer(unsigned(bl_s(1 downto 0)))) <= acc_s;
                                when X"7" => -- 0x47
                                    ports_o(to_integer(unsigned(bl_s(1 downto 0)))) <= ramout_s;
                                when X"8" | X"9" => -- 0x48-0x49    mistake in SHARP doc! 48 is set and 49 is clear
                                    carry_s <= not opcode_s(0);
                                when X"A" => -- 0x48
                                    wr_ram_s <= '1';
                                    ramin_s <= acc_s;
                                when X"C" | X"D" =>
                                    stack_ptr <= std_logic_vector(unsigned(stack_ptr) - 1);
                                    skip_s <= opcode_s(0); 
                                when others =>
                            end case;
                        when x"5" =>  
                            case opcode_s(3 downto 0) is
                                when X"0" => 
                                    bm_s <= std_logic_vector(unsigned(bm_s) + 1);
                                when X"1" => 
                                    bm_s <= std_logic_vector(unsigned(bm_s) - 1);
                                when X"2" =>  
                                    inc_bl <= '1';
                                    skip_s <= bl_s(3) and bl_s(2) and bl_s(1) and bl_s(0);
                                when X"3" =>  
                                    dec_bl <= '1';
                                    skip_s <= not (bl_s(3) or bl_s(2) or bl_s(1) or bl_s(0));
                                when X"4" =>
                                    acc_s <= acc_s xor X"F";
                                when X"5" =>
                                    acc_s <= ports_i(to_integer(unsigned(bl_s)));
                                when X"7" =>
                                    acc_s <= b_s(3 downto 0);
                                    b_s(3 downto 0) <= acc_s;
                                when X"C" =>
                                    x_s <= acc_s;
                                when X"D" =>
                                    acc_s <= x_s;
                                    x_s <= acc_s;
                                when others =>
                            end case;
                        when x"6" =>
                            case opcode_s(3 downto 2) is
                                when "00" =>    --0x60-0x63
                                    skip_s <= ramout_s(to_integer(unsigned(opcode_s(1 downto 0))));
                                when "01" =>    --0x64-0x67
                                    skip_s <= acc_s(to_integer(unsigned(opcode_s(1 downto 0))));
                                when "10" | "11" => --0x68-0x6F
                                    wr_ram_s <= '1';
                                    ramin_s <= ramout_s;
                                    ramin_s(to_integer(unsigned(opcode_s(1 downto 0)))) <= opcode_s(2);
                                when others =>
                            end case;
                        when x"7" =>
                            case opcode_s(3 downto 0) is
                                when X"0" | X"2" | X"3" =>
                                    temp_s := unsigned('0' & acc_s) + unsigned('0' & ramout_s);
                                    if (carry_s and opcode_s(1)) = '1' then
                                        temp_s := unsigned('0' & acc_s) + unsigned('0' & ramout_s) + 1;
                                    end if;                                
                                    acc_s <= std_logic_vector(temp_s(3 downto 0));
                                    skip_s <= opcode_s(1) and opcode_s(0) and temp_s(4);
                                when X"4" | X"5" | X"6" | X"7" =>
                                    b_s(5 downto 4) <= opcode_s(1 downto 0);  
                                when X"8" | X"9" | X"A" | X"B" | X"C" | X"D" | X"E" | X"F" =>
                                    if jump = '0' then
                                        jump <= '1';
                                        if opcode_s(2) = '1' then   -- jump + stck
                                            stack_ptr <= std_logic_vector(unsigned(stack_ptr) + 1);
                                        end if;
                                    else    -- this is the second byte, therefore save next pc to stack 
                                        if opcode_s(2) = '1' then -- save next pc to stack
                                            stack_addr_in <= pc_s(9 downto 7) & (pc_s(1) xnor pc_s(0)) & pc_s(6 downto 1);
                                            wr_stack_s <= '1';
                                        end if;                        
                                        jump <= '0';
                                    end if; 
                                when others =>
                            end case;
                        -- 0x80+ or unrecognized opcode
                        when others =>
                    end case;
                end if;
                
                -- bl inc dec ops
                if inc_bl = '1' then
                    bl_s <= std_logic_vector(unsigned(bl_s) + 1);
                end if;
                if dec_bl = '1' then
                    bl_s <= std_logic_vector(unsigned(bl_s) - 1);
                end if;  
            end if; 
		end if;		
	end process;
	
end cic_a;
