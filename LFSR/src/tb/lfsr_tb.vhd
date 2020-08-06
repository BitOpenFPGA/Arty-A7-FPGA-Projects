library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity lfsr_tb is
end entity;

architecture behav of lfsr_tb is 
signal clk : std_logic := '0';
signal reset : std_logic := '0';
signal lfsr_dout : std_logic;
signal lfsr_dout_vld : std_logic;
signal lfsr_enable : std_logic := '0';
constant clk_period : time := 10 ns;

begin

lfsr0 : entity work.LFSR 
	port map (	
		clk => clk,
		rst => reset,
		enable => lfsr_enable,
		dout => lfsr_dout, 
		dout_valid=> lfsr_dout_vld
	);
	
	proc_clk: process 
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

    proc_stim: process
    begin
        reset <= '1';
        wait for clk_period*1;
        reset <= '0';
		lfsr_enable <= '1';
		wait for clk_period/2;
		wait for clk_period * 511; --run for 2 periods
        assert false report "success - end of simulation" severity failure;
    end process;

	proc_write_output : process(clk, reset) 
		constant file_name : string(1 to 99) := "C:\Users\Philip\Documents\FPGA\FPGA projects\Random_Arty_A7_Projects\LFSR\src\tb\LFSR_tb_output.txt";
		variable o_line : line ;
		variable output_bit : bit; 
		file OUTFILE: text open write_mode is file_name;
	begin
		
		if reset = '1' then
			
		elsif rising_edge(clk) then
			if lfsr_dout_vld = '1' then
				output_bit := to_bit(lfsr_dout);
				write(o_line, output_bit);
				writeline(OUTFILE, o_line);
			end if;
		end if;
	end process;
end architecture;

