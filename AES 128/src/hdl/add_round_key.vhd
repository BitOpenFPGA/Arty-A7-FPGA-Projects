library IEEE;
use IEEE.std_logic_1164.all;

-- Performs the add round key stage for a single round.
-- This is an bitwise xor between the block/state and the round key
entity add_round_key is 
	port (	clk  : in std_logic;
			i_data_valid : in std_logic;
			i_round_key : in std_logic_vector(127 downto 0);
			i_data_block : in std_logic_vector(127 downto 0);
			o_data_block : out std_logic_vector(127 downto 0);
			o_data_valid : out std_logic );
end entity;

architecture rtl of add_round_key is 

begin
add_round_key : process (clk)
begin
	if rising_edge(clk) then
		if i_data_valid = '1' then
			o_data_block <= i_round_key xor i_data_block;
			o_data_valid <= '1';
		else 
			o_data_valid <= '0';
		end if;
	end if;
end process;

end;