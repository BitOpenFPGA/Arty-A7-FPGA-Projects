library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_top is

port (	SYS_CLK100, RST_BTN : in std_logic; --100Mhz on Arty A7
		VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0);
		VGA_HSYNC, VGA_VSYNC : out std_logic	
	);
end entity;	
architecture rtl of vga_top is 

constant clk_div_threshold : natural := 3; 
signal clk_cnt : unsigned(1 downto 0) := (others => '0');
signal pxl_tick : std_logic := '0';
signal pixel_x, pixel_y : std_logic_vector(11 downto 0);
signal active, animate : std_logic; --not used at the moment
signal rst : std_logic;
signal red, green, blue : std_logic_vector(3 downto 0);
begin

    rst <= not RST_BTN; --reset button on ARTY A7 is active low

	vga_sync_gen : entity work.sync_generator
	port map (	clk => SYS_CLK100,
				rst => rst,
				pxl_tick => pxl_tick,
				h_sync => VGA_HSYNC,
				v_sync => VGA_VSYNC,
				pixel_x => pixel_x,
				pixel_y => pixel_y,
				active => active,
				animate => animate
	);

	vga_image_gen : entity work.image_generator
	port map (	clk => SYS_CLK100,
				rst => rst,
				pxl_tick => pxl_tick,
				pixel_x => pixel_x,
				pixel_y => pixel_y,
				active => active,
				animate => animate,
				red => red,
				blue => green,
				green => blue
	);

	VGA_R <= red when active = '1' else (others=>'0');
	VGA_G <= green when active = '1' else (others=>'0');
	VGA_B <= blue when active = '1' else (others=>'0');



	--generate pixel tick - asserted once every four clock cycles with 100Mhz input clk - making 25Mhz signal
	gen_pxl_tick : process (SYS_CLK100, rst) is
	begin
		if rising_edge(SYS_CLK100) then 
			if rst = '1' then 
				clk_cnt <= (others=>'0');
				pxl_tick <= '0';
			else 
				clk_cnt <= clk_cnt + 1;
				if clk_cnt = clk_div_threshold then 
					clk_cnt <= (others => '0');
					pxl_tick <= '1';
				else 
					pxl_tick <= '0';
				end if;
			end if;
		end if;
	end process;
end architecture;