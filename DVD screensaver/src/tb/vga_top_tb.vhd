library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_top_tb is
end entity;

architecture behaviour of vga_top_tb is
constant clk_period : time := 10 ns; 
signal clk, rst : std_logic := '0';
signal red,green,blue : std_logic_vector(3 downto 0);
signal vga_hsync, vga_vsync : std_logic;
begin

	vga_top1 : entity work.vga_top
	port map (	SYS_CLK100 => clk,
				RST_BTN => rst,
				VGA_R => red,
				VGA_G => green,
				VGA_B => blue,
				VGA_HSYNC => vga_hsync,
				VGA_VSYNC => vga_vsync
				);
	
	



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
		rst <= '0';
		wait until falling_edge(clk);
		rst <= '1';
		wait for 5 sec;
		assert false report "success - end of simulation" severity failure;
	end process;
	
	
end architecture;