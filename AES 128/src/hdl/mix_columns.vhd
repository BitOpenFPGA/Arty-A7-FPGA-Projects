library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Performs the mix columns of the AES. 
-- Done through matrix multiplication of the input block with a constant matrix as detailed in the specifications
entity mix_columns is 
port (	clk : in std_logic;
		rst : in std_logic;
		i_data_valid : in std_logic;
		i_data_block : in std_logic_vector(127 downto 0);
		o_data_block : out std_logic_vector(127 downto 0);
		o_data_valid : out std_logic );
end entity;

architecture rtl of mix_columns is
 
type product_arr_t is array (0 to 15) of std_logic_vector(7 downto 0);
signal mult_1_prod_arr, mult_2_prod_arr, mult_3_prod_arr : product_arr_t; --stores the intermediate products before the accumulation step in the matrix multiplication


signal GF_mult_result_valid : std_logic;


begin


-- For the matrix multiplication in the mix columns stage, we need to use the product of every byte times 1, 2, and 3
-- 1* the byte is simply the same byte value
-- 2* and 3* is done by the component GF_mult_2_and_3
intermediate_mult : for I in 0 to 15 generate
	GF_multiplier : entity work.GF_mult_2_and_3
		port map (
			clk => clk,
			rst => rst,
			i_valid => i_data_valid,
			i_multiplicand => i_data_block(8*(16-I)-1 downto 8*(15-I)),
			o_mult_by_2_result => mult_2_prod_arr(I),
			o_mult_by_3_result => mult_3_prod_arr(I),
			o_valid => GF_mult_result_valid
		);
end generate; 

-- Multiplication by 1 is simply the same input byte
-- Delay output by one clock cycle to align the data since the GF multiplier has a latency of 1 clock 
mult_by_1:process(clk)
begin
	if rising_edge(clk) then
		for I in 0 to 15 loop
			mult_1_prod_arr(I) <= i_data_block(8*(16-I)-1 downto 8*(15-I));
		end loop;
	end if;
end process;


-- Perform the addition/accumulation for each column for the matrix multiplication using the products from the multiplier 
--
-- |2 3 1 1|     |a_0|
-- |1 2 3 1|  X  |a_1|
-- |1 1 2 3|     |a_2|
-- |3 1 1 2|     |a_3|
--
mat_mult_addition: process(clk)
begin
	if rising_edge(clk) then
		if rst = '1' then
			o_data_valid <= '0';
		else
			if GF_mult_result_valid = '1' then
				--Do column by column
				for I in 0 to 3 loop
					--first row element
					o_data_block((32*(4-I))-1 downto 32*(4-I)-8) <= mult_2_prod_arr(I*4) xor mult_3_prod_arr(I*4+1) xor mult_1_prod_arr(I*4+2) xor mult_1_prod_arr(I*4+3);	
					
					--second row element
					o_data_block((32*(4-I))-1-8 downto 32*(4-I)-16) <= mult_1_prod_arr(I*4) xor mult_2_prod_arr(I*4+1) xor mult_3_prod_arr(I*4+2) xor mult_1_prod_arr(I*4+3);	
					
					--thrid row element
					o_data_block((32*(4-I))-1-16 downto 32*(4-I)-24) <= mult_1_prod_arr(I*4) xor mult_1_prod_arr(I*4+1) xor mult_2_prod_arr(I*4+2) xor mult_3_prod_arr(I*4+3);	
					
					--fourth row element
					o_data_block((32*(4-I))-1-24 downto 32*(4-I)-32) <= mult_3_prod_arr(I*4) xor mult_1_prod_arr(I*4+1) xor mult_1_prod_arr(I*4+2) xor mult_2_prod_arr(I*4+3);	
				
				end loop;
				o_data_valid <= '1';
			else
				o_data_valid <= '0';
			end if;
		end if;
	end if;
end process;


end;