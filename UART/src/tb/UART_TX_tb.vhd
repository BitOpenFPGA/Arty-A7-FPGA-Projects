Library IEEE;
use IEEE.std_logic_1164.all;

entity UART_TX_tb is 
end entity;

architecture behav of UART_TX_tb is

signal clk, rst, tx_busy, tx_out_bit, tx_enable: std_logic := '0';
constant clk_period : time := 10 ns;
signal tx_data : std_logic_vector(7 downto 0);
begin

uut : entity work.UART_TX
	port map (	
			clk => clk, 	
			rst => rst,
			i_txdata => tx_data,
			i_tx_enable => tx_enable,
			o_tx => tx_out_bit,
			o_busy => tx_busy
			);




gen_clk: process
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
	wait for clk_period;
	-- wait until tx_busy = '0';
	tx_enable <= '1';
	tx_data <= "11001100";
	wait for clk_period;
	-- wait until rising_edge(clk);
	tx_enable <= '0';
	wait until tx_busy = '0';
	tx_enable <= '1';
	tx_data <= "11000011";
	wait until rising_edge(clk);
	tx_enable <= '0';
	wait until tx_busy = '0';
	wait for clk_period*100;
	assert false report "success - end of simulation" severity failure;
end process;




end;