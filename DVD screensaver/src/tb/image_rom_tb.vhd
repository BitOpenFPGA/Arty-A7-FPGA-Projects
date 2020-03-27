library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity image_rom_tb is
end entity;

architecture behav of image_rom_tb is
signal clk : std_logic;
constant clk_period : time := 10 ns;
signal data_out : std_logic_vector(143 downto 0);
signal addr : std_logic_vector(6 downto 0);


begin

image_rom1 : entity work.image_rom
port map (	clk => clk,
			r_addr => addr,
			data => data_out
			);




proc_clk: process
begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

	proc_set: process
	begin
		addr <= (others=>'0');
		wait for clk_period;
		addr <= std_logic_vector(to_unsigned(57, addr'length));
		wait for clk_period*10;
		assert false report "success - end of simulation" severity failure;
	end process;




end architecture;
