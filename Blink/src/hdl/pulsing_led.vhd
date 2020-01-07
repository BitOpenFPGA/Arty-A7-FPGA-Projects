library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Generates signal to pulse the four green LED's on the digilent Arty a7 fpga board


entity pulsing_led is 
port (	clk, rst : in std_logic;
		o_led : out std_logic_vector(3 downto 0) );
end;

architecture behaviour of pulsing_led is
--increase to full brightness (0 to 255 duty cycle) over approximately 1 second. 100Mhz system clock. 
--increment duty cycle value every 100e6/256 clock ticks. 
constant clk_cnt_max : natural := 390625;
signal clk_div_cnt : natural range 0 to clk_cnt_max-1;


signal pwm_counter : unsigned(7 downto 0) := (others => '0'); --range 0 to 255 for one pwm cycle
signal duty_value : unsigned(7 downto 0) := (others => '0'); -- duty cycle value, point where signal goes from high to low
signal duty_value_incr_direction : std_logic := '0';

signal led_drive : std_logic_vector(3 downto 0) := (others => '0');
begin
--slow counter to generate the increasing and decreasing duty cycle value
incr_duty: process (clk, rst) is
begin
if rising_edge(clk) then 
	if rst = '0' then --active low reset
		duty_value <= (others=> '0');
		clk_div_cnt <= 0;
		duty_value_incr_direction <= '0';
	elsif clk_div_cnt = clk_cnt_max-1 then 
		if duty_value_incr_direction = '0' then 
		  duty_value <= duty_value + 1;
		else 
		  duty_value <= duty_value - 1;
		end if;
		if (duty_value = 1 and duty_value_incr_direction = '1') or (duty_value = 254 and duty_value_incr_direction = '0') then
		  duty_value_incr_direction <= not duty_value_incr_direction;
		end if;
		clk_div_cnt <= 0;
	else
		clk_div_cnt <= clk_div_cnt + 1;
	end if;
end if;
end process;

--generates pwm output signal for LED according to duty cycle
gen_output: process (clk,rst) is
begin
if rising_edge(clk) then 
	if rst = '0' then 
		led_drive <= (others => '0');
		pwm_counter <= (others => '0');
	else
		pwm_counter <= pwm_counter + 1;
		if pwm_counter < duty_value then 
			led_drive<= (others=>'1');
		else
			led_drive<= (others=>'0');
		end if;
	end if;
end if;
end process;


o_led <= led_drive;
end;