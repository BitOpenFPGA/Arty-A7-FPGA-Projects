library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AES_128 is
port (	clk : in std_logic;
		rst : in std_logic;
		i_key : in std_logic_vector(127 downto 0);
		i_new_key_valid : in std_logic;
		i_plaintext : in std_logic_vector(127 downto 0);
		i_plaintext_valid : in std_logic;
		o_ciphertext : out std_logic_vector(127 downto 0);
		o_ciphertext_valid : out std_logic
	);
end entity;



architecture rtl of AES_128 is
type round_key_arr_t is array (0 to 9) of std_logic_vector(127 downto 0);
signal round_key_arr : round_key_arr_t;

-- State is the wire for the 128 bit block of plaintext through the first 9 "normal" rounds as well as 
-- the components for the last round, including the delay line
type state_arr_t is array (0 to 13) of std_logic_vector(127 downto 0);
signal state_arr : state_arr_t;

signal rounds_valid_arr : std_logic_vector(9 downto 0); --holds the propogating valid signal through the rounds

signal last_round_valid_arr : std_logic_vector(3 downto 0); --holds the propogating valid signal through the rounds

begin


key_expansion0 : entity work.key_expansion
	port map (
			clk => clk,
			rst => rst,
			i_key => i_key,
			i_key_valid => i_new_key_valid, 
			o_round_key_0 => round_key_arr(0), 
			o_round_key_1 => round_key_arr(1),
			o_round_key_2 => round_key_arr(2),				
			o_round_key_3 => round_key_arr(3),				
			o_round_key_4 => round_key_arr(4),				
			o_round_key_5 => round_key_arr(5),				
			o_round_key_6 => round_key_arr(6),				
			o_round_key_7 => round_key_arr(7),				
			o_round_key_8 => round_key_arr(8),				
			o_round_key_9 => round_key_arr(9)	
	);


 
add_init_key : entity work.add_round_key
	port map (
		clk => clk,
		rst => rst,
		i_data_valid => i_plaintext_valid,
		i_round_key => i_key,
		i_data_block => i_plaintext,
		o_data_block => state_arr(0),
		o_data_valid => rounds_valid_arr(0)
	);

-- First 9 rounds have the mix columns component, the last round does not
rounds : for I in 0 to 8 generate
	round : entity work.round
	port map(
		clk => clk,
		rst => rst,
		i_valid => rounds_valid_arr(I),
		i_data_block => state_arr(I),
		i_round_key => round_key_arr(I),
		o_data_block => state_arr(I+1),
		o_valid => rounds_valid_arr(I+1)
	);
end generate;

-- Last round has no mix columns operation
sub_bytes_last : entity work.sub_bytes
	port map (
		clk => clk,
		rst => rst,
		i_enable => rounds_valid_arr(9),
		i_data_block => state_arr(9),
		o_data_block => state_arr(10),
		o_data_valid => last_round_valid_arr(0)
	);

shift_rows_last : entity work.shift_rows
	port map (
		i_data_block => state_arr(10),
		i_data_valid => last_round_valid_arr(0),
		o_data_block => state_arr(11),
		o_data_valid => last_round_valid_arr(1)
	);


-- Last round has a latency of 2 clk cycles (with no mix columns) but key schedule only produces valid new keys 
-- after 3 clock cycles (for use in the 4th clk cycle for a normal round).
-- Therefore to keep pipeline aligned, we must delay the data by 2 clock cycles before doing 
-- the last add round key step. 
delay_data : process (clk)
begin
	if rising_edge(clk) then
		if rst = '1' then
			last_round_valid_arr(3 downto 2) <= (others=>'0');
		else 
			last_round_valid_arr(3 downto 2) <= last_round_valid_arr(2 downto 1);
			state_arr(12 to 13) <= state_arr(11 to 12);
		end if;
	end if;
end process;






add_round_key_last : entity work.add_round_key
	port map (
		clk => clk,
		rst => rst,
		i_data_valid => last_round_valid_arr(3),
		i_round_key => round_key_arr(9),
		i_data_block => state_arr(13),
		o_data_block => o_ciphertext,
		o_data_valid => o_ciphertext_valid
	);








end;