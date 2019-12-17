library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity helloworld is
port (	sw : in std_logic_vector(3 downto 0);
		led : out std_logic_vector(3 downto 0) );
end;

architecture behaviour of helloworld is 
begin
led <= sw;
end architecture;