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

--box_x and box_y hold the coordinates of the top left corner of the box. 
signal box_x : unsigned(11 downto 0) := to_unsigned(5, pixel_x'length); 
signal box_y : unsigned(11 downto 0) := to_unsigned(5, pixel_y'length);


--Direction of the box movement in the x and y coordinates. Could have used std_logic type, but define new type for clarity
type x_dir_t is (right, left);
type y_dir_t is (up, down);

signal box_x_dir : x_dir_t := right;
signal box_y_dir : y_dir_t := up;

constant IMG_WIDTH : natural := 144; --size of image is 144*78 pixels
constant IMG_HEIGHT : natural := 78; 

signal rom_addr : std_logic_vector(6 downto 0) := (others=> '0') ;
signal logo_pixels_row : std_logic_vector(143 downto 0);



begin
	
	image_rom1 : entity work.image_rom
	port map (	clk => clk,
				r_addr => rom_addr,
				data => logo_pixels_row );
	

	--sets values of the RGB channels for the current pixel
	set_pixels : process (clk, rst) is
	variable img_row_idx : integer;
	begin
	if rising_edge(clk) then
		if pxl_tick = '1' then
			--Draw the box on the screen
			if unsigned(pixel_x) >= box_x and unsigned(pixel_x) < box_x + IMG_WIDTH and unsigned(pixel_y) >= box_y and unsigned(pixel_y) < box_y + IMG_HEIGHT then 
				img_row_idx := to_integer(unsigned(pixel_x)) - to_integer(box_x);
				red <= (others=>not logo_pixels_row(img_row_idx));
				green <= (others=>not logo_pixels_row(img_row_idx));
				blue <= (others=>not logo_pixels_row(img_row_idx));
				if img_row_idx = 143 then 
				    if rom_addr = std_logic_vector(to_unsigned(77, rom_addr'length)) then   
				        rom_addr <= (others=> '0');
				    elsif active = '1' then
				        rom_addr <= std_logic_vector(unsigned(rom_addr) + 1); 
                    end if;				
				end if;
			else 
				red <= (others=>'0');
				green <= (others=>'0');
				blue <= (others=>'0');
			end if;
		end if; 
	end if;
	end process;
	
	animate_box : process (clk, rst) is
	begin
	if rising_edge(clk) then
		if pxl_tick = '1' and animate = '1' then --progress animation only when whole frame has been displayed
			--change position of box arcording to set direction
			if box_x_dir = right then 
				box_x <= box_x + 1;
			else 
				box_x <= box_x - 1;
			end if; 
			
			if box_y_dir = up then 
				box_y <= box_y - 1;
			else 
				box_y <= box_y + 1;
			end if; 

		end if;
	end if;
	end process;

	set_box_dir : process (clk, rst) is
	begin
	if rising_edge(clk) then
		if pxl_tick = '1' and animate = '1' then

			if box_x = 1 then --hit left border, bounce right
				box_x_dir <= right;
			elsif box_x + IMG_WIDTH - 1 = FRAME_WIDTH-2 then --hit right border, bounce left
				box_x_dir <= left;
			end if; 
			
			if box_y = 1 then --hit TOP border, bounce DOWN
				box_y_dir <= down;
			elsif box_y + IMG_HEIGHT-1 = FRAME_HEIGHT-2 then --hit bottom border, bounce up
				box_y_dir <= up;
			end if; 
		end if;
	end if;
	end process;





end architecture;