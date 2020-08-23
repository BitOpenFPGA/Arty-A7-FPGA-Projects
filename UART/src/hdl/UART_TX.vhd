library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--UART tramsit with no parity bit, 1 stop bit. Default values 8 bit data width, baud rate 9600, system clock frequency 50 MHz 
entity UART_TX is
	generic	(	BAUD_RATE : integer := 9600;
				DATA_WIDTH : integer := 8;
				CLK_FREQ : integer := 100e6 --ARTY 100MHz system clk
	);
	port( 	clk, rst: in std_logic; 
			i_txdata : in std_logic_vector(7 downto 0);  --Byte of data to send
			i_tx_enable : in std_logic; --Enable pulse with new input data
			o_tx : out std_logic; --single output bit
			o_busy : out std_logic
	);
end entity;

architecture rtl of UART_TX is

constant CLKS_PER_BIT  : integer := CLK_FREQ/BAUD_RATE; --number of system clock ticks per transmission of one bit as per the baud rate
signal clk_cnt : natural range 0 to CLKS_PER_BIT-1 := 0;
signal tx_pulse : std_logic := '0';

type TX_STATES is (IDLE, START, SEND_DATA, STOP);
signal uart_txstate : TX_STATES := IDLE;
signal tx_bit_cnt : natural range 0 to DATA_WIDTH-1 := 0;
signal tx_data : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

--generates single clock period pulse at the specified baud rate to be used in transmit state machine
gen_baud_en :process (clk)
begin
if rising_edge(clk) then 
	if rst = '1' then
		clk_cnt <= 0;
		tx_pulse <= '0';
	elsif clk_cnt < CLKS_PER_BIT -1 then 
		clk_cnt <= clk_cnt + 1;
		tx_pulse <= '0';
	else
		tx_pulse <= '1';
		clk_cnt <= 0;
	end if;
end if;
end process;

--State machine to transmit data
tx_state_machine : process (clk) 
begin
if rising_edge(clk) then
	if rst = '1' then 
		uart_txstate <= IDLE;
		o_busy <= '0';
		tx_bit_cnt <= 0;
	else
		case uart_txstate is
			when IDLE =>
				o_tx <= '1'; --Keep line high when idle
				tx_bit_cnt <= 0;
				if (i_tx_enable = '1') then --recieved new data to send
					o_busy <= '1'; 
					uart_txstate <= START;
					tx_data <= i_txdata; --register the data to send 
				else
					o_busy <= '0'; --ready to recieve new data
				end if;
				
			when START =>
				if tx_pulse = '1' then
					o_tx <= '0'; --send start bit
					uart_txstate <= SEND_DATA;
					tx_bit_cnt <= 0;
				end if;
			when SEND_DATA =>	
				if tx_pulse = '1' then
					o_tx <= tx_data(tx_bit_cnt);
					
					if (tx_bit_cnt < DATA_WIDTH-1) then 
						uart_txstate <= SEND_DATA;
						tx_bit_cnt <= tx_bit_cnt + 1; --increment index
					else --send last bit and go to stop state
						uart_txstate <= STOP;
						tx_bit_cnt <= 0;
					end if;
				end if;
			
			when STOP =>	
				if tx_pulse = '1' then
					o_tx <= '1'; --Send stop bit
					o_busy <= '0'; --ready to recieve new data
					tx_bit_cnt <= 0;
					uart_txstate <= IDLE;
				end if;
		end case;
	end if;
end if;

end process;





end;