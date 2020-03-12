library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_generator is
	--default values corresponding to vga 640*480 60Hz
	generic (	FRAME_WIDTH : natural := 640;
				FRAME_HEIGHT : natural := 480;
				H_FP : natural := 16;  --Horizontal front porch in number of pixels/clk ticks 
				H_BP : natural := 48; --Horizontal back porch
				H_PULSE : natural := 96; -- Horizontal pulse width
				V_FP : natural := 10;  -- Vertical front porch in number of lines 
				V_BP : natural := 33; --Vertical back porch
				V_PULSE : natural := 2; -- Vertical pulse width
				SYNC_POL : std_logic := '0' --Polarity of sync signals
				);

	port (	clk, pxl_tick, rst : in std_logic;
			h_sync, v_sync : out std_logic;
			pixel_x, pixel_y : out std_logic_vector(11 downto 0); --position of active pixel. Trying to keep it generalised, bit width suitable up to 4k resolution. Other way would be to calulate bit width and declare new type in a package
			active : out std_logic;
			animate : out std_logic
			);
end;			
architecture rtl of sync_generator is

constant LINE_WIDTH : natural :=  FRAME_WIDTH + H_FP + H_PULSE + H_BP; --width in pixels of each line, 800 for 640*480 60 Hz VGA
constant SCREEN_HEIGHT : natural := FRAME_HEIGHT + V_FP + V_PULSE + V_BP; --525 for 640*480 VGA

constant HS_START : natural := FRAME_WIDTH + H_FP; --number of clock cycles until hsync is asserted
constant HS_END : natural := FRAME_WIDTH + H_FP + H_PULSE;  --number of clock cycles until hsync is deasserted
constant VS_START : natural := FRAME_HEIGHT + V_FP;
constant VS_END : natural := V_FP + FRAME_HEIGHT + V_PULSE;  


signal h_cnt : natural range 0 to LINE_WIDTH - 1; --counter for line position
signal v_cnt : natural range 0 to SCREEN_HEIGHT - 1; --counter for screen position

begin
	--increment the horizontal and vertical position counters
	position_counters : process (clk, rst) is
	begin
		if rising_edge(clk) then
			if rst = '1' then 
				h_cnt <= 0;
				v_cnt <= 0;
			elsif pxl_tick = '1' then
				if h_cnt = LINE_WIDTH - 1 then -- reached end of line
					h_cnt <= 0;
					if v_cnt = SCREEN_HEIGHT - 1 then 
						v_cnt <= 0;
					else
						v_cnt <= v_cnt + 1;
					end if;
				else
					h_cnt <= h_cnt + 1;
				end if;
			end if;
		end if;
	end process;
	
	--generate output horizontal and vertical sync signals
	--h_sync <= SYNC_POL when (h_cnt >= HS_START - 1 and h_cnt <= HS_END - 1) else not SYNC_POL;

	h_sync_output : process (clk) is
	begin
		if rising_edge(clk) then
			if pxl_tick = '1' then
				if (h_cnt >= HS_START - 1 and h_cnt < HS_END - 1) then
					h_sync <= SYNC_POL;
				else
					h_sync <= not SYNC_POL;
				end if;
			end if;
		end if;
	end process;

	v_sync_output : process (clk) is
	begin
		if rising_edge(clk) then
			if pxl_tick = '1' then
				if (v_cnt >= VS_START - 1 and v_cnt < VS_END - 1) then
					v_sync <= SYNC_POL;
				else
					v_sync <= not SYNC_POL;
				end if;
			end if;
		end if;
	end process;

	active <= '1' when h_cnt < FRAME_WIDTH and v_cnt < FRAME_HEIGHT else '0';
	animate <= '1' when h_cnt = FRAME_WIDTH-1 and v_cnt = FRAME_HEIGHT-1 else '0'; -- high during last active pixel drawing for screen
	pixel_x <= std_logic_vector(to_unsigned(h_cnt, pixel_x'length)) when h_cnt < FRAME_WIDTH else (others=> '0');
	pixel_y <= std_logic_vector(to_unsigned(v_cnt, pixel_y'length)) when v_cnt < FRAME_HEIGHT else (others=> '0');

end architecture;
			