library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity incremental_key_exp_tb is
end entity;




architecture bahav of incremental_key_exp_tb is

constant clk_period : time := 10 ns;
signal clk, rst : std_logic;
signal key_in_valid, key_out_valid : std_logic;
signal cipher_key : std_logic_vector(127 downto 0);
signal round_key : std_logic_vector(127 downto 0);




begin


uut : entity work.incremental_key_exp
	generic map (ROUND_NUMBER => 0)
	port map (
			clk => clk,
			rst => rst,
			i_prev_key => cipher_key,
			i_prev_key_valid => key_in_valid, 
			o_round_key => round_key, 				
			o_round_key_valid  => key_out_valid
	);



generate_clk : process 
begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

stim : process 
begin
	rst <= '1';
	wait for clk_period;
	rst <= '0';
	key_in_valid <= '0';
	cipher_key <= x"000102030405060708090a0b0c0d0e0f";
	wait for clk_period * 5;
	key_in_valid <= '1';
	wait for clk_period;
	key_in_valid <= '0';
	wait until key_out_valid = '1';
	wait for clk_period * 5;
	
	assert round_key = x"d6aa74fd_d2af72fa_daa678f1_d6ab76fe" report "incorrect key 0" severity note;

	

	assert false report "end of simulation" severity failure;
	
	

end process;




end;