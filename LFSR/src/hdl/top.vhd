library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Displays the output bit of the LFSR on the green LEDs on the Arty A7
entity top is 
port ( 	CLK, RST_BTN : in std_logic;
		led : out std_logic_vector(3 downto 0) );
end entity;

architecture rtl of top is 

signal rst : std_logic;

--LFSR signals
signal lfsr_enable : std_logic:= '0';
signal lfsr_dout : std_logic;

--Signals for enable generation
constant CLK_1HZ_THRESHOLD : natural := 100e6; --Arty a7 clk 100MHz, so 100e6 clk ticks for one Hz
signal enable_clk_cnt : natural range 0 to CLK_1HZ_THRESHOLD-1 := 0;  



begin
    rst <= not RST_BTN; --reset button on ARTY A7 is active low

	--genertes the enable signal to make LFSR progress
	gen_enable : process (clk)
	begin
		if rising_edge(clk) then 
			if rst = '1' then 
				enable_clk_cnt <= 0;
				lfsr_enable <= '0';
			elsif enable_clk_cnt = CLK_1HZ_THRESHOLD-1 then 
				enable_clk_cnt <= 0;
				lfsr_enable <= '1';
			else
				enable_clk_cnt <= enable_clk_cnt + 1;
				lfsr_enable <= '0';
			end if; 
		end if;
	end process;




	LFSR1 : entity work.LFSR 
	port map (	
		clk => clk,
		rst => rst,
		enable => lfsr_enable,
		dout => lfsr_dout 
	);

	led <= "1100" when lfsr_dout = '0' else "0011"; 


end architecture;