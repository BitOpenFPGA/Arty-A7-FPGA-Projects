library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity add_round_key_tb is
end entity;




architecture bahav of add_round_key_tb is
constant clk_period : time := 10 ns;
signal clk,rst : std_logic;
signal data_in_valid, data_out_valid : std_logic;
signal data_in, data_out, round_key: std_logic_vector(127 downto 0);





begin


uut : entity work.add_round_key
	port map (
		clk => clk,
		rst => rst,
		i_data_valid => data_in_valid,
		i_round_key => round_key,
		i_data_block => data_in,
		o_data_block => data_out,
		o_data_valid => data_out_valid
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
	data_in_valid <= '0';
	data_in <= x"f4bcd45432e554d075f1d6c51dd03b3c";
	round_key <= x"3caaa3e8a99f9deb50f3af57adf622aa";
	wait for clk_period * 2.5;
	wait for 1 ns;

	data_in_valid <= '1';
	wait for clk_period;
	data_in_valid <= '0';
	wait for clk_period*10;
	assert data_out = x"c81677bc9b7ac93b25027992b0261996" report "incorrect add round key" severity note;
	assert false report "end of simulation" severity failure;
	
	

end process;




end;