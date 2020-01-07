library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--Top module for the various blinking LED designs. Change the constant "LED_function" to select what is implemented on the Arty A7 FPGA
entity top is
port (	clk : in std_logic;
		sw : in std_logic_vector(3 downto 0);
		led : out std_logic_vector(3 downto 0) );
end;

architecture behaviour of top is 
type LED_function_t is  (Blink, Bounce, Pulse, Count);
constant LED_function : LED_function_t := Pulse; --change this value to change circuit function
begin
  g1: case LED_function generate
    when Blink =>
      blink_led0 : entity work.blink_led
            port map (	clk => clk,
						rst => sw(0),
						o_led => led );
    when Count =>
      count_led0 : entity work.count_led
            port map (	clk => clk,
						rst => sw(0),
						o_led => led );
	when Bounce =>
		bouncing_led1 : entity work.bouncing_led
			port map (	clk => clk, 
						rst => sw(0),
						o_led => led );
	when Pulse => 
		pulsing_led1 : entity work.pulsing_led
			port map (	clk => clk,
						rst => sw(0),
						o_led => led );
    when others =>

  end generate;  


end architecture;