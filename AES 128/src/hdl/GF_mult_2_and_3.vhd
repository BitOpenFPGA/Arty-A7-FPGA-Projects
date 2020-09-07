library IEEE;
use IEEE.std_logic_1164.all;

-- Multiplies the input byte by 2 and 3 in the Galois/Finite field GF(2^8)
entity GF_mult_2_and_3 is
port ( 	clk : in std_logic;
		rst : in std_logic;
		i_valid : in std_logic;
		i_multiplicand : in std_logic_vector(7 downto 0);
		o_mult_by_2_result : out std_logic_vector(7 downto 0);
		o_mult_by_3_result : out std_logic_vector(7 downto 0);
		o_valid : out std_logic
		);
end entity;

architecture rtl of GF_mult_2_and_3 is

begin


-- Multiply the input byte by 2 and also 3. 
multiply_by_2_and_3 : process (clk)
variable temp_input_shifted : std_logic_vector(8 downto 0);
begin
	if rising_edge(clk) then
		if rst = '1' then
			o_valid <= '0';
		else
			if i_valid = '1' then
				temp_input_shifted := i_multiplicand & '0';
				
				-- 2x multiplication
				-- This is simply a left shift, however, if the 8th bit is 1 need to modulo result by x"1b" in Finite Field arithmetic
				if i_multiplicand(7) = '1' then 
					o_mult_by_2_result <= temp_input_shifted(7 downto 0) xor x"1B"; --x"1b" is the irreducible polynomial in AES
				else 
					o_mult_by_2_result <= temp_input_shifted(7 downto 0);
				end if;
				
				-- 3x multiplication
				-- this is equal to  multiplicand * (2+1) = multiplicand * 2 + multiplicand * 1 (distributivity)
				-- which is simply 2*multiplicand xor multiiplicand
				-- Since we do a left shift, resulting in a data width of 9  and an xor with an 8 bit length vector, 
				-- for the ninth bit of the result to be set, the eighth bit of the input must be '1'
				if i_multiplicand(7) = '1' then 
					o_mult_by_3_result <= temp_input_shifted(7 downto 0) xor i_multiplicand xor x"1B"; --x"1b" is the irreducible polynomial in AES
				else 
					o_mult_by_3_result <= temp_input_shifted(7 downto 0) xor i_multiplicand;
				end if;
				o_valid <= '1';
			else 
				o_valid <= '0';
			end if;	
		end if;
	end if;
end process;

end;