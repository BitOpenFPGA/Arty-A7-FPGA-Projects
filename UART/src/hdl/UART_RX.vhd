library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART_RX is
	generic (	CLK_FREQ : natural := 100e6; --Arty a7 system clk is 100MHz
				DATA_WIDTH : natural := 8;
				OVERSAMPLING_RATE : natural := 16; --sample the input 16 times per baud
				BAUD_RATE : natural := 9600 --bits/sec
			);
	port (	clk, rst : in std_logic;
			i_rx_bit : std_logic;
			o_data_vld : out std_logic;
			o_rx_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
		 );
end entity;


architecture rtl of UART_RX is

--Signals for oversampling pulse generation
constant OVERSAMPLING_CLK_CNT_THRESHOLD  : natural := CLK_FREQ/BAUD_RATE/OVERSAMPLING_RATE;
signal oversampling_clk_cnt : natural range 0 to OVERSAMPLING_CLK_CNT_THRESHOLD-1;
signal oversampling_pulse : std_logic;



-- Holds the 3 latest samples from the receive line, to be used via majority vote to determine the rx bit
signal rx_bit_samples : std_logic_vector(2 downto 0) := "000"; 
signal rx_bit : std_logic; -- Bit received on line, determined from  majority value from "rx_bit_samples"
signal rx_data : std_logic_vector(DATA_WIDTH-1 downto 0); 

--state machine signals
type RX_STATES is (IDLE, START, READ_DATA, STOP);
signal uart_rx_state : RX_STATES := IDLE;

--signals for receive state machine
signal rx_bit_cnt : natural range 0 to DATA_WIDTH-1 := 0; -- Counter for number of saved/received bits 
signal oversample_cnt : natural range 0 to OVERSAMPLING_RATE-1 := 0; -- Counter for number of sample within the single Baud period

--Synchroniser signals
signal d_meta, input_bit : std_logic;
attribute ASYNC_REG : string;
attribute ASYNC_REG of d_meta: signal is "true";
attribute ASYNC_REG of rx_bit: signal is "true";


begin


-- Input receive signal is UART is asynchronous (i.e there is CDC)
-- Double flop input to reduce probability of metastability 
sync_input : process (clk)
begin
	if rising_edge(clk) then
		d_meta <= i_rx_bit;
		input_bit <= d_meta;
	end if;
end process;


--Generates the pulse at the oversampling rate used as an enable to sample the input bit
gen_oversampling_pulse : process (clk)
begin
	if rising_edge(clk) then
		if rst = '1' then 
			oversampling_clk_cnt <= 0;
			oversampling_pulse <= '0';
		elsif oversampling_clk_cnt < OVERSAMPLING_CLK_CNT_THRESHOLD-1 then
			oversampling_clk_cnt <= oversampling_clk_cnt+1;
			oversampling_pulse <= '0';
		else
			oversampling_pulse <= '1';
			oversampling_clk_cnt <= 0;
		end if;
	end if;
end process;




-- Use Majority Voting
-- Sample the middle three values of the baud period on the receive line
-- Save the rx bit as the value from the majority of the samples (i.e the value with two or more samples)

majority_vote_sample : process (clk)
begin
	if rising_edge(clk) then
		if oversampling_pulse = '1' then 
			rx_bit_samples <= rx_bit_samples(rx_bit_samples'high-1 downto 0) & input_bit;
			-- 2 or more samples of '0'out of 3 means rx bit is '0' otherwise it is a '1' 
			case rx_bit_samples is 
				when "000"|"001"|"010"|"100" =>
					rx_bit <= '0';
				when others =>
					rx_bit <= '1';
			end case;
		end if;
	end if;
end process;


rx_state_machine : process (clk)
begin
	if rising_edge(clk) then
		if rst = '1' then
			uart_rx_state <= IDLE;
			o_data_vld <= '0';
			rx_bit_cnt <= 0;
			oversample_cnt <= 0;
		else
			if oversampling_pulse = '1' then 
				case uart_rx_state is 
					when IDLE =>
						o_data_vld <= '0';
						oversample_cnt <= 0;
						if input_bit = '0' then  -- first transition of start bit detected
							uart_rx_state <= START;
							oversample_cnt <= 1; 
						end if;							
					when START =>
						rx_bit_cnt <= 0;
						-- Wait until middle of baud period and check to make sure it is still low for the start bit
						-- Since we are taking a majority vote of three samples, need to wait until after sampling middle 3 bits
						if oversample_cnt = OVERSAMPLING_RATE/2 + 1 then
							oversample_cnt <= 0;
							if rx_bit = '0' then 
								uart_rx_state <= READ_DATA;
							else -- Detected transition was not start bit, return to idle state
								uart_rx_state <= IDLE;
							end if;
						else 
							oversample_cnt <= oversample_cnt+1;
						end if;
						
					when READ_DATA =>
						if oversample_cnt = OVERSAMPLING_RATE-1 then
							oversample_cnt <= 0;
							rx_data <= rx_bit & rx_data(DATA_WIDTH-1 downto 1);
							if rx_bit_cnt < DATA_WIDTH-1 then
								rx_bit_cnt <= rx_bit_cnt+1;
							else
								rx_bit_cnt <= 0;
								uart_rx_state <= STOP;
								oversample_cnt <= 0;
							end if;
						else --wait 1 baud period to sample input
							oversample_cnt <= oversample_cnt+1;
						end if;

					when STOP =>
						if oversample_cnt = OVERSAMPLING_RATE-1 then
							oversample_cnt <= 0;
							if rx_bit = '1' then
								uart_rx_state <= IDLE;
								rx_bit_cnt <= 0;
								o_data_vld <= '1';
							end if;
						else 
							oversample_cnt <= oversample_cnt+1;
						end if;
				end case;
			end if;
		end if;
		
	end if;


end process;

o_rx_data <= rx_data;




end;
