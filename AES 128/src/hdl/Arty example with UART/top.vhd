library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top is 
port (	clk : in std_logic;
		rst_btn : in std_logic;
		uart_txd_in : in std_logic;
		uart_rxd_out : out std_logic
);
end entity;

architecture rtl of top is 
signal reset : std_logic;

-- AES signals
signal key : std_logic_vector(127 downto 0);
signal new_key_valid : std_logic;
signal plaintext : std_logic_vector(127 downto 0);
signal ciphertext : std_logic_vector(127 downto 0);
signal plaintext_valid, ciphertext_valid : std_logic;



--UART signals
signal uart_rx_data, uart_tx_data : std_logic_vector(7 downto 0);
signal uart_rx_data_vld, uart_tx_data_vld : std_logic;
signal uart_tx_busy : std_logic;

signal uart_rx_vld_delayed : std_logic;
signal uart_rx_new_data : std_logic;

--
signal input_block_buf : std_logic_vector(127 downto 0);

type receive_state_t is (RECEIVE_KEY, RECEIVE_PLAINTEXT);
signal receive_state : receive_state_t := RECEIVE_KEY;
signal rx_byte_count : natural range 0 to 15 := 0;

type transmit_state_t is (IDLE, TRANSMIT);
signal transmit_state : transmit_state_t := IDLE;
signal tx_byte_count : natural range 0 to 15 := 0;



begin

reset <= not rst_btn; --rst button is active low


AES_128 : entity work.AES_128
	port map (
		clk => clk,
		rst => reset,
		i_key => key,
		i_new_key_valid => new_key_valid,
		i_plaintext => plaintext,
		i_plaintext_valid => plaintext_valid, 
		o_ciphertext => ciphertext,
		o_ciphertext_valid => ciphertext_valid
	);

uart_tx : entity work.UART_TX
	generic map (	CLK_FREQ => 100e6,
				DATA_WIDTH => 8,
				BAUD_RATE => 9600 
	)
	port map (	
		clk => clk, 	
		rst => reset,
		i_txdata => uart_tx_data,
		i_tx_enable => uart_tx_data_vld,
		o_tx => uart_rxd_out,
		o_busy => uart_tx_busy
	);
	
	
uart_rx : entity work.UART_RX
	generic map (	CLK_FREQ => 100e6, 
				DATA_WIDTH => 8,
				BAUD_RATE => 9600)
	port map ( 
		clk => clk,
		rst => reset,
		i_rx_bit => uart_txd_in,
		o_data_vld => uart_rx_data_vld,
		o_rx_data => uart_rx_data  
	);

-- transmit state machine - selects the byte of data to transmit on UART from the 128 bit ciphertext
output_byte : process (clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			transmit_state <= IDLE;
			tx_byte_count <= 0;
			uart_tx_data_vld <= '0';
		else
			case transmit_state is
				when IDLE =>
					if ciphertext_valid = '1' then
						--send first byte
						uart_tx_data <= ciphertext(8*(16-tx_byte_count)-1 downto 8*(16-tx_byte_count-1)); 
						uart_tx_data_vld <= '1';
						transmit_state <= TRANSMIT;
					end if;
				when TRANSMIT => 
					uart_tx_data <= ciphertext(8*(16-tx_byte_count)-1 downto 8*(16-tx_byte_count-1)); 
					uart_tx_data_vld <= '1';
					if uart_tx_busy = '0' and uart_tx_data_vld = '1' then
						if tx_byte_count = 15 then
							tx_byte_count <= 0;
							transmit_state <= IDLE;
							uart_tx_data_vld <= '0';
						else
							tx_byte_count <= tx_byte_count + 1;
						end if;
					end if;
			end case;
		end if;
	end if;
end process;


-- Receive state machine - constructs the 128 bit length block of input data from the 8 bit uart signals 
-- Just for simplicity, in this implemention the first 128 bits received on UART are the input key,
-- and all following 128 bits correspond to plaintext

construct_input_data : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			receive_state <= RECEIVE_KEY;
			rx_byte_count <= 0;
			new_key_valid <= '0';
			plaintext_valid <= '0';
		else 
			case receive_state is
				when RECEIVE_KEY =>
					if uart_rx_new_data = '1' then
						key <= key(119 downto 0) & uart_rx_data;
						rx_byte_count <= rx_byte_count + 1;
						if rx_byte_count = 15 then
							rx_byte_count <= 0;
							new_key_valid <= '1';
							receive_state <= RECEIVE_PLAINTEXT;
						end if;
					end if;
				when RECEIVE_PLAINTEXT =>
					new_key_valid <= '0';
					plaintext_valid <= '0';
					if uart_rx_new_data = '1' then
						plaintext <= plaintext(119 downto 0) & uart_rx_data;
						rx_byte_count <= rx_byte_count + 1;
						if rx_byte_count = 15 then
							rx_byte_count <= 0;
							plaintext_valid <= '1';
						end if;
					end if;
				when others =>
					NULL;
			end case;
		end if;
	end if;
end process;


-- The uart receive component I have implemented currently outputs a high valid signal for 1/baud (i.e the length of the whole bit 
-- transfer period) as opposed to only one clk cycle of the system clock. So we need to detect the rising edge to indicate when new data is received.
detect_rising_edge_data_vld : process (clk) 
begin
	if rising_edge(clk) then
		if reset = '1' then
			uart_rx_new_data <= '0';
		else 
			uart_rx_vld_delayed <= uart_rx_data_vld;
			if uart_rx_vld_delayed = '0' and uart_rx_data_vld = '1' then
				uart_rx_new_data <= '1';
			else
				uart_rx_new_data<= '0';
			end if;
		end if;
	end if;
end process; 

end;
