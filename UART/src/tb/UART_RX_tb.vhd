library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART_RX_tb is
end entity;

architecture behav of UART_RX_tb is

constant clk_period : time := 10 ns;
signal clk, rst : std_logic;

signal tx_data_vec : std_logic_vector(7 downto 0);
signal tx_enable : std_logic := '0';
signal tx_busy : std_logic;
signal  rx_data_valid : std_logic;
signal rx_data_vec : std_logic_vector(7 downto 0);
signal tx_out_bit : std_logic;

begin

uart_tx : entity work.UART_TX
	port map (	
		clk => clk, 	
		rst => rst,
		i_txdata => tx_data_vec,
		i_tx_enable => tx_enable,
		o_tx => tx_out_bit,
		o_busy => tx_busy
	);
	
	
uut : entity work.UART_RX
	port map ( 
		clk => clk,
		rst => rst,
		i_rx_bit => tx_out_bit,
		o_data_vld => rx_data_valid,
		o_rx_data => rx_data_vec
	);



proc_clk : process
begin
	clk <= '0';
	wait for clk_period/2;
	clk <= '1';
	wait for clk_period/2;
end process;

proc_stim : process 
begin
rst <= '1';

wait for clk_period;

rst <= '0';
tx_data_vec <= "10101000";
tx_enable <= '1';
wait for clk_period;
tx_enable <= '0';

wait until rx_data_valid = '1';
wait for clk_period * 20;
assert rx_data_vec = tx_data_vec report "Test 1 failed" severity note;

tx_data_vec <= "00001010";
tx_enable <= '1';
wait for clk_period;
tx_enable <= '0';

wait until rx_data_valid = '1';
wait for clk_period * 20;
assert rx_data_vec = tx_data_vec report "Test 1 failed" severity note;

assert false report "end of simulation" severity failure;


end process;



end;