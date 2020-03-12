library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity image_generator is
generic (	FRAME_WIDTH : natural := 640;
			FRAME_HEIGHT : natural := 480 );
			
port (	clk, pxl_tick, rst : in std_logic; --clk is system clock, pxl_tick is asserted at vga frequency (25 MHz for vga 640*480).
		pixel_x, pixel_y : in std_logic_vector(11 downto 0); --position of the current active pixel to draw
		active : in std_logic; --asserted when within active portion of screen
		animate : in std_logic; --asserted for one clock cycle at end of frame
		red, green, blue : out std_logic_vector(3 downto 0)); --value of the colour channels
		
		
end entity;

architecture rtl of image_generator is



begin
--Let's draw a test pattern
--split 640 by 480 screen into seven intervals for each different colour, then each interval into more intervals to display increasing intensity. 
	process (pixel_x,pixel_y) 
	begin
	case to_integer(unsigned(pixel_x)) is
		--red colour only
		when 0 to 89 => 			
			red <= pixel_y(8 downto 5); 
			green <= (others=>'0');
			blue <= (others=>'0');
		when 90 to 179 => 			
			red <= (others=>'0'); 
			green <= pixel_y(8 downto 5); 
			blue <= (others=>'0');
		when 180 to 269 => 			
			red <= (others=>'0'); 
			green <= (others=>'0');
			blue <= pixel_y(8 downto 5); 
		when 270 to 359 => 			
			red <= pixel_y(8 downto 5); 
			green <= pixel_y(8 downto 5); 
			blue <= (others=>'0');
		when 360 to 449 => 			
			red <= pixel_y(8 downto 5);  
			green <= (others=>'0');
			blue <= pixel_y(8 downto 5); 
		when 450 to 539 => 			
			red <= (others=>'0');
			green <= pixel_y(8 downto 5); 
			blue <= pixel_y(8 downto 5); 
		when 540 to 639 => 			
			red <= pixel_y(8 downto 5); 
			green <= pixel_y(8 downto 5); 
			blue <= pixel_y(8 downto 5); 
		
		when others =>
			red <= (others=> '0');
			green <= (others=>'0');
			blue <= (others=>'0');
		end case;
	end process;

end architecture;