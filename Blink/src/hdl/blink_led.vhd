library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--Generates signal to blink the four green LED's on the digilent Arty a7 fpga board at 1Hz

entity blink_led is
port (	clk, rst : in std_logic;
		o_led : out std_logic_vector(3 downto 0) );
end;

architecture behaviour of blink_led is 

--Clk is 100Mhz. For a 1Hz blinking LED with a 50% duty cycle,
--the number of clk ticks is 100000000 / 1 * 50% = 50 000 000
constant clk_cnt_1Hz : natural := 50000000;

signal led_drive : std_logic_vector(3 downto 0) := (others => '0');
signal cnt : natural range 0 to clk_cnt_1Hz-1;

begin

process (clk, rst) is
begin
	if rising_edge(clk) then 
		if rst = '0' then --make switch active low
			led_drive <= (others => '0');
			cnt <= 0;
		elsif cnt = clk_cnt_1Hz-1 then
			cnt <= 0;
			led_drive <= not led_drive;
		else 
			cnt <= cnt + 1;
		end if;
	end if;
end process;

o_led <= led_drive;

end architecture;