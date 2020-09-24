library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mix_columns_tb is
end entity;




architecture bahav of mix_columns_tb is
constant clk_period : time := 10 ns;
signal clk,rst : std_logic;
signal data_in_valid, data_out_valid : std_logic;
signal data_in, data_out: std_logic_vector(127 downto 0);





begin


uut : entity work.mix_columns
	port map (
		clk => clk,
		rst => rst,
		i_data_valid => data_in_valid,
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
	data_in <= x"a7be1a6997ad739bd8c9ca451f618b61";
	wait for clk_period * 2.5;
	wait for 1 ns;

	data_in_valid <= '1';
	wait for clk_period;
	data_in_valid <= '0';
	wait for clk_period*10;
	assert data_out = x"ff87968431d86a51645151fa773ad009" report "incorrect mix columns" severity note;
	assert false report "end of simulation" severity failure;
	
	

end process;




end;