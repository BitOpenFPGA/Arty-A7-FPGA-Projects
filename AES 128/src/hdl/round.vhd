library IEEE;
use IEEE.std_logic_1164.all;

entity round is
	port(	
		clk : in std_logic;
		rst : in std_logic;
		i_valid : in std_logic;
		i_data_block : in std_logic_vector(127 downto 0);
		i_round_key : in std_logic_vector(127 downto 0);
		o_data_block : out std_logic_vector(127 downto 0);
		o_valid : out std_logic 
	);
end entity;

architecture rtl of round is
type data_block_arr_t is array (0 to 3) of std_logic_vector(127 downto 0);
signal data_block_arr : data_block_arr_t; 

signal valid_arr : std_logic_vector(2 downto 0);

begin

sub_bytes0 : entity work.sub_bytes
	port map (
		clk => clk,
		rst => rst,
		i_enable => i_valid,
		i_data_block => i_data_block,
		o_data_block => data_block_arr(0),
		o_data_valid => valid_arr(0)
	);

shift_rows0 : entity work.shift_rows
	port map (
		i_data_block => data_block_arr(0),
		i_data_valid => valid_arr(0),
		o_data_block => data_block_arr(1),
		o_data_valid => valid_arr(1)
	);

mix_columns0 : entity work.mix_columns
	port map (
		clk => clk,
		rst => rst,
		i_data_valid => valid_arr(1),
		i_data_block => data_block_arr(1),
		o_data_block => data_block_arr(2),
		o_data_valid => valid_arr(2)
	);

add_round_key0 : entity work.add_round_key
	port map (
		clk => clk,
		rst => rst,
		i_data_valid => valid_arr(2),
		i_round_key => i_round_key,
		i_data_block => data_block_arr(2),
		o_data_block => o_data_block,
		o_data_valid => o_valid
	);

end;