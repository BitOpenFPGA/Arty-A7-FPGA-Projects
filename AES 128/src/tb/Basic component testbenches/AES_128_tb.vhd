library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AES_128_tb is
end entity;

architecture bahav of AES_128_tb is

constant clk_period : time := 10 ns;
signal clk, rst : std_logic;
signal cipher_key_valid, cipher_text_valid, plain_txt_valid : std_logic;
signal cipher_key, plain_txt, cipher_txt : std_logic_vector(127 downto 0);
signal round_key : std_logic_vector(127 downto 0);




begin


uut : entity work.AES_128
	port map (
		clk => clk,
		rst => rst,
		i_cipher_key => cipher_key,
		i_new_key_valid => cipher_key_valid,
		i_plain_text => plain_txt,
		i_plain_text_valid => plain_txt_valid,
		o_cipher_text => cipher_txt,
		o_cipher_text_valid => cipher_text_valid
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
	cipher_key_valid <= '0';
	plain_txt_valid <= '0';
	cipher_key <= x"000102030405060708090a0b0c0d0e0f";
	plain_txt <= x"00112233445566778899aabbccddeeff";
	wait for clk_period;
	cipher_key_valid <= '1';
	plain_txt_valid <= '1';
	wait for clk_period;
	cipher_key_valid <= '0';
	plain_txt_valid <= '0';
	wait until cipher_text_valid = '1';
	wait for clk_period * 5;
	
	assert cipher_txt = x"69c4e0d86a7b0430d8cdb78070b4c55a" report "incorrect output" severity note;

	

	assert false report "end of simulation" severity failure;
	
	

end process;




end;