library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_generator_tb is
end entity;

architecture behaviour of sync_generator_tb is
constant clk_period : time := 10 ns;
constant clk_div_threshold : natural := 3;
 
signal clk_cnt : unsigned(1 downto 0) := (others => '0');
signal pxl_tick : std_logic := '0';
signal pixel_x, pixel_y : std_logic_vector(11 downto 0);
signal active : std_logic; --not used at the moment
signal clk, rst : std_logic := '0';
signal vga_hsync, vga_vsync : std_logic := '0';
begin

	vga_sync_gen : entity work.sync_generator
	port map (	clk => clk,
				rst => rst,
				pxl_tick => pxl_tick,
				h_sync => vga_hsync,
				v_sync => vga_vsync,
				pixel_x => pixel_x,
				pixel_y => pixel_y,
				active => active
	);
	
	--generate pixel tick - asserted once every four clock cycles with 100Mhz input clk - making 25Mhz signal
	gen_pxl_tick : process (clk, rst) is
	begin
		if rising_edge(clk) then 
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



	clock : process 
	begin 
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
	proc_set: process
	begin
		wait until falling_edge(clk);
		rst <= '1';
		wait until falling_edge(clk);
		rst <= '0';
		wait for 0.5 sec;
		assert false report "success - end of simulation" severity failure;
	end process;
	
	
end architecture;