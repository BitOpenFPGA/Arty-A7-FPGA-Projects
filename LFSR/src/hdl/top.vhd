library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Displays the output bit of the LFSR on the green LEDs on the Arty A7
entity top is 
port ( 	CLK, RST_BTN : in std_logic;
		led : out std_logic_vector(1 downto 0) );
end entity;

architecture rtl of top is 

signal rst : std_logic;

--LFSR signals
signal lfsr_enable : std_logic:= '0';
signal lfsr_dout : std_logic;
signal lfsr_dout_vld : std_logic;

--Signals for enable generation
constant CLK_1HZ_THRESHOLD : natural := 100e6; --Arty a7 clk 100MHz, so 100e6 clk ticks for one Hz
signal lfsr_enable_clk_cnt : natural range 0 to CLK_1HZ_THRESHOLD-1 := 0;  

--signals for pulsing the LED using PWM
signal pwm_counter : natural range 0 to 255 := 0; --range 0 to 255 for one pwm cycle. Increments every clk cycle from 100MHz source clk
signal duty_value : natural range 0 to 255 := 0; -- duty cycle value, point where signal goes from high to low
signal led_drive : std_logic := '0'; --output to drive led
--increase to full brightness (0 to 255 duty cycle) over approximately 1 second. 100Mhz system clock. Increment duty cycle value every 100e6/256 clock ticks. 
constant CLK_CNT_PWM_THRESHOLD : natural := 390625;
signal pwm_clk_div_cnt : natural range 0 to CLK_CNT_PWM_THRESHOLD-1 := 0;
begin
    rst <= not RST_BTN; --reset button on ARTY A7 is active low

	LFSR1 : entity work.LFSR 
	port map (	
		clk => clk,
		rst => rst,
		enable => lfsr_enable,
		dout => lfsr_dout, 
		dout_valid => lfsr_dout_vld
	);
	
	--genertes the enable signal to make LFSR progress at 1Hz
	gen_enable : process (clk)
	begin
		if rising_edge(clk) then 
			if rst = '1' then 
				lfsr_enable_clk_cnt <= 0;
				lfsr_enable <= '0';
			elsif lfsr_enable_clk_cnt = CLK_1HZ_THRESHOLD-1 then 
				lfsr_enable_clk_cnt <= 0;
				lfsr_enable <= '1';
			else
				lfsr_enable_clk_cnt <= lfsr_enable_clk_cnt + 1;
				lfsr_enable <= '0';
			end if; 
		end if;
	end process;

	--generates pwm signal to drive LED 
	gen_duty_value : process (clk)
	begin
		if rising_edge(clk) then 
			if rst = '1' or lfsr_enable = '1' then 
				duty_value <= 0;
				pwm_clk_div_cnt <= 0;
			elsif pwm_clk_div_cnt = CLK_CNT_PWM_THRESHOLD-1 then
				pwm_clk_div_cnt <= 0; --reset clk counter
				duty_value <= duty_value + 1; --increment pwm counter
			else
				pwm_clk_div_cnt <= pwm_clk_div_cnt + 1;
			end if;
		end if;
	end process;

	gen_led_drive : process (clk) 
	begin
	if rising_edge(clk) then 
		if rst = '1' or lfsr_enable = '1' then 
			pwm_counter <= 0;
		else
			if pwm_counter = 255 then
				pwm_counter <= 0;
			else
				pwm_counter <= pwm_counter + 1;
			end if;
			
			if pwm_counter < duty_value then 
				led_drive<= '1';
			else
				led_drive<= '0';
			end if;
		end if;
	end if;
	
	end process;

	led <= led_drive & "0" when lfsr_dout = '0' else "0" & led_drive; 


end architecture;