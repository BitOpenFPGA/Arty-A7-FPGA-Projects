library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--Linear Feedback Shift Register in Fibonacci form
--output single bit
--
entity LFSR is 
	port (	clk, rst, enable : in std_logic;
			dout, dout_valid : out std_logic);
end entity;

architecture rtl of LFSR is 
constant LFSR_WIDTH : natural := 8; 
constant SEED : std_logic_vector(LFSR_WIDTH-1 downto 0) :=  x"BE";-- initial value of LFSR
signal lfsr_state : std_logic_vector(LFSR_WIDTH-1 downto 0) := SEED;

begin

process(clk) is
begin
if rising_edge(clk) then 
	if rst = '1' then 
		lfsr_state <= SEED;
		dout_valid <= '0';		
	elsif enable = '1' then 
		lfsr_state <=  (lfsr_state(0) xor lfsr_state(2) xor lfsr_state(3) xor lfsr_state(5)) & lfsr_state(LFSR_WIDTH-1 downto 1);  --Polynomial: x^8+x^6+x^5+x^3+1. Reverse bits for fibonacci LFSR
		dout <= lfsr_state(0);
		dout_valid <= '1';
	else 
		dout_valid <= '0';		
	end if;	
end if;
end process;



end;