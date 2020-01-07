library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--Generates signal to light up the four green LED's on the digilent Arty a7 fpga board in a binary counting sequence

entity count_led is 
port (	clk, rst : in std_logic;
		o_led : out std_logic_vector(3 downto 0) );
end;

architecture behaviour of count_led is
constant clk_cnt_1Hz : natural := 100000000;

signal led_drive : std_logic_vector(3 downto 0) := (others => '0');
signal cnt : natural range 0 to clk_cnt_1Hz-1;
begin

process (clk, rst) is
begin
if rising_edge(clk) then
	if rst = '0' then --let switch be active low
		led_drive <= (others => '0');
		cnt <= 0;
	elsif cnt = clk_cnt_1Hz-1 then 
		led_drive <= std_logic_vector(unsigned(led_drive) + 1);
		cnt <= 0;
	else 
		cnt <= cnt + 1;
	end if;
end if;
end process;

o_led <= led_drive;
end;