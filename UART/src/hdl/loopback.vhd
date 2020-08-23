library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity loopback is 
port (	CLK : in std_logic;
		RST_BTN : in std_logic;
		UART_RX : in std_logic;
		SW : in std_logic;
		UART_TX : out std_logic
		);

end entity;




architecture rtl of loopback is

signal uart_rx_data : std_logic_vector(7 downto 0);
signal uart_tx_data : std_logic_vector(7 downto 0);

signal tx_enable : std_logic;
signal tx_busy : std_logic;



begin

-- Send A is switch 0 is '1', otherwise send back received bit.
uart_tx_data <= uart_rx_data when SW = '0' else "01000001";



uart_tx1 : entity work.UART_TX
	port map (	
		clk => CLK, 	
		rst => RST_BTN,
		i_txdata => uart_tx_data,
		i_tx_enable => tx_enable,
		o_tx => UART_TX,
		o_busy => tx_busy
	);
	
	
uart_rx1 : entity work.UART_RX
	port map ( 
		clk => CLK,
		rst => RST_BTN,
		i_rx_bit => UART_RX,
		o_data_vld => tx_enable,
		o_rx_data => uart_rx_data
	);


end;
