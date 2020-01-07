library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;
--Generates signal to light up the four green LED's on the digilent Arty a7 fpga board from left to right and back

entity bouncing_led is
port (	clk, rst: in std_logic;
		o_led : out std_logic_vector(3 downto 0) );
end;

architecture behaviour of bouncing_led is 
--100MHz system clk, 4Hz is every 0.25 seconds which occurs at 100e6/4 clk ticks
constant clk_cnt_4Hz : natural := 25e6;

signal led_drive : std_logic_vector(3 downto 0) := "0001";
signal direction_right : std_logic := '0'; 
signal cnt : natural range 0 to clk_cnt_4Hz-1;

begin

process (clk, rst) is
begin
	if rising_edge(clk) then 
		if rst = '0' then
			led_drive <= "0001";
			direction_right <= '0'; --initial movement of led is to the left
		elsif cnt = clk_cnt_4Hz-1 then --change the "on" led
			cnt <= 0;
			if direction_right = '0' then 
				if led_drive = "1000" then --change direction of LED movement when reached the end 
					direction_right <= '1';
					led_drive <= std_logic_vector(shift_right(unsigned(led_drive),1));
				else 
					led_drive <= std_logic_vector(shift_left(unsigned(led_drive),1)); --shift on LED according to direction
				end if;
			else
				if led_drive = "0001" then 
					direction_right <= '0';
					led_drive <= std_logic_vector(shift_left(unsigned(led_drive),1));
				else 
					led_drive <= std_logic_vector(shift_right(unsigned(led_drive),1));
				end if;			
			end if;
			
		else
			cnt <= cnt + 1;
		end if;
	end if;
end process;

o_led <= led_drive;

end architecture;