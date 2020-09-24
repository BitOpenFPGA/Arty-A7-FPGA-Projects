library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity key_expansion_tb is
end entity;




architecture bahav of key_expansion_tb is

constant clk_period : time := 10 ns;
signal clk, rst : std_logic;
signal key_in_valid, key_out_valid : std_logic;
signal cipher_key, init_key : std_logic_vector(127 downto 0);
signal round_key_0 : std_logic_vector(127 downto 0);
signal round_key_1 : std_logic_vector(127 downto 0);
signal round_key_2 : std_logic_vector(127 downto 0);
signal round_key_3 : std_logic_vector(127 downto 0);
signal round_key_4 : std_logic_vector(127 downto 0);
signal round_key_5 : std_logic_vector(127 downto 0);
signal round_key_6 : std_logic_vector(127 downto 0);
signal round_key_7 : std_logic_vector(127 downto 0);
signal round_key_8 : std_logic_vector(127 downto 0);
signal round_key_9 : std_logic_vector(127 downto 0);



begin


uut : entity work.key_expansion
	port map (
			clk => clk,
			rst => rst,
			i_cipher_key => cipher_key,
			i_cipher_key_valid => key_in_valid, 
			o_round_key_0 => round_key_0, 
			o_round_key_1 => round_key_1,
			o_round_key_2 => round_key_2,				
			o_round_key_3 => round_key_3,				
			o_round_key_4 => round_key_4,				
			o_round_key_5 => round_key_5,				
			o_round_key_6 => round_key_6,				
			o_round_key_7 => round_key_7,				
			o_round_key_8 => round_key_8,				
			o_round_key_9 => round_key_9	);



generate_clk : process 
begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

stim : process 
begin
	key_in_valid <= '0';
	cipher_key <= x"000102030405060708090a0b0c0d0e0f";
	wait for clk_period * 5;
	key_in_valid <= '1';
	wait for clk_period;
	key_in_valid <= '0';
	wait for clk_period * 42;
	
	assert round_key_0 = x"d6aa74fdd2af72fadaa678f1d6ab76fe" report "incorrect key 0" severity note;
	assert round_key_1 = x"b692cf0b643dbdf1be9bc5006830b3fe" report "incorrect key 1" severity note;
	assert round_key_2 = x"b6ff744ed2c2c9bf6c590cbf0469bf41" report "incorrect key 2" severity note;
	assert round_key_3 = x"47f7f7bc95353e03f96c32bcfd058dfd" report "incorrect key 3" severity note;
	assert round_key_4 = x"3caaa3e8a99f9deb50f3af57adf622aa" report "incorrect key 4" severity note;
	assert round_key_5 = x"5e390f7df7a69296a7553dc10aa31f6b" report "incorrect key 5" severity note;
	assert round_key_6 = x"14f9701ae35fe28c440adf4d4ea9c026" report "incorrect key 6" severity note;
	assert round_key_7 = x"47438735a41c65b9e016baf4aebf7ad2" report "incorrect key 7" severity note;
	assert round_key_8 = x"549932d1f08557681093ed9cbe2c974e" report "incorrect key 8" severity note;
	assert round_key_9 = x"13111d7fe3944a17f307a78b4d2b30c5" report "incorrect key 9" severity note;
	

	assert false report "end of simulation" severity failure;
	
	

end process;




end;