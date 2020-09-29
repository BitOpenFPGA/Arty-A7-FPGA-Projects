library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity key_expansion is 
port (	clk : in std_logic;
		rst : in std_logic;
		i_key : in std_logic_vector(127 downto 0);
		i_key_valid: in std_logic;
		o_round_key_0 : out std_logic_vector(127 downto 0);
		o_round_key_1 : out std_logic_vector(127 downto 0);
		o_round_key_2 : out std_logic_vector(127 downto 0);				
		o_round_key_3 : out std_logic_vector(127 downto 0);				
		o_round_key_4 : out std_logic_vector(127 downto 0);				
		o_round_key_5 : out std_logic_vector(127 downto 0);				
		o_round_key_6 : out std_logic_vector(127 downto 0);				
		o_round_key_7 : out std_logic_vector(127 downto 0);				
		o_round_key_8 : out std_logic_vector(127 downto 0);				
		o_round_key_9 : out std_logic_vector(127 downto 0)				
	);
end entity;

architecture rtl of key_expansion is 

type round_key_arr_t is array (0 to 10) of std_logic_vector(127 downto 0);
signal round_key_arr : round_key_arr_t;
signal delayed_round_key_arr : round_key_arr_t; --delayed 1 clock cycle to align with data in round pipeline


signal valid_arr : std_logic_vector(10 downto 0);
signal delayed_valid_arr : std_logic_vector(10 downto 0); --delayed 1 clock cycle to align with data in round pipeline

begin

valid_arr(0) <= i_key_valid;
round_key_arr(0) <= i_key;

key_expansion: for I in 0 to 9 generate

	incr_key_exp : entity work.incremental_key_exp
		generic map (ROUND_NUMBER => I)
		port map (
				clk => clk,
				rst => rst,
				i_prev_key => delayed_round_key_arr(I),
				i_prev_key_valid => delayed_valid_arr(I), 
				o_round_key => round_key_arr(I+1), 				
				o_round_key_valid  => valid_arr(I+1)
		);

end generate; 


dalay_round_key :process(clk) 
begin
if rising_edge(clk) then 
		delayed_round_key_arr <= round_key_arr;
		delayed_valid_arr <= valid_arr;	
end if;

end process;

o_round_key_0 <=round_key_arr(1);
o_round_key_1 <=round_key_arr(2);
o_round_key_2 <=round_key_arr(3);				
o_round_key_3 <=round_key_arr(4);				
o_round_key_4 <=round_key_arr(5);				
o_round_key_5 <=round_key_arr(6);				
o_round_key_6 <=round_key_arr(7);				
o_round_key_7 <=round_key_arr(8);				
o_round_key_8 <=round_key_arr(9);				
o_round_key_9 <=round_key_arr(10);	


end;
