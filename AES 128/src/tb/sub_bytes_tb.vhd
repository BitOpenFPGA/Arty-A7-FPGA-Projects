library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sub_bytes_tb is
end entity;




architecture bahav of sub_bytes_tb is
constant clk_period : time := 10 ns;
signal clk : std_logic;
signal sub_bytes_enable, data_out_valid : std_logic;
signal data_in, data_out: std_logic_vector(127 downto 0);





begin


uut : entity work.sub_bytes
	port map (
		clk => clk,
		i_enable => sub_bytes_enable,
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
	sub_bytes_enable <= '0';
	data_in <= x"000102030405060708090A0B0C0D0E0F";
	wait for clk_period * 5;
	sub_bytes_enable <= '1';
	wait for clk_period;
	sub_bytes_enable <= '0';
	wait for clk_period*10;
	assert data_out = x"637c777bf26b6fc53001672bfed7ab76" report "incorrect byte substitution" severity note;
	assert false report "end of simulation" severity failure;
	
	

end process;




end;