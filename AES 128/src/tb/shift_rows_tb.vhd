library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift_rows_tb is
end entity;


architecture bahav of shift_rows_tb is

constant clk_period : time := 10 ns;
signal clk : std_logic;
signal data_in_valid, data_out_valid : std_logic;
signal data_in, data_out: std_logic_vector(127 downto 0);





begin


uut : entity work.shift_rows
	port map (
		i_data_block => data_in,
		i_data_valid => data_in_valid,
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
	data_in_valid <= '1';
	data_in <= x"63cab7040953d051cd60e0e7ba70e18c";
	wait for 1 ns;
	assert data_out = x"6353e08c0960e104cd70b751bacad0e7" report "incorrect shift rows" severity note;
	wait for clk_period*5;
	assert false report "end of simulation" severity failure;
end process;




end;